docker-sling-cluster
====================

_Note that I have not touched this prototype since October 2014, it might need some adjustments to run in a recent Docker environment. https://docs.docker.com/compose/ now replaces Fig, for example_.

Experimental Sling/Oak cluster running on Docker. My main goal so far is to create elastic Sling clusters in a simple way, as
a playground for making Sling more operations-friendly.

See also my http://www.slideshare.net/bdelacretaz/modern-operations-with-apache-sling-2014-adaptto-version slides for additional information.
 
This is using http://www.fig.sh/ to build and start the Docker images. The only real dependency on fig is the `fig.yml` 
definition file, which can easily be translated to Docker commands if you don't want to use fig.

A Vagrant box is provided which should keep setup to the minimum, so you can just get https://www.vagrantup.com/ 
(I'm currently using 1.6.2) and you should be good, see instructions below. 

If you already have a Docker environment with Fig you can start the cluster as follows:

    export HOST_IP=(public IP of your Docker host)
    cd docker
    fig build
    fig up
    
In both cases you can then use `fig scale sling=N` to start N Sling instances which announce themselves to the HAProxy 
front-end via etcd. To check that HAProxy is actually using several Sling instances as its back-end you can use

    export HOST_IP=(public IP of your Docker host)
    export PORT=80
    for i in 1 2 3 4 5 6 7 8 9 0
    do 
      curl -s -u admin:admin http://$HOST_IP:$PORT/system/console/status-slingsettings.json | grep Name
    done | sort -u
    
This should display something like (here with 3 Sling instances up):

    "Sling Name = Instance 88461e68-91ef-495f-9d38-0746c48bf9e8",
    "Sling Name = Instance d9a10ec2-2d6d-4a22-97ad-42c33c6242da",
    "Sling Name = Instance fcba04db-1a00-4c0d-99bb-55d7790ea9c6",
    
Which shows that you are hitting 3 different Sling instances, each with their own instance ID.

If using the Vagrant box `HOST_IP` is the host that's running Vagrant, and `PORT` is 9080 as exposed in the Vagrantfile.

The following ports (81, 82 or 9081, 9082) expose the HAProxy and Graphite status pages, respectively. Graphite is not getting
stats from the Sling instances as I write this, for some reason.
    
Using the supplied Vagrant box
------------------------------

Note that this might Download The Web (TM) on first startup, using many fine ways of doing that:
downloading a Vagrant image, building Java modules with Maven starting on an empty local repository, and
getting the required Docker images which are not optimized so far.   

Should you accept doing that, install Vagrant 1.6.2 or later and run this from the folder that contains the Vagrantfile:

    vagrant up
    vagrant ssh
    
    # You're in a dark and scary Vagrant box now. Inception starts.
    sudo bash
    cd /dsc/docker
    export HOST_IP=$(ifconfig eth0 | grep "inet addr" | cut -d: -f2- | cut -d' ' -f1)
    fig build
    fig up
    
You can then open another `vagrant ssh` session to use `fig ps` or other fig commands to see details 
of what's happening, or use `fig scale sling=N` to start more Sling instances.     

Trouble at Mongo startup
------------------------
Brutally stopping the mongo Docker box might prevent it from restarting, if that happens see 
http://docs.mongodb.org/manual/tutorial/recover-data-following-unexpected-shutdown/ for how to fix it.

The Mongo data is stored on the Vagrant box, the following works for me (but it's kinda brute force):

Use `find / -name mongod.lock` to find that lock file.

Use `> full_path_of/mongod.lock` to make it zero length.

Restart the Mongo box with `fig up mongo` (requires restarting the Sling boxes), or restart the whole cluster with
`fig up` if you stopped everything.
