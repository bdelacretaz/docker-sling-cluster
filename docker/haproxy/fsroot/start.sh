service haproxy start

ETCD=${ETCD_PORT_4001_TCP_ADDR}:${ETCD_PORT_4001_TCP_PORT}
if [ "$ETCD" = “:” ]
then
  echo "ERROR: missing ETCD environment variables"
  exit 1
fi

echo Using etcd server $ETCD
confd -node $ETCD -interval $CONFD_INTERVAL
