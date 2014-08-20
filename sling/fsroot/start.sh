WARMUP=$1

ETCD=${ETCD_PORT_4001_TCP_ADDR}:${ETCD_PORT_4001_TCP_PORT}
echo Using etcd server $ETCD

MONGO=mongodb://${MONGO_PORT_27017_TCP_ADDR}:${MONGO_PORT_27017_TCP_PORT}
echo Using Mongo server $MONGO

REPO="-Dorg.ops4j.pax.url.mvn.repositories=http://repo1.maven.org/maven2@id=central,http://repository.apache.org/snapshots/@snapshots@id=apache-snapshots"
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
