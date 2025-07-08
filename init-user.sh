#!/bin/bash
# shellcheck shell=bash

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
# Exit with a non-zero status if any command in a pipeline fails.
set -euo pipefail

# --- Logging functions ---
# Usage: log "some message"
log() {
    echo >&2 -e "[INFO] $*"
}

# Usage: die "error message"
die() {
    echo >&2 -e "[ERROR] $*"
    exit 1
}

# --- Prerequisite checks ---
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        die "This script must be run as root."
    fi
}

check_distro() {
    distro="$(awk -F= '/^ID=/ {print $2}' /etc/os-release)"
    if [[ "${distro}" != "debian" ]]; then
        die "This script currently only support Debian."
    fi
}

require_command() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            die "Required command '$cmd' is not installed. Please install it and try again."
        fi
    done
}

init_apt_sources() {
    codename="$(awk -F= '/^VERSION_CODENAME/ {print $2}' /etc/os-release)"

    cat >/etc/apt/sources.list <<EOF
deb https://deb.debian.org/debian/ ${codename} main contrib non-free non-free-firmware
# deb-src https://deb.debian.org/debian/ ${codename} main contrib non-free non-free-firmware

deb https://deb.debian.org/debian/ ${codename}-updates main contrib non-free non-free-firmware
# deb-src https://deb.debian.org/debian/ ${codename}-updates main contrib non-free non-free-firmware

deb https://deb.debian.org/debian-security/ ${codename}-security main contrib non-free non-free-firmware
# deb-src https://deb.debian.org/debian-security/ ${codename}-security main contrib non-free non-free-firmware

# deb https://deb.debian.org/debian/ ${codename}-backports main contrib non-free non-free-firmware
# deb-src https://deb.debian.org/debian/ ${codename}-backports main contrib non-free non-free-firmware

EOF
}

# --- Core functions ---
install_dependencies() {
    log "Updating package list and installing dependencies..."
    apt-get update
    apt-get upgrade -y
    apt-get install -y \
        ca-certificates \
        curl \
        debian-archive-keyring \
        gnupg2 \
        lsb-release \
        sudo \
        passwd # for chpasswd
    log "Dependencies installed."
}

setup_sudo() {
    log "Configuring sudo group..."
    if ! getent group sudo >/dev/null; then
        log "Creating 'sudo' group."
        groupadd --system sudo
    fi

    # Ensure sudoers.d is included
    if ! grep -qE '^\s*#?\s*@includedir\s+/etc/sudoers\.d' /etc/sudoers; then
        log "Adding @includedir /etc/sudoers.d to /etc/sudoers"
        echo '#includedir /etc/sudoers.d' >>/etc/sudoers
    else
        log "Ensuring /etc/sudoers.d is included."
        sed -i -E 's%^#?\s*@includedir\s+/etc/sudoers\.d%@includedir /etc/sudoers.d%' /etc/sudoers
    fi

    # Create sudoers file for the group
    local sudo_file="/etc/sudoers.d/sudo"
    if [ ! -f "$sudo_file" ]; then
        log "Creating sudoers file for group 'sudo' with NOPASSWD."
        echo "%sudo ALL=(ALL) NOPASSWD:ALL" >"$sudo_file"
        chmod 440 "$sudo_file"
    else
        log "Sudoers file for group 'sudo' already exists."
    fi
    log "Sudo configuration complete."
}

create_user() {
    local user="$1"
    log "Setting up user '$user'..."

    if ! id "$user" &>/dev/null; then
        log "Creating user '$user' and adding to 'sudo' group."
        useradd -m -s /bin/bash -G sudo "$user"
    else
        log "User '$user' already exists."
        if ! id -nG "$user" | grep -qw sudo; then
            log "Adding existing user '$user' to 'sudo' group."
            usermod -aG sudo "$user"
        else
            log "User '$user' is already in 'sudo' group."
        fi
    fi
}

chpasswd_user() {
    local user="$1"
    log "Change password for user '$user'..."

    # Generate and set password
    log "Generating a new password for '$user'."
    # Using openssl is more common and readable
    local password
    password=$(openssl rand -base64 12)
    echo "${user}:${password}" | chpasswd --crypt-method SHA512

    log "User setup complete."
    echo "---"
    echo "Username: $user"
    echo "Password: $password"
    echo "---"
    echo "Please save this password in a secure location."
}

# --- Main script logic ---
main() {
    check_root
    check_distro

    require_command apt-get groupadd useradd usermod chpasswd openssl getent

    local user
    user="${1:-}" # Set user to first argument, or empty if not provided

    if [ -z "$user" ]; then
        die "Usage: $0 <username>"
    fi

    init_apt_sources
    install_dependencies
    setup_sudo
    create_user "$user"

    log "Initialization complete for user '$user'."
}

# Execute main function with all script arguments
main "$@"
