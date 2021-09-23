#!/bin/bash

CONFLUENT_HOME=""

pssh --hosts=./hosts/kafka.hosts --askpass --inline --timeout=5 --options=StrictHostKeyChecking=no "${SCRIPTS_DIR}/start.sh"
