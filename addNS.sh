#!/bin/bash

usage() {
    cat << EOF
Usage: $0 NAME [-h | --help]

    NAME    The name of the host to create
    --help  Show this message
EOF
exit 1
}

if [ "$EUID" -ne 0 ]; then
    echo Must be root
    exit
fi

pos_arguments=()

while [[ -n $1 ]] ; do
    case $1 in
        -h | --help) usage ;;
        *) pos_arguments+=("$1") ; shift ;;
    esac
done

name="${pos_arguments[0]}"

if [[ -z $name ]]; then
    usage
fi

ip netns add "$name"
