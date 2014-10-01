docker-sling-cluster
====================

Experimental Sling/Oak cluster running on Docker. My main goal so far is to create elastic Sling clusters in a simple way for running tests like Sling's integration tests and other more cluster-specific tests on them - on your own laptop.
 
This is using http://www.fig.sh/ to build and start the Docker images. The only real dependency on fig is the fig.yml definition file, which can easily be translated to Docker commands if you don't want to use fig.

To run this on docker with fig:

    setup the environment as shown below
    cd docker
    fig build
    fig up
    

And you can then use `fig scale sling=N` to start N Sling instances which announce themselves to the HAProxy front-end via etcd.

HAProxy make the Sling instances available on port 80, and its own status page on port 81.

environment setup
-----------------
I'm testing this on a mac with boot2docker, different environments might need tweaks.
 
Environment variables that have no value in the fig.yml file must be set before running fig, for now that's

    export HOST_IP=$(boot2docker ip  2>&1 | grep IP  | sed 's/.*: *//') ; echo "[$HOST_IP]"

Or something similar on your environment.

The Sling start.sh script references a Maven repository server on the Docker host (or on
the mac running boot2docker), see sling/fsroot/start.sh for how to set that up.

Any SNAPSHOT dependencies used in sling/fsroot/sling/crankstart.txt must be present in the Maven
repositories that that start.sh file uses.

