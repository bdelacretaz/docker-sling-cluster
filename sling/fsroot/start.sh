ETCD=${ETCD_PORT_4001_TCP_ADDR}:${ETCD_PORT_4001_TCP_PORT}
echo Using etcd server $ETCD

MONGO=mongodb://${MONGO_PORT_27017_TCP_ADDR}:${MONGO_PORT_27017_TCP_PORT}
echo Using Mongo server $MONGO

REPO="-Dorg.ops4j.pax.url.mvn.repositories=http://repo1.maven.org/maven2@id=central,http://repository.apache.org/snapshots/@snapshots@id=apache-snapshots"
echo "Maven repositories: $REPO"

java \
  -Dmongo=$MONGO \
  -Dorg.ops4j.pax.url.mvn.localRepository=./tmp/maven-repo \
  $REPO \
  -jar /sling/org.apache.sling.crankstart.launcher.jar \
  /sling/crankstart.txt
