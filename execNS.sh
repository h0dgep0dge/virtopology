#!/bin/bash

usage() {
    cat << EOF
Usage: $0 NAME [-h | --help] \; COMMAND ARGUMENTS

    NAME    The name of the NS in which to execute the command
    --help  Show this message
    \;       Deliminator to indicate start of command
    COMMAND
    ARGUMENTS
EOF
exit 1
}

if [ "$EUID" -ne 0 ]; then
    echo Must be root
    exit
fi

pos_arguments=()
command=()

while [[ -n $1 ]] ; do
    case $1 in
        -h | --help) usage ;;
        ";") shift ; break ;;
        *) pos_arguments+=("$1") ; shift ;;
    esac
done

while [[ -n $1 ]] ; do
    command+=("$1")
    shift
done

name="${pos_arguments[0]}"

if [[ -z $name ]]; then
    usage
fi

nsenter --net="hosts/$name/netns" ${command[@]}
