#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo Must be root
    exit
fi

./newHub.sh switch

for i in {1..50}; do
    ./newHost.sh "host$i" "10.0.0.$i/24" switch -s $[$RANDOM % 100]
done