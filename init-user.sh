#! /bin/bash

user="$1"
test -n "$user" || user=ak1ra
user_password_file=/home/$user/password.txt

github_user="$2"
test -n "$github_user" || github_user=ak1ra-komj
ssh_public_key_url=https://github.com/${github_user}.keys

if [ `id -u` -ne 0 ]; then
    echo "Please run this script as root or prefix with sudo"
    exit 1
fi

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

# create sudo group
if ! grep -q sudo /etc/group; then
    groupadd --system sudo
fi

# create user
if ! grep -qE $user /etc/passwd; then
    useradd -m -s /bin/bash -G sudo $user
else
    usermod -aG sudo $user
fi

# set user password
# password=$(openssl rand -base64 15)
password=$(dd if=/dev/urandom bs=3 count=5 2>/dev/null | base64)
echo "$user:$password" | tee $user_password_file \
    | chpasswd --crypt-method SHA512
echo "user password file saved at $user_password_file"

# add user ssh_key
test -d /home/$user/.ssh || mkdir -p /home/$user/.ssh
curl -sL $ssh_public_key_url | tee -a /home/$user/.ssh/authorized_keys
chown -R "${user}." /home/$user/.ssh
chmod 0700 /home/$user/.ssh
chmod 0600 /home/$user/.ssh/*

# modify /etc/sudoers
sed -i 's%^#? *@includedir +/etc/sudoers\.d%@includedir /etc/sudoers.d%' /etc/sudoers
echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudo
