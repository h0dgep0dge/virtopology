#!/bin/bash

# Create a network namespace, and give it a bridge device
# Acts as an ethernet hub in the network

usage() {
    cat << EOF
Usage: $0 NAME

    NAME    The name of the hub to create
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
        -h | --help) usage;;
        *) pos_arguments+=("$1") ; shift ;;
    esac
done

name="${pos_arguments[0]}"


if [[ -z $name ]]; then
    usage
fi

ip netns add "$name"
ip -n "$name" link add br0 type bridge
ip -n "$name" link set br0 up
