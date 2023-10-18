#!/bin/bash

usage() {
    cat << EOF
Usage: $0 NAME [-f] [-h | --help]

    NAME    The name of the host to create
    -f      Enable IP forwarding on this host
    --help  Show this message
EOF
exit 1
}

if [ "$EUID" -ne 0 ]; then
    echo Must be root
    exit
fi

pos_arguments=()
forwarding=""

while [[ -n $1 ]] ; do
    case $1 in
        -h | --help) usage ;;
        -f) forwarding="YES"; shift ;;
        *) pos_arguments+=("$1") ; shift ;;
    esac
done

name="${pos_arguments[0]}"

if [[ -z $name ]]; then
    usage
fi

./addNS.sh "$name"
./execNS.sh "$name" \; ip link set lo up

if [[ -n $forwarding ]]; then
    ./execNS.sh "$name" \; sysctl net.ipv4.ip_forward=1
    ./execNS.sh "$name" \; sysctl net.ipv6.conf.all.forwarding=1
fi
