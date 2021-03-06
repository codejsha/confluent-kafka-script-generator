#!/bin/bash

JAVA_HOME=""
export JAVA_HOME

CONFLUENT_HOME=""
SERVER_NAME=""
PROPERTIES_FILE=""

LOG_DIR=""
export LOG_DIR

######################################################################

### memory options
KAFKAREST_HEAP_OPTS="${KAFKAREST_HEAP_OPTS} -Xms256m -Xmx256m"
export KAFKAREST_HEAP_OPTS

### performance
KAFKAREST_JVM_PERFORMANCE_OPTS="${KAFKAREST_JVM_PERFORMANCE_OPTS} -server"
KAFKAREST_JVM_PERFORMANCE_OPTS="${KAFKAREST_JVM_PERFORMANCE_OPTS} -XX:+UseG1GC"
KAFKAREST_JVM_PERFORMANCE_OPTS="${KAFKAREST_JVM_PERFORMANCE_OPTS} -XX:MaxGCPauseMillis=20"
KAFKAREST_JVM_PERFORMANCE_OPTS="${KAFKAREST_JVM_PERFORMANCE_OPTS} -XX:InitiatingHeapOccupancyPercent=35"
KAFKAREST_JVM_PERFORMANCE_OPTS="${KAFKAREST_JVM_PERFORMANCE_OPTS} -XX:+ExplicitGCInvokesConcurrent"
KAFKAREST_JVM_PERFORMANCE_OPTS="${KAFKAREST_JVM_PERFORMANCE_OPTS} -XX:MaxInlineLevel=15"
KAFKAREST_JVM_PERFORMANCE_OPTS="${KAFKAREST_JVM_PERFORMANCE_OPTS} -Djava.awt.headless=true"
export KAFKAREST_JVM_PERFORMANCE_OPTS

### generic jvm settings
KAFKAREST_OPTS="${KAFKAREST_OPTS} -D${SERVER_NAME}"
# JMX_EXPORTER_JAVA_AGENT_FILE="${CONFLUENT_HOME}/prometheus/jmx_prometheus_javaagent-0.16.1.jar"
# JMX_EXPORTER_CONFIG_FILE="${CONFLUENT_HOME}/prometheus/confluent_rest.yml"
# JMX_EXPORTER_HOST_PORT="1234"
# KAFKAREST_OPTS="${KAFKAREST_OPTS} -javaagent:${JMX_EXPORTER_JAVA_AGENT_FILE}=${JMX_EXPORTER_HOST_PORT}:${JMX_EXPORTER_CONFIG_FILE}"
export KAFKAREST_OPTS

### gc options
# KAFKAREST_OPTS="${KAFKAREST_OPTS} -Xloggc:${LOG_DIR}/${SERVER_NAME}-gc.log"
# KAFKAREST_OPTS="${KAFKAREST_OPTS} -verbose:gc"
# KAFKAREST_OPTS="${KAFKAREST_OPTS} -XX:+PrintGCDetails"
# KAFKAREST_OPTS="${KAFKAREST_OPTS} -XX:+PrintGCDateStamps"
# KAFKAREST_OPTS="${KAFKAREST_OPTS} -XX:+PrintGCTimeStamps"
# KAFKAREST_OPTS="${KAFKAREST_OPTS} -XX:+UseGCLogFileRotation"
# KAFKAREST_OPTS="${KAFKAREST_OPTS} -XX:NumberOfGCLogFiles=10"
# KAFKAREST_OPTS="${KAFKAREST_OPTS} -XX:GCLogFileSize=100M"
# export KAFKAREST_OPTS
# KAFKAREST_OPTS="${KAFKAREST_OPTS} -Xlog:gc*:file=${LOG_DIR}/${SERVER_NAME}-gc.log:time,tags:filecount=10,filesize=100M"
# export KAFKAREST_OPTS

### jmx
KAFKAREST_JMX_OPTS="${KAFKAREST_JMX_OPTS} -Dcom.sun.management.jmxremote"
KAFKAREST_JMX_OPTS="${KAFKAREST_JMX_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"
KAFKAREST_JMX_OPTS="${KAFKAREST_JMX_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
# KAFKAREST_JMX_OPTS="${KAFKAREST_JMX_OPTS} -Dcom.sun.management.jmxremote.port=9010"
export KAFKAREST_JMX_OPTS

### log4j
KAFKAREST_LOG4J_OPTS="${KAFKAREST_LOG4J_OPTS} -Dlog4j.configuration=file:${CONFLUENT_HOME}/log4j/kafka-rest-log4j.properties"
export KAFKAREST_LOG4J_OPTS

######################################################################

######################################################################

### check current user
CURRENT_USER="$(id -un)"
if [ "${CURRENT_USER}" == "root" ]; then
    echo "[ERROR] The current user is root!"
    exit
fi

### check running process
PID="$(pgrep -xa java | grep ${PROPERTIES_FILE} | grep ${SERVER_NAME} | awk '{print $1}')"
if [ -n "${PID}" ]; then
    echo "[ERROR] The ${SERVER_NAME} (pid ${PID}) is already running!"
    exit
fi

### create log directory
if [ ! -d "${LOG_DIR}/backup" ]; then
    mkdir -p ${LOG_DIR}/backup
fi

### backup stdout log
DATETIME="$(date +'%Y%m%d_%H%M%S')"
if [ -f "${LOG_DIR}/nohup.${SERVER_NAME}.out" ]; then
    mv ${LOG_DIR}/nohup.${SERVER_NAME}.out ${LOG_DIR}/backup/nohup.${SERVER_NAME}.${DATETIME}.out
fi

### start
touch ${LOG_DIR}/nohup.${SERVER_NAME}.out
nohup ${CONFLUENT_HOME}/bin/kafka-rest-start ${PROPERTIES_FILE} > ${LOG_DIR}/nohup.${SERVER_NAME}.out 2>&1 &

### tail stdout log
if [ "${1}" == "tail" ]; then
    tail -f ${LOG_DIR}/nohup.${SERVER_NAME}.out
fi
