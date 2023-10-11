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
ip -n $name link add $host_veth type veth peer name $hub_veth
ip -n $name link set $hub_veth netns $hub
ip -n $hub link set $hub_veth master br0
ip -n $hub link set $hub_veth up

ip -n $name link set lo up
ip -n $name link set $host_veth up
ip -n $name addr add $ip dev $host_veth

for port in "${services[@]}"; do
    ip netns exec $name ncat -kl $port -c cat &
done


if [[ -n $gw ]]; then
    ip -n $name route add default via $gw
fi