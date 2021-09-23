#!/bin/bash

CONFLUENT_HOME=""

pssh --hosts=./hosts/replicator.hosts --askpass --inline --timeout=5 --options=StrictHostKeyChecking=no "${SCRIPTS_DIR}/stop.sh"
