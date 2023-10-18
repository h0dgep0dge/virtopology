#!/bin/bash

usage() {
    cat << EOF
Usage: $0 HOST_A IP_A HOST_B IP_B [-h | --help]

    NAME_A  The name of the first host
    IP_A    The IP address to assign to NAME_A
    NAME_B  The name of the second host
    IP_B    The IP address to assign to IP_B
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

name_a="${pos_arguments[0]}"
ip_a="${pos_arguments[1]}"
name_b="${pos_arguments[2]}"
ip_b="${pos_arguments[3]}"

veth_a="$name_a-$name_b"
veth_b="$name_b-$name_a"

if [[ -z $name_a || -z $ip_a || -z $name_b || -z $ip_b ]]; then
    usage
fi


./execNS.sh "$name_a" \; ip link add "$veth_a" type veth peer name "$veth_b"
./execNS.sh "$name_a" \; ip link set "$veth_b" netns "$name_b"

./execNS.sh "$name_a" \; ip addr add "$ip_a/32" peer "$ip_b/32" dev "$veth_a"
./execNS.sh "$name_a" \; ip link set "$veth_a" up

./execNS.sh "$name_b" \; ip addr add "$ip_b/32" peer "$ip_a/32" dev "$veth_b"
./execNS.sh "$name_b" \; ip link set "$veth_b" up
