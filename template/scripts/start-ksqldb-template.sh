#!/bin/bash

JAVA_HOME=""
export JAVA_HOME

CONFLUENT_HOME=""
SERVER_NAME=""
PROPERTIES_FILE=""

DATA_DIR=""
LOG_DIR=""
export LOG_DIR

######################################################################

### memory options
KSQL_HEAP_OPTS="${KSQL_HEAP_OPTS} -Xms3g -Xmx3g"
export KSQL_HEAP_OPTS

### performance
KSQL_JVM_PERFORMANCE_OPTS="${KSQL_JVM_PERFORMANCE_OPTS} -server"
# KSQL_JVM_PERFORMANCE_OPTS="${KSQL_JVM_PERFORMANCE_OPTS} -XX:+UseG1GC"
# KSQL_JVM_PERFORMANCE_OPTS="${KSQL_JVM_PERFORMANCE_OPTS} -XX:MaxGCPauseMillis=20"
# KSQL_JVM_PERFORMANCE_OPTS="${KSQL_JVM_PERFORMANCE_OPTS} -XX:InitiatingHeapOccupancyPercent=35"
# KSQL_JVM_PERFORMANCE_OPTS="${KSQL_JVM_PERFORMANCE_OPTS} -XX:+ExplicitGCInvokesConcurrent"
KSQL_JVM_PERFORMANCE_OPTS="${KSQL_JVM_PERFORMANCE_OPTS} -XX:+UseConcMarkSweepGC"
KSQL_JVM_PERFORMANCE_OPTS="${KSQL_JVM_PERFORMANCE_OPTS} -XX:+CMSClassUnloadingEnabled"
KSQL_JVM_PERFORMANCE_OPTS="${KSQL_JVM_PERFORMANCE_OPTS} -XX:+CMSScavengeBeforeRemark"
KSQL_JVM_PERFORMANCE_OPTS="${KSQL_JVM_PERFORMANCE_OPTS} -XX:+DisableExplicitGC"
KSQL_JVM_PERFORMANCE_OPTS="${KSQL_JVM_PERFORMANCE_OPTS} -XX:MaxInlineLevel=15"
KSQL_JVM_PERFORMANCE_OPTS="${KSQL_JVM_PERFORMANCE_OPTS} -Djava.awt.headless=true"
export KSQL_JVM_PERFORMANCE_OPTS

### generic jvm settings
KSQL_OPTS="${KSQL_OPTS} -D${SERVER_NAME}"
# JMX_EXPORTER_JAVA_AGENT_FILE="${CONFLUENT_HOME}/prometheus/jmx_prometheus_javaagent-0.16.1.jar"
# JMX_EXPORTER_CONFIG_FILE="${CONFLUENT_HOME}/prometheus/confluent_ksql.yml"
# JMX_EXPORTER_HOST_PORT="1234"
# KSQL_OPTS="${KSQL_OPTS} -javaagent:${JMX_EXPORTER_JAVA_AGENT_FILE}=${JMX_EXPORTER_HOST_PORT}:${JMX_EXPORTER_CONFIG_FILE}"
export KSQL_OPTS

### gc options
KSQL_GC_LOG_OPTS="${KSQL_GC_LOG_OPTS} -Xloggc:${LOG_DIR}/${SERVER_NAME}-gc.log"
KSQL_GC_LOG_OPTS="${KSQL_GC_LOG_OPTS} -verbose:gc"
KSQL_GC_LOG_OPTS="${KSQL_GC_LOG_OPTS} -XX:+PrintGCDetails"
KSQL_GC_LOG_OPTS="${KSQL_GC_LOG_OPTS} -XX:+PrintGCDateStamps"
KSQL_GC_LOG_OPTS="${KSQL_GC_LOG_OPTS} -XX:+PrintGCTimeStamps"
KSQL_GC_LOG_OPTS="${KSQL_GC_LOG_OPTS} -XX:+UseGCLogFileRotation"
KSQL_GC_LOG_OPTS="${KSQL_GC_LOG_OPTS} -XX:NumberOfGCLogFiles=10"
KSQL_GC_LOG_OPTS="${KSQL_GC_LOG_OPTS} -XX:GCLogFileSize=100M"
export KSQL_GC_LOG_OPTS
# KSQL_GC_LOG_OPTS="${KSQL_GC_LOG_OPTS} -Xlog:gc*:file=${LOG_DIR}/${SERVER_NAME}-gc.log:time,tags:filecount=10,filesize=100M"
# export KSQL_GC_LOG_OPTS

### jmx
KSQL_JMX_OPTS="${KSQL_JMX_OPTS} -Dcom.sun.management.jmxremote"
KSQL_JMX_OPTS="${KSQL_JMX_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"
KSQL_JMX_OPTS="${KSQL_JMX_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
# KSQL_JMX_OPTS="${KSQL_JMX_OPTS} -Dcom.sun.management.jmxremote.port=9010"
export KSQL_JMX_OPTS

### log4j
KSQL_LOG4J_OPTS="${KSQL_LOG4J_OPTS} -Dlog4j.configuration=file:${CONFLUENT_HOME}/log4j/ksqldb-log4j.properties"
export KSQL_LOG4J_OPTS

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

### create data and log directories
if [ ! -d "${DATA_DIR}" ]; then
    mkdir -p ${DATA_DIR}
fi
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
nohup ${CONFLUENT_HOME}/bin/ksql-server-start ${PROPERTIES_FILE} > ${LOG_DIR}/nohup.${SERVER_NAME}.out 2>&1 &

### tail stdout log
if [ "${1}" == "tail" ]; then
    tail -f ${LOG_DIR}/nohup.${SERVER_NAME}.out
fi
