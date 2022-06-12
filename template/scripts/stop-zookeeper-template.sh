#!/bin/bash

CONFLUENT_HOME=""

PID="$(pgrep -xa java | grep ${CONFLUENT_HOME} | grep "org\.apache\.zookeeper\.server\.quorum\.QuorumPeerMain" | awk '{print $1}')"
kill -9 ${PID}
# kill -15 ${PID}
