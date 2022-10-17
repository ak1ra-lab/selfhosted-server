#! /bin/bash

if ! awk -F= '/^ID=/ {print $2}' /etc/os-release | grep -qE '(debian|ubuntu)'; then
    echo "This script only support Debian/Ubuntu distro."
    exit 1
fi

if [ `id -u` -ne 0 ]; then
    echo "Please run this script as root or prefix with sudo"
    exit 2
fi

function apt_upgrade() {
    apt-get update
    apt-get upgrade -y
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        debian-archive-keyring \
        gnupg2 \
        lsb-release \
        sudo
}

function init_user() {
    # create sudo group
    if ! grep -q sudo /etc/group; then
        groupadd --system sudo
    fi

    # modify /etc/sudoers
    sed -i 's%^#? *@includedir +/etc/sudoers\.d%@includedir /etc/sudoers.d%' /etc/sudoers
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/sudo

    # create user
    if ! grep -qE '^'$username':' /etc/passwd; then
        useradd -m -s /bin/bash -G sudo $username
    else
        if ! id $username | grep -q sudo; then
            usermod -aG sudo $username
        fi
    fi

    local user_home_dir=$(awk -F: '$1 ~ /^'$username'/ {print $(NF-1)}' /etc/passwd)
    local user_password_file=$user_home_dir/password.txt

    # set user password
    # password=$(openssl rand -base64 15)
    local password=$(dd if=/dev/urandom bs=3 count=5 2>/dev/null | base64)
    echo "$username:$password" | tee $user_password_file \
        | chpasswd --crypt-method SHA512
    echo "user_password_file saved at $user_password_file"
}

function add_ssh_key() {
    # add user ssh_key
    local user_home_dir=$(awk -F: '$1 ~ /^'$username'/ {print $(NF-1)}' /etc/passwd)
    test -d $user_home_dir/.ssh || mkdir -p $user_home_dir/.ssh
    curl -sL $ssh_public_key_url | tee -a $user_home_dir/.ssh/authorized_keys

    chown -R "${username}." $user_home_dir/.ssh
    chmod 0700 $user_home_dir/.ssh
    chmod 0600 $user_home_dir/.ssh/*
}

function main() {
    # read required arguments
    while read -p "Please ENTER your username: " username; do
        test -n "$username" && break
        echo "username can not be empty!"
    done

    while read -p "Please ENTER your ssh_public_key_url or GitHub username: " ssh_public_key_url; do
        test -n "$ssh_public_key_url" && break
        echo "ssh_public_key_url can not be empty!"
    done

    if echo "$ssh_public_key_url" | grep -qE '^https?://'; then
        ssh_public_key_url="$ssh_public_key_url"
    else
        ssh_public_key_url="https://github.com/${ssh_public_key_url}.keys"
    fi

    apt_upgrade
    init_user
    add_ssh_key
}

main
