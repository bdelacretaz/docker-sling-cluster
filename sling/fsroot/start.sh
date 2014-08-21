WARMUP=$1

ETCD=${ETCD_PORT_4001_TCP_ADDR}:${ETCD_PORT_4001_TCP_PORT}
echo Using etcd server $ETCD

MONGO=mongodb://${MONGO_PORT_27017_TCP_ADDR}:${MONGO_PORT_27017_TCP_PORT}
echo Using Mongo server $MONGO

# This can be used if you don’t need local snapshots
# REPO="-Dorg.ops4j.pax.url.mvn.repositories=http://repo1.maven.org/maven2@id=central,http://repository.apache.org/snapshots/@snapshots@id=apache-snapshots"

# Use this with a suitable host name or IP to point to the Maven repository
# of the host running Docker, or mac host running boot2docker. That’s a faster
# way of getting Maven artifacts, and includes snapshots built locally on that host.
# You can run a simple HTTP server (like python -m SimpleHTTPServer) on your host’s
# $HOME/.m2/repository to make it available on the below URL.
REPO_HOST=docker-maven.ddns.net
REPO_PORT=8000
REPO=-Dorg.ops4j.pax.url.mvn.repositories=http://$REPO_HOST:$REPO_PORT/@snapshots@id=dockerHost

echo "Maven repositories: $REPO"

# Create Mongo config from environment variables
mkdir -p /tmp/sling-configs
cat > /tmp/sling-configs/org.apache.jackrabbit.oak.plugins.document.DocumentNodeStoreService.cfg << EOF
mongouri=$MONGO
db=sling
EOF

echo "Starting sling, warmup=$WARMUP"
java \
  -Dmongo=$MONGO \
  -Dwarmup=$WARMUP \
  -Dorg.ops4j.pax.url.mvn.localRepository=./tmp/maven-repo \
  $REPO \
  -jar /sling/org.apache.sling.crankstart.launcher.jar \
  /sling/crankstart.txt

# Remove the sling id file (created during warmup) to make sure 
# each instance gets a unique ID. 
rm $(find /tmp/SLING-HOME -name sling.id.file)
