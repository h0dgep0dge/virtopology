#!/bin/bash

# Create and destroy buttload of "hosts" and "hubs" to see if I can make it faster

# As of 0d84277abca1352a6086d0e43be236338416e8e0
#real	0m0.386s
#user	0m0.090s
#sys	0m0.053s

#real	0m6.521s
#user	0m0.748s
#sys	0m0.599s

#real	1m4.897s
#user	0m7.429s
#sys	0m5.884s

if [[ -z $1 ]]; then
    time ./stress.sh 1
    time ./stress.sh 10
    time ./stress.sh 100
    exit
fi

for (( c=1; c<=$1; c++ )); do
    ./newHub.sh hub$c
    for i in {1..5}; do
        ./newHost.sh client$i
        ./hostToHub.sh client$i eth0 192.168.0.$i/24 hub$c
    done
    for i in {1..5}; do
        ./delNS.sh client$i
    done
    ./delNS.sh hub$c
done
