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
SCHEMA_REGISTRY_HEAP_OPTS="${SCHEMA_REGISTRY_HEAP_OPTS} -Xms512m -Xmx512m"
export SCHEMA_REGISTRY_HEAP_OPTS

### performance
SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS="${SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS} -server"
SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS="${SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS} -XX:+UseG1GC"
SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS="${SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS} -XX:MaxGCPauseMillis=20"
SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS="${SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS} -XX:InitiatingHeapOccupancyPercent=35"
SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS="${SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS} -XX:+ExplicitGCInvokesConcurrent"
SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS="${SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS} -XX:MaxInlineLevel=15"
SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS="${SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS} -Djava.awt.headless=true"
export SCHEMA_REGISTRY_JVM_PERFORMANCE_OPTS

### generic jvm settings
SCHEMA_REGISTRY_OPTS="${SCHEMA_REGISTRY_OPTS} -D${SERVER_NAME}"
# JMX_EXPORTER_JAVA_AGENT_FILE="${CONFLUENT_HOME}/prometheus/jmx_prometheus_javaagent-0.16.1.jar"
# JMX_EXPORTER_CONFIG_FILE="${CONFLUENT_HOME}/prometheus/confluent_schemaregistry.yml"
# JMX_EXPORTER_HOST_PORT="1234"
# SCHEMA_REGISTRY_OPTS="${SCHEMA_REGISTRY_OPTS} -javaagent:${JMX_EXPORTER_JAVA_AGENT_FILE}=${JMX_EXPORTER_HOST_PORT}:${JMX_EXPORTER_CONFIG_FILE}"
export SCHEMA_REGISTRY_OPTS

### gc options
SCHEMA_REGISTRY_GC_LOG_OPTS="${SCHEMA_REGISTRY_GC_LOG_OPTS} -Xloggc:${LOG_DIR}/${SERVER_NAME}-gc.log"
SCHEMA_REGISTRY_GC_LOG_OPTS="${SCHEMA_REGISTRY_GC_LOG_OPTS} -verbose:gc"
SCHEMA_REGISTRY_GC_LOG_OPTS="${SCHEMA_REGISTRY_GC_LOG_OPTS} -XX:+PrintGCDetails"
SCHEMA_REGISTRY_GC_LOG_OPTS="${SCHEMA_REGISTRY_GC_LOG_OPTS} -XX:+PrintGCDateStamps"
SCHEMA_REGISTRY_GC_LOG_OPTS="${SCHEMA_REGISTRY_GC_LOG_OPTS} -XX:+PrintGCTimeStamps"
SCHEMA_REGISTRY_GC_LOG_OPTS="${SCHEMA_REGISTRY_GC_LOG_OPTS} -XX:+UseGCLogFileRotation"
SCHEMA_REGISTRY_GC_LOG_OPTS="${SCHEMA_REGISTRY_GC_LOG_OPTS} -XX:NumberOfGCLogFiles=10"
SCHEMA_REGISTRY_GC_LOG_OPTS="${SCHEMA_REGISTRY_GC_LOG_OPTS} -XX:GCLogFileSize=100M"
export SCHEMA_REGISTRY_GC_LOG_OPTS
# SCHEMA_REGISTRY_GC_LOG_OPTS="${SCHEMA_REGISTRY_GC_LOG_OPTS} -Xlog:gc*:file=${LOG_DIR}/${SERVER_NAME}-gc.log:time,tags:filecount=10,filesize=100M"
# export SCHEMA_REGISTRY_GC_LOG_OPTS

### jmx
SCHEMA_REGISTRY_JMX_OPTS="${SCHEMA_REGISTRY_JMX_OPTS} -Dcom.sun.management.jmxremote"
SCHEMA_REGISTRY_JMX_OPTS="${SCHEMA_REGISTRY_JMX_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"
SCHEMA_REGISTRY_JMX_OPTS="${SCHEMA_REGISTRY_JMX_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
# SCHEMA_REGISTRY_JMX_OPTS="${SCHEMA_REGISTRY_JMX_OPTS} -Dcom.sun.management.jmxremote.port=9010"
export SCHEMA_REGISTRY_JMX_OPTS

### log4j
SCHEMA_REGISTRY_LOG4J_OPTS="${SCHEMA_REGISTRY_LOG4J_OPTS} -Dlog4j.configuration=file:${CONFLUENT_HOME}/log4j/schema-registry-log4j.properties"
export SCHEMA_REGISTRY_LOG4J_OPTS

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
nohup ${CONFLUENT_HOME}/bin/schema-registry-start ${PROPERTIES_FILE} > ${LOG_DIR}/nohup.${SERVER_NAME}.out 2>&1 &

### tail stdout log
if [ "${1}" == "tail" ]; then
    tail -f ${LOG_DIR}/nohup.${SERVER_NAME}.out
fi
