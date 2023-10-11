#!/bin/bash

# This is the first script I wrote, after doing a proof-of-concept by hand

HUB_NAMESPACE=switch

ip netns add $HUB_NAMESPACE
ip -n $HUB_NAMESPACE link add br0 type bridge
ip -n $HUB_NAMESPACE link set br0 up

ip link add veth0 type veth peer name router
ip link set router netns $HUB_NAMESPACE
ip -n $HUB_NAMESPACE link set router master br0
ip -n $HUB_NAMESPACE link set router up
ip link set veth0 up
ip addr add 10.0.0.254/24 dev veth0

for i in {1..10}; do
    NAMESPACE=server$i
    SERVER_VETH=eth0
    HUB_VETH=veth$i
    ADDR=10.0.0.$i/24
    
    ip netns add $NAMESPACE
    ip -n $NAMESPACE link add $SERVER_VETH type veth peer name $HUB_VETH
    ip -n $NAMESPACE link set $HUB_VETH netns $HUB_NAMESPACE
    ip -n $HUB_NAMESPACE link set $HUB_VETH master br0
    ip -n $HUB_NAMESPACE link set $HUB_VETH up

    ip -n $NAMESPACE link set lo up
    ip -n $NAMESPACE link set $SERVER_VETH up

    ip -n $NAMESPACE addr add $ADDR dev $SERVER_VETH
    
    ip -n $NAMESPACE route add default via 10.0.0.254
done
