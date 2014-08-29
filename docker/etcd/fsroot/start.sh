if [[ "$HOST_IP" = "" ]]
then
  echo "Missing HOST_IP environment variable"
  exit 1
fi
/opt/etcd/bin/etcd -peer-addr=$HOST_IP:$PEER_PORT -addr=$HOST_IP:$ETCD_PORT
