#!/bin/bash
# update haproxy config from confd output
# and reload the service only if the sorted
# output has changed
BASE=/etc/haproxy/haproxy-base.cfg
IN=/etc/haproxy/haproxy-from-confd.cfg
OUT=/etc/haproxy/haproxy.cfg
SORTED=/tmp/sorted.cfg
OLD=/tmp/old.cfg

function update() {
  echo "Updating $OUT and reloading haproxy"
  cat $BASE $SORTED > $OUT
  cp $SORTED $OLD
  service haproxy reload
  exit 0
}

# Sort confd output 
sort < $IN > $SORTED

# Update if no old file
[[ -f $OLD ]] || update

# Update if any changes
diff $SORTED $OLD
[[ $? -eq 1 ]] && update

echo "No changes in $IN once sorted, haproxy won't be reloaded"
