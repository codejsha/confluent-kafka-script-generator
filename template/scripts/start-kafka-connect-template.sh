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
KAFKA_HEAP_OPTS="${KAFKA_HEAP_OPTS} -Xms2g -Xmx2g"
export KAFKA_HEAP_OPTS

### performance
KAFKA_JVM_PERFORMANCE_OPTS="${KAFKA_JVM_PERFORMANCE_OPTS} -server"
KAFKA_JVM_PERFORMANCE_OPTS="${KAFKA_JVM_PERFORMANCE_OPTS} -XX:+UseG1GC"
KAFKA_JVM_PERFORMANCE_OPTS="${KAFKA_JVM_PERFORMANCE_OPTS} -XX:MaxGCPauseMillis=20"
KAFKA_JVM_PERFORMANCE_OPTS="${KAFKA_JVM_PERFORMANCE_OPTS} -XX:InitiatingHeapOccupancyPercent=35"
KAFKA_JVM_PERFORMANCE_OPTS="${KAFKA_JVM_PERFORMANCE_OPTS} -XX:+ExplicitGCInvokesConcurrent"
KAFKA_JVM_PERFORMANCE_OPTS="${KAFKA_JVM_PERFORMANCE_OPTS} -XX:MaxInlineLevel=15"
KAFKA_JVM_PERFORMANCE_OPTS="${KAFKA_JVM_PERFORMANCE_OPTS} -Djava.awt.headless=true"
export KAFKA_JVM_PERFORMANCE_OPTS

### generic jvm settings
KAFKA_OPTS="${KAFKA_OPTS} -D${SERVER_NAME}"
# JMX_EXPORTER_JAVA_AGENT_FILE="${CONFLUENT_HOME}/prometheus/jmx_prometheus_javaagent-0.16.1.jar"
# JMX_EXPORTER_CONFIG_FILE="${CONFLUENT_HOME}/prometheus/kafka_connect.yml"
# JMX_EXPORTER_HOST_PORT="1234"
# KAFKA_OPTS="${KAFKA_OPTS} -javaagent:${JMX_EXPORTER_JAVA_AGENT_FILE}=${JMX_EXPORTER_HOST_PORT}:${JMX_EXPORTER_CONFIG_FILE}"
export KAFKA_OPTS

### gc options
KAFKA_GC_LOG_OPTS="${KAFKA_GC_LOG_OPTS} -Xloggc:${LOG_DIR}/${SERVER_NAME}-gc.log"
KAFKA_GC_LOG_OPTS="${KAFKA_GC_LOG_OPTS} -verbose:gc"
KAFKA_GC_LOG_OPTS="${KAFKA_GC_LOG_OPTS} -XX:+PrintGCDetails"
KAFKA_GC_LOG_OPTS="${KAFKA_GC_LOG_OPTS} -XX:+PrintGCDateStamps"
KAFKA_GC_LOG_OPTS="${KAFKA_GC_LOG_OPTS} -XX:+PrintGCTimeStamps"
KAFKA_GC_LOG_OPTS="${KAFKA_GC_LOG_OPTS} -XX:+UseGCLogFileRotation"
KAFKA_GC_LOG_OPTS="${KAFKA_GC_LOG_OPTS} -XX:NumberOfGCLogFiles=10"
KAFKA_GC_LOG_OPTS="${KAFKA_GC_LOG_OPTS} -XX:GCLogFileSize=100M"
export KAFKA_GC_LOG_OPTS
# KAFKA_GC_LOG_OPTS="${KAFKA_GC_LOG_OPTS} -Xlog:gc*:file=${LOG_DIR}/${SERVER_NAME}-gc.log:time,tags:filecount=10,filesize=100M"
# export KAFKA_GC_LOG_OPTS

### jmx
KAFKA_JMX_OPTS="${KAFKA_JMX_OPTS} -Dcom.sun.management.jmxremote"
KAFKA_JMX_OPTS="${KAFKA_JMX_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"
KAFKA_JMX_OPTS="${KAFKA_JMX_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
# KAFKA_JMX_OPTS="${KAFKA_JMX_OPTS} -Dcom.sun.management.jmxremote.port=9010"
export KAFKA_JMX_OPTS

### log4j
KAFKA_LOG4J_OPTS="${KAFKA_LOG4J_OPTS} -Dlog4j.configuration=file:${CONFLUENT_HOME}/log4j/kafka-connect-log4j.properties"
export KAFKA_LOG4J_OPTS

######################################################################

### classpath
CLASSPATH="${CLASSPATH}:${CONFLUENT_HOME}/share/java/kafka-connect-replicator/*"
export CLASSPATH

### aws credentials
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""

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
# nohup ${CONFLUENT_HOME}/bin/connect-standalone ${PROPERTIES_FILE} > ${LOG_DIR}/nohup.${SERVER_NAME}.out 2>&1 &
nohup ${CONFLUENT_HOME}/bin/connect-distributed ${PROPERTIES_FILE} > ${LOG_DIR}/nohup.${SERVER_NAME}.out 2>&1 &

### tail stdout log
if [ "${1}" == "tail" ]; then
    tail -f ${LOG_DIR}/nohup.${SERVER_NAME}.out
fi
