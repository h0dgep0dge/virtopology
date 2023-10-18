#!/bin/bash

usage() {
    cat << EOF
Usage: $0 HOST VETH IP/SUB HUB [-h | --help]

    NAME    The name of the host to link
    VETH    The name of the veth on the host
    IP/SUB  The IP address and sn mask to assign to the veth
    HUB     The hub to which to link the host
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
        -h | --help) usage;;
        *) pos_arguments+=("$1") ; shift ;;
    esac
done

name="${pos_arguments[0]}"
host_veth="${pos_arguments[1]}"
ip="${pos_arguments[2]}"
hub="${pos_arguments[3]}"
hub_veth="$name-veth"

if [[ -z $name || -z $host_veth || -z $ip || -z $hub ]]; then
    usage
fi


./execNS.sh "$name" \; ip link add "$host_veth" type veth peer name "$hub_veth"
./execNS.sh "$name" \; ip link set "$hub_veth" netns "hosts/$hub/netns"
./execNS.sh "$hub" \;  ip link set "$hub_veth" master br0
./execNS.sh "$hub" \;  ip link set "$hub_veth" up

./execNS.sh "$name" \; ip link set "$host_veth" up
./execNS.sh "$name" \; ip addr add "$ip" dev "$host_veth"
