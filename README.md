docker-sling-cluster
====================

Experimental Sling/Oak cluster running on Docker.

Using http://www.fig.sh/ to build and start the Docker images.

To run this on docker:

    cd docker
    fig build
    fig up
    
Environment variables that have no value in the fig.yml file
must be set before running fig, like

    export HOST_IP=$(boot2docker ip  2>&1 | grep IP  | sed 's/.*: *//') ; echo "[$HOST_IP]"

I'm testing this on a mac with boot2docker, different environments might need tweaks. 

