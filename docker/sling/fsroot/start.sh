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
#
# Here I'm using docker-maven.ddns.net mapped to 10.0.2.2 which is my mac's address
# as seen from the Docker containers.
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

# Create etcd announcer config
MY_IP=$(grep $HOSTNAME /etc/hosts | cut -f1)
cat > /tmp/sling-configs/ch.x42.sling.etcd.EtcdAnnouncer-1.cfg << EOF
etcd.url=http://${ETCD}/v2/keys/http/backends/sling_${HOSTNAME}
sling.host=${MY_IP}
sling.port=80
interval.seconds=10
ttl.seconds=30
EOF

# Create metrics config
cat > /tmp/sling-configs/com.github.digital_wonderland.sling_metrics.reporter.GraphiteReporter.cfg << EOF
graphiteReporter.enabled = true
graphiteReporter.hostname = ${GRAPHITE_PORT_2003_TCP_ADDR}
graphiteReporter.port = ${GRAPHITE_PORT_2003_TCP_PORT}
graphiteReporter.prefix = slingdocker
EOF

echo "Starting sling, warmup=$WARMUP"
java \
  -Dmongo=$MONGO \
  -Dwarmup=$WARMUP \
  -Dorg.ops4j.pax.url.mvn.localRepository=./tmp/maven-repo \
  $REPO \
  -jar /sling/org.apache.sling.crankstart.launcher-1.0.0.jar \
  /sling/crankstart.txt

# Remove the sling id file (created during warmup) to make sure 
# each instance gets a unique ID. 
rm $(find /tmp/SLING-HOME -name sling.id.file)
