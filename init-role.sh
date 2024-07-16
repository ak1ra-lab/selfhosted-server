#!/bin/sh
# shellcheck shell=dash

main() {
    NAME="$1"
    BASE_DIR="$(readlink -f "$(dirname "$0")")/roles"

    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <role_name>"
        exit 1
    fi

    ansible-galaxy role init "roles/${NAME}"
}

main "$@"
