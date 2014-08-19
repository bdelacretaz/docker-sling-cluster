service haproxy start

ETCD=${ETCD_PORT_4001_TCP_ADDR}:${ETCD_PORT_4001_TCP_PORT}
if [ -z "$ETCD" ]
then
  echo "ERROR: missing ETCD environment variables"
  exit 1
fi
echo Using etcd server $ETCD
confd -interval 1 -node $ETCD
