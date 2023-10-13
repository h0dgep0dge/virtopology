# virtopology
Create a virtualized network within the linux kernel, for the purpose of network education

# Warranty
None! Provided with absolutely no warranty, guarantee, or mormon tea. You you to run this with root, and it has minimal error checking or even testing. It's a bad idea to run this, only do so on an aboslutely disposable machine.

# Tools

newHub.sh       create a namespace with a bridge

newHost.sh      create an empty namespace

hostToHub.sh    create a veth link between two namespaces, one with a bridge

hostToHost.sh   create a point-to-point veth link between 2 namespaces

addService.sh   start a listener in a namespace
