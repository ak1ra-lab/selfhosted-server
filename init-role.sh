#! /bin/bash

NAME=$1
BASE_DIR=$(readlink -f $(dirname "$0"))/roles

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <role_name>"
    exit 1
fi

if [[ -d $BASE_DIR/$NAME ]]; then
    code $BASE_DIR/$NAME/tasks/main.yml
else
    mkdir -p $BASE_DIR/$NAME/{files,handlers,templates,tasks,vars}
    tree $BASE_DIR/$NAME
fi

exit 0
