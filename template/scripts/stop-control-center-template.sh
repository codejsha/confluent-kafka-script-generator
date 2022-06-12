#!/bin/bash

CONFLUENT_HOME=""

PID="$(pgrep -xa java | grep ${CONFLUENT_HOME} | grep "io\.confluent\.controlcenter\.ControlCenter" | awk '{print $1}')"
kill -9 ${PID}
# kill -15 ${PID}
