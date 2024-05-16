#!/bin/bash
# shellcheck shell=bash

apt_install_packages() {
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

apt_install_extra_packages() {
    mapfile -t extra_packages < <(
        if [ -f packages.txt ]; then
            cat packages.txt
        else
            curl -s https://raw.githubusercontent.com/ak1ra-lab/selfhosted-server/master/packages.txt
        fi
    )

    apt-get update
    apt-get upgrade -y
    apt-get install -y "${extra_packages[@]}"
}

init_user() {
    username="$1"
    # create sudo group
    if ! grep -q sudo /etc/group; then
        groupadd --system sudo
    fi

    # modify /etc/sudoers
    test -d /etc/sudoers.d || mkdir -p /etc/sudoers.d
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/sudo
    sed -i 's%^#? *@includedir +/etc/sudoers\.d%@includedir /etc/sudoers.d%' /etc/sudoers

    # create user
    if ! grep -qE '^'"${username}"':' /etc/passwd; then
        useradd -m -s /bin/bash -G sudo "${username}"
    else
        if ! id "${username}" | grep -q sudo; then
            usermod -aG sudo "${username}"
        fi
    fi

    user_home_dir="$(awk -F: '$1 ~ /^'"${username}"'/ {print $(NF-1)}' /etc/passwd)"
    user_password_file="${user_home_dir}/password.txt"

    # set user password
    # password=$(openssl rand -base64 15)
    password="$(dd if=/dev/urandom bs=3 count=5 2>/dev/null | base64)"
    echo "${username}:${password}" | tee "${user_password_file}" | chpasswd --crypt-method SHA512
    echo "user_password_file saved at ${user_password_file}"
}

add_ssh_key() {
    username="$1"
    ssh_public_key_content="$2"

    user_perm="$(awk -F: '$1 ~ /^'"${username}"'/ {print $3":"$4}' /etc/passwd)"
    user_home_dir="$(awk -F: '$1 ~ /^'"${username}"'/ {print $(NF-1)}' /etc/passwd)"
    user_ssh_dir="${user_home_dir}/.ssh"

    test -d "${user_ssh_dir}" || mkdir -p "${user_ssh_dir}"
    if ! grep -q "${ssh_public_key_content}" "${user_ssh_dir}/authorized_keys"; then
        echo "${ssh_public_key_content}" | tee -a "${user_ssh_dir}/authorized_keys"
    fi

    chown -R "${user_perm}" "${user_ssh_dir}"
    find "${user_ssh_dir}" -type d -exec chmod 700 "{}" \;
    find "${user_ssh_dir}" -type f -exec chmod 600 "{}" \;
}

main() {
    if ! awk -F= '/^ID=/ {print $2}' /etc/os-release | grep -qE '(debian|ubuntu)'; then
        echo "This script only support Debian/Ubuntu distro."
        exit 1
    fi

    if [ "$(id -u)" -ne 0 ]; then
        echo "Please run this script as root or prefix with sudo"
        exit 2
    fi

    # read required arguments
    while read -r -p "Please ENTER the username of the user you want to create: " username; do
        test -n "${username}" && break
        echo "username can not be empty!"
    done

    ssh_public_key=""
    ssh_public_key_content=""
    openssh_format_regex='^(ssh-(rsa|ed25519)|ecdsa-sha2-nistp(256|384|521)|(sk-ecdsa-sha2-nistp256|sk-ssh-ed25519)@openssh\.com)'
    while read -r -p "Please ENTER your ssh_public_key, Can be a GitHub username, OpenSSH format public key url or public key content: " ssh_public_key; do
        # OpenSSH format public key content
        if echo "${ssh_public_key}" | grep -qE "${openssh_format_regex}"; then
            ssh_public_key_content="${ssh_public_key}"
            break
        fi

        # Public key url or GitHub username
        ssh_public_key_url=""
        if echo "${ssh_public_key}" | grep -qE '^https?://'; then
            ssh_public_key_url="${ssh_public_key}"
        else
            # arbitrary input, must be a valid GitHub username
            ssh_public_key_url="https://github.com/${ssh_public_key}.keys"
        fi

        ssh_public_key_content="$(curl -sL "${ssh_public_key_url}")"
        if echo "${ssh_public_key_content}" | grep -qE "${openssh_format_regex}"; then
            break
        else
            echo "ssh_public_key_content format mismatch, please re-ENTER"
            echo "ssh_public_key_content = ${ssh_public_key_content}"
        fi
    done

    apt_install_packages
    apt_install_extra_packages

    init_user "${username}"
    add_ssh_key "${username}" "${ssh_public_key_content}"
}

main "$@"
