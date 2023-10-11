#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo Must be root
    exit
fi

for i in {1..50}; do
    ip netns del "host$i"
done

ip netns del switch