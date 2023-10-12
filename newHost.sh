#!/bin/bash

usage() {
    cat << EOF
Usage: $0 NAME IP/SUB HUB [-s <port number>] [--gw <ip>] [-h | --help]

    NAME    The name of the host to create
    IP/SUB  The IP address and sn mask to assign to the veth
    HUB     The hub instance this host should talk to
    -s      Port to run a fake service on, add as many as you like
    --gw    Specify a default gateway for this node
    --help  Show this message
EOF
exit 1
}

if [ "$EUID" -ne 0 ]; then
    echo Must be root
    exit
fi

pos_arguments=()
services=()

while [[ -n $1 ]] ; do
    case $1 in
        -h | --help) usage;;
        -s) services+=("$2"); shift 2 ;;
        --gw) gw="$2"; shift 2 ;;
        *) pos_arguments+=("$1") ; shift ;;
    esac
done

name="${pos_arguments[0]}"
ip="${pos_arguments[1]}"
hub="${pos_arguments[2]}"

if [[ -z $name || -z $ip || -z $hub ]]; then
    usage
fi

host_veth=eth0
hub_veth="$name-veth"

ip netns add $name
ip -n "$name" link set lo up

./addLink.sh "$name" "$host_veth" "$ip" "$hub"

for port in "${services[@]}"; do
    ./addService $name $port
done


if [[ -n $gw ]]; then
    ip -n $name route add default via $gw
fi
