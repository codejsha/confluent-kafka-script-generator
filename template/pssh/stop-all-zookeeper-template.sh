#!/bin/bash

CONFLUENT_HOME=""

pssh --hosts=./hosts/zookeeper.hosts --askpass --inline --timeout=5 --options=StrictHostKeyChecking=no "${SCRIPTS_DIR}/stop.sh"
