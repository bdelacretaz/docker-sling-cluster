docker-sling-cluster
====================

Experimental Sling/Oak cluster running on Docker. My main goal so far is to create elastic Sling clusters in a simple way for running tests like Sling's integration tests and other more cluster-specific tests on them.
 
This is using http://www.fig.sh/ to build and start the Docker images. The only real dependency on fig is the fig.yml definition file, which can easily be translated to Docker commands if you don't want to use fig.

To run this on docker with fig:

    cd docker
    fig build
    fig up
    

See comments in fig.yml for any special setup that might be required.

In particular, environment variables that have no value in the fig.yml file
must be set before running fig, like

    export HOST_IP=$(boot2docker ip  2>&1 | grep IP  | sed 's/.*: *//') ; echo "[$HOST_IP]"

I'm testing this on a mac with boot2docker, different environments might need tweaks. 

