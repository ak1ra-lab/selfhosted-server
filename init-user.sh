#!/bin/bash

set -o errexit -o nounset -o pipefail

SCRIPT_FILE="$(readlink -f "$0")"
SCRIPT_NAME="$(basename "${SCRIPT_FILE}")"

# Logging configuration
declare -g LOG_LEVEL="INFO"    # ERROR, WARNING, INFO, DEBUG
declare -g LOG_FORMAT="simple" # simple, level, full

# Log level priorities
declare -g -A LOG_PRIORITY=(
    ["DEBUG"]=10
    ["INFO"]=20
    ["WARNING"]=30
    ["ERROR"]=40
    ["CRITICAL"]=50
)

# Logging functions
log_color() {
    local color="$1"
    shift
    if [[ -t 2 ]]; then
        printf "\x1b[0;%sm%s\x1b[0m\n" "${color}" "$*" >&2
    else
        printf "%s\n" "$*" >&2
    fi
}

log_message() {
    local color="$1"
    local level="$2"
    shift 2

    if [[ "${LOG_PRIORITY[$level]}" -lt "${LOG_PRIORITY[$LOG_LEVEL]}" ]]; then
        return 0
    fi

    local message="$*"
    case "${LOG_FORMAT}" in
        simple)
            log_color "${color}" "${message}"
            ;;
        level)
            log_color "${color}" "[${level}] ${message}"
            ;;
        full)
            local timestamp
            timestamp="$(date -u +%Y-%m-%dT%H:%M:%S+0000)"
            log_color "${color}" "[${timestamp}][${level}] ${message}"
            ;;
        *)
            log_color "${color}" "${message}"
            ;;
    esac
}

log_error() {
    local RED=31
    log_message "${RED}" "ERROR" "$@"
}

log_info() {
    local GREEN=32
    log_message "${GREEN}" "INFO" "$@"
}

log_warning() {
    local YELLOW=33
    log_message "${YELLOW}" "WARNING" "$@"
}

log_debug() {
    local BLUE=34
    log_message "${BLUE}" "DEBUG" "$@"
}

log_critical() {
    local CYAN=36
    log_message "${CYAN}" "CRITICAL" "$@"
}

# Set log level with validation
set_log_level() {
    local level="${1^^}" # Convert to uppercase
    if [[ -n "${LOG_PRIORITY[${level}]:-}" ]]; then
        LOG_LEVEL="${level}"
    else
        log_error "Invalid log level: ${1}. Valid levels: ERROR, WARNING, INFO, DEBUG"
        exit 1
    fi
}

# Set log format with validation
set_log_format() {
    case "$1" in
        simple | level | full)
            LOG_FORMAT="$1"
            ;;
        *)
            log_error "Invalid log format: ${1}. Valid formats: simple, level, full"
            exit 1
            ;;
    esac
}

# Check if required commands are available
require_command() {
    for c in "$@"; do
        if ! command -v "$c" >/dev/null 2>&1; then
            log_error "Required command '$c' is not installed"
            exit 1
        fi
    done
}

# Show usage information
usage() {
    cat <<EOF
Usage:
    ${SCRIPT_NAME} [OPTIONS] USERNAME

    Initialize a new user with sudo privileges on Debian systems.
    Creates the user if not exists, adds to sudo group, and sets a random password.

OPTIONS:
    -h, --help                Show this help message
    --log-level LEVEL         Set log level (ERROR, WARNING, INFO, DEBUG)
                              Default: INFO
    --log-format FORMAT       Set log output format (simple, level, full)
                              simple: message only
                              level:  [LEVEL] message
                              full:   [timestamp][LEVEL] message
                              Default: simple
    --skip-apt-update         Skip APT repository initialization and updates
    --no-password             Do not set password for the user

EXAMPLES:
    ${SCRIPT_NAME} alice
    ${SCRIPT_NAME} --log-level DEBUG bob
    ${SCRIPT_NAME} --skip-apt-update --no-password charlie

REQUIREMENTS:
    - Must be run as root
    - Debian-based system only

EOF
    exit 0
}

# Parse command line arguments
parse_args() {
    local args
    local options="h"
    local longoptions="help,log-level:,log-format:,skip-apt-update,no-password"
    if ! args=$(getopt --options="${options}" --longoptions="${longoptions}" --name="${SCRIPT_NAME}" -- "$@"); then
        usage
    fi

    eval set -- "${args}"
    declare -g -a REST_ARGS=()

    declare -g SKIP_APT_UPDATE=false
    declare -g NO_PASSWORD=false

    while true; do
        case "$1" in
            -h | --help)
                usage
                ;;
            --log-level)
                set_log_level "$2"
                shift 2
                ;;
            --log-format)
                set_log_format "$2"
                shift 2
                ;;
            --skip-apt-update)
                SKIP_APT_UPDATE=true
                shift
                ;;
            --no-password)
                NO_PASSWORD=true
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                log_error "Unexpected option: $1"
                usage
                ;;
        esac
    done

    # Capture remaining positional arguments
    REST_ARGS=("$@")
}

