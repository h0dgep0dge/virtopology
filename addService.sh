#!/bin/bash

usage() {
    cat << EOF
Usage: $0 NAME PORT [-c <command>] [-h | --help]

    NAME    The name of the host to which to add a service
    PORT    The port to assign to the service
    -c      A command string to pass to ncat, default is cat
    --help  Show this message
EOF
exit 1
}

if [ "$EUID" -ne 0 ]; then
    echo Must be root
    exit
fi

command=""
pos_arguments=()

while [[ -n $1 ]] ; do
    case $1 in
        -h | --help) usage ;;
        -c) command="$1"; shift 2 ;;
        *) pos_arguments+=("$1") ; shift ;;
    esac
done

name="${pos_arguments[0]}"
port="${pos_arguments[1]}"

if [[ -z $name || -z $port ]]; then
    usage
fi

if [[ -z $command ]]; then
    command=cat
fi

./execNS.sh "$name" \; ncat -kl "$port" -c "$command" &
