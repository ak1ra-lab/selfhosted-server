#!/bin/sh
# shellcheck shell=dash

main() {
    NAME=$1
    BASE_DIR="$(readlink -f "$(dirname "$0")")/roles"

    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <role_name>"
        exit 1
    fi

    if [ -d "${BASE_DIR}/${NAME}" ]; then
        code "${BASE_DIR}/${NAME}/tasks/main.yml"
    else
        for DIR in defaults files handlers templates tasks vars; do
            mkdir -p "${BASE_DIR}/${NAME}/${DIR}"
        done
        tree "${BASE_DIR}/${NAME}"
    fi
}

main "$@"