# Prerequisite checks
check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

check_distro() {
    local distro
    distro="$(awk -F= '/^ID=/ {print $2}' /etc/os-release | tr -d '"')"
    if [[ "${distro}" != "debian" ]]; then
        log_error "This script currently only supports Debian (detected: ${distro})"
        exit 1
    fi
    log_debug "Detected distro: ${distro}"
}

# Initialize APT sources
init_apt_sources() {
    local codename
    codename="$(awk -F= '/^VERSION_CODENAME/ {print $2}' /etc/os-release)"
    log_info "Initializing APT sources for ${codename}"

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
    log_debug "APT sources configured for ${codename}"
}

# Install required system packages
install_dependencies() {
    log_info "Updating package list and installing dependencies"
    apt-get update
    apt-get upgrade -y
    apt-get install -y \
        ca-certificates \
        curl \
        debian-archive-keyring \
        gnupg2 \
        lsb-release \
        sudo \
        passwd
    log_info "Dependencies installed successfully"
}

# Configure sudo group and permissions
setup_sudo() {
    log_info "Configuring sudo group"

    if ! getent group sudo >/dev/null; then
        log_debug "Creating 'sudo' group"
        groupadd --system sudo
    else
        log_debug "Group 'sudo' already exists"
    fi

    # Ensure sudoers.d is included
    if ! grep -qE '^\s*@includedir\s+/etc/sudoers\.d' /etc/sudoers; then
        log_debug "Adding @includedir /etc/sudoers.d to /etc/sudoers"
        echo '@includedir /etc/sudoers.d' >>/etc/sudoers
    else
        log_debug "Ensuring /etc/sudoers.d is included"
        sed -i -E 's%^\s*#\s*@includedir\s+/etc/sudoers\.d%@includedir /etc/sudoers.d%' /etc/sudoers
    fi

    # Create sudoers file for the group
    local sudo_file="/etc/sudoers.d/sudo"
    if [[ ! -f "${sudo_file}" ]]; then
        log_debug "Creating sudoers file for group 'sudo' with NOPASSWD"
        echo "%sudo ALL=(ALL) NOPASSWD:ALL" >"${sudo_file}"
        chmod 440 "${sudo_file}"
    else
        log_debug "Sudoers file for group 'sudo' already exists"
    fi

    log_info "Sudo configuration complete"
}

# Create or update user account
create_user() {
    local user="$1"
    log_info "Setting up user '${user}'"

    if ! id "${user}" &>/dev/null; then
        log_debug "Creating user '${user}' and adding to 'sudo' group"
        useradd -m -s /bin/bash -G sudo "${user}"
        log_info "User '${user}' created successfully"
    else
        log_warning "User '${user}' already exists"
        if ! id -nG "${user}" | grep -qw sudo; then
            log_debug "Adding existing user '${user}' to 'sudo' group"
            usermod -aG sudo "${user}"
            log_info "User '${user}' added to sudo group"
        else
            log_debug "User '${user}' is already in 'sudo' group"
        fi
    fi
}

# Set password for user
set_user_password() {
    local user="$1"
    log_info "Setting password for user '${user}'"

    # Generate and set password
    local password
    password=$(openssl rand -base64 12)
    echo "${user}:${password}" | chpasswd --crypt-method SHA512

    # Save password to user's home directory
    local user_home
    user_home=$(getent passwd "${user}" | cut -d: -f6)
    local password_file="${user_home}/.initial_password"

    {
        echo "# Initial password for user: ${user}"
        echo "# Generated: $(date -u +%Y-%m-%dT%H:%M:%S+0000)"
        echo "# Please change this password immediately after first login"
        echo ""
        echo "Username: ${user}"
        echo "Password: ${password}"
    } | tee "${password_file}"

    # Set secure permissions and ownership
    chmod 600 "${password_file}"
    chown "${user}:${user}" "${password_file}"
}

# Main script logic
main() {
    require_command getopt apt-get groupadd useradd usermod chpasswd openssl getent

    parse_args "$@"

    check_root
    check_distro

    if [[ ${#REST_ARGS[@]} -eq 0 ]]; then
        log_error "Username argument is required"
        usage
    fi

    if [[ ${#REST_ARGS[@]} -gt 1 ]]; then
        log_error "Too many arguments provided"
        usage
    fi

    local username="${REST_ARGS[0]}"
    log_debug "Target username: ${username}"

    # Validate username
    if [[ ! "${username}" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        log_error "Invalid username '${username}'. Username must start with a lowercase letter or underscore, followed by lowercase letters, digits, underscores, or hyphens"
        exit 1
    fi

    if [[ "${SKIP_APT_UPDATE}" == false ]]; then
        init_apt_sources
        install_dependencies
    else
        log_info "Skipping APT repository initialization and updates"
    fi

    setup_sudo
    create_user "${username}"

    if [[ "${NO_PASSWORD}" == false ]]; then
        set_user_password "${username}"
    else
        log_info "Skipping password setup for user '${username}'"
    fi

    log_info "Initialization complete for user '${username}'"
}

main "$@"
