#!/bin/bash

pssh \
    --hosts=./hosts/zookeeper.hosts \
    --hosts=./hosts/kafka.hosts \
    --hosts=./hosts/schema-registry.hosts \
    --hosts=./hosts/kafka-connect.hosts \
    --hosts=./hosts/replicator.hosts \
    --hosts=./hosts/kafka-rest.hosts \
    --hosts=./hosts/ksqldb.hosts \
    --hosts=./hosts/control-center.hosts \
    --askpass \
    --inline \
    --timeout=5 \
    --options=StrictHostKeyChecking=no \
    "pkill -9 -ecx java"
