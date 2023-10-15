# virtopology
Create a virtualized network within the linux kernel, for the purpose of network education

# Warranty

None! Provided with absolutely no warranty, guarantee, or mormon tea. You need to run this as root, and it has minimal error checking or even testing. It's a bad idea to run this, only do so on an aboslutely disposable machine.

# Tools

newHub.sh       create a namespace with a bridge

newHost.sh      create an empty namespace

hostToHub.sh    create a veth link between two namespaces, one with a bridge

hostToHost.sh   create a point-to-point veth link between 2 namespaces

addService.sh   start a listener in a namespace

# Examples

## Bus Topology

<img src="topologies/bus.png" alt="drawing" height="200"/>

    ./newHub.sh switch # Create a bridging NS
    ./newHost.sh client1
    ./newHost.sh client2
    ./newHost.sh client3
    ./newHost.sh client4
    ./hostToHub.sh client1 eth0 192.168.0.1/24 switch
    ./hostToHub.sh client2 eth0 192.168.0.2/24 switch
    ./hostToHub.sh client3 eth0 192.168.0.3/24 switch
    ./hostToHub.sh client4 eth0 192.168.0.4/24 switch

## Star topology

<img src="topologies/star.png" alt="drawing" height="200"/>

    ./newHost.sh center
    ./newHost.sh point1
    ./newHost.sh point2
    ./newHost.sh point3
    ./newHost.sh point4
    ./hostToHost.sh point1 192.168.0.2 center 192.168.0.1
    ./hostToHost.sh point2 192.168.0.3 center 192.168.0.1
    ./hostToHost.sh point3 192.168.0.4 center 192.168.0.1
    ./hostToHost.sh point4 192.168.0.5 center 192.168.0.1

## Tree Topology

<img src="topologies/tree.png" alt="drawing" height="200"/>

    ./newHost.sh root
    ./newHost.sh layer1_1
    ./newHost.sh layer1_2

    ./hostToHost.sh root 10.0.0.1 layer1_1 10.1.0.1
    ./hostToHost.sh root 10.0.0.1 layer1_2 10.1.0.2
    
    ./newHost.sh layer2_1
    ./newHost.sh layer2_2
    ./newHost.sh layer2_3

    ./hostToHost.sh layer1_1 10.1.0.1 layer2_1 10.2.0.1
    ./hostToHost.sh layer1_1 10.1.0.1 layer2_2 10.2.0.2
    ./hostToHost.sh layer1_2 10.1.0.2 layer2_3 10.2.1.1

## Bus Topology with nominated router

    ./newHost.sh router
    ./newHub.sh lanSwitch

    ./hostToHub.sh router eth0 192.168.0.250/24 lanSwitch
    
    # create a veth to simulate a wan interface
    ip link add vrouter0 type veth peer wan0
    ip link set wan0 netns router
    
    # bridge the "wan" veth to the physical network (this requires an existing bridge)
    ip link set vrouter0 master br0

    for i in {1..5}; do
        ./newHost.sh client$i
        ./hostToHub.sh client$i eth0 192.168.0.$i/24 lanSwitch

        # set the "router" host as the default gateway for the "clients"
        ip -n client$i route add default via 192.168.0.250
    done

# Credits and Prior Art

Topology Graphics from NetworkTopologies.png: Maksim derivative work: Malyszkz (talk) - NetworkTopologies.png, Public Domain, https://commons.wikimedia.org/w/index.php?curid=15006915

vSDNEmul: A Software-Defined Network Emulator Based on Container Virtualization https://arxiv.org/abs/1908.10980
