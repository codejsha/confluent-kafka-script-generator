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
CONTROL_CENTER_HEAP_OPTS="${CONTROL_CENTER_HEAP_OPTS} -Xms6g -Xmx6g"
export CONTROL_CENTER_HEAP_OPTS

### performance
CONTROL_CENTER_JVM_PERFORMANCE_OPTS="${CONTROL_CENTER_JVM_PERFORMANCE_OPTS} -server"
# CONTROL_CENTER_JVM_PERFORMANCE_OPTS="${CONTROL_CENTER_JVM_PERFORMANCE_OPTS} -XX:+UseG1GC"
# CONTROL_CENTER_JVM_PERFORMANCE_OPTS="${CONTROL_CENTER_JVM_PERFORMANCE_OPTS} -XX:MaxGCPauseMillis=20"
# CONTROL_CENTER_JVM_PERFORMANCE_OPTS="${CONTROL_CENTER_JVM_PERFORMANCE_OPTS} -XX:InitiatingHeapOccupancyPercent=35"
# CONTROL_CENTER_JVM_PERFORMANCE_OPTS="${CONTROL_CENTER_JVM_PERFORMANCE_OPTS} -XX:+ExplicitGCInvokesConcurrent"
CONTROL_CENTER_JVM_PERFORMANCE_OPTS="${CONTROL_CENTER_JVM_PERFORMANCE_OPTS} -XX:+UseConcMarkSweepGC"
CONTROL_CENTER_JVM_PERFORMANCE_OPTS="${CONTROL_CENTER_JVM_PERFORMANCE_OPTS} -XX:+CMSClassUnloadingEnabled"
CONTROL_CENTER_JVM_PERFORMANCE_OPTS="${CONTROL_CENTER_JVM_PERFORMANCE_OPTS} -XX:+CMSScavengeBeforeRemark"
CONTROL_CENTER_JVM_PERFORMANCE_OPTS="${CONTROL_CENTER_JVM_PERFORMANCE_OPTS} -XX:+DisableExplicitGC"
CONTROL_CENTER_JVM_PERFORMANCE_OPTS="${CONTROL_CENTER_JVM_PERFORMANCE_OPTS} -XX:MaxInlineLevel=15"
CONTROL_CENTER_JVM_PERFORMANCE_OPTS="${CONTROL_CENTER_JVM_PERFORMANCE_OPTS} -Djava.awt.headless=true"
export CONTROL_CENTER_JVM_PERFORMANCE_OPTS

### generic jvm settings
CONTROL_CENTER_OPTS="${CONTROL_CENTER_OPTS} -D${SERVER_NAME}"
export CONTROL_CENTER_OPTS

### gc options
# CONTROL_CENTER_OPTS="${CONTROL_CENTER_OPTS} -Xloggc:${LOG_DIR}/${SERVER_NAME}-gc.log"
# CONTROL_CENTER_OPTS="${CONTROL_CENTER_OPTS} -verbose:gc"
# CONTROL_CENTER_OPTS="${CONTROL_CENTER_OPTS} -XX:+PrintGCDetails"
# CONTROL_CENTER_OPTS="${CONTROL_CENTER_OPTS} -XX:+PrintGCDateStamps"
# CONTROL_CENTER_OPTS="${CONTROL_CENTER_OPTS} -XX:+PrintGCTimeStamps"
# CONTROL_CENTER_OPTS="${CONTROL_CENTER_OPTS} -XX:+UseGCLogFileRotation"
# CONTROL_CENTER_OPTS="${CONTROL_CENTER_OPTS} -XX:NumberOfGCLogFiles=10"
# CONTROL_CENTER_OPTS="${CONTROL_CENTER_OPTS} -XX:GCLogFileSize=100M"
# export CONTROL_CENTER_OPTS
# CONTROL_CENTER_OPTS="${CONTROL_CENTER_OPTS} -Xlog:gc*:file=${LOG_DIR}/${SERVER_NAME}-gc.log:time,tags:filecount=10,filesize=100M"
# export CONTROL_CENTER_OPTS

### jmx
CONTROL_CENTER_JMX_OPTS="${CONTROL_CENTER_JMX_OPTS} -Dcom.sun.management.jmxremote"
CONTROL_CENTER_JMX_OPTS="${CONTROL_CENTER_JMX_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"
CONTROL_CENTER_JMX_OPTS="${CONTROL_CENTER_JMX_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
# CONTROL_CENTER_JMX_OPTS="${CONTROL_CENTER_JMX_OPTS} -Dcom.sun.management.jmxremote.port=9010"
export CONTROL_CENTER_JMX_OPTS

### log4j
CONTROL_CENTER_LOG4J_OPTS="${CONTROL_CENTER_LOG4J_OPTS} -Dlog4j.configuration=file:${CONFLUENT_HOME}/log4j/control-center-log4j.properties"
export CONTROL_CENTER_LOG4J_OPTS

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
nohup ${CONFLUENT_HOME}/bin/control-center-start ${PROPERTIES_FILE} > ${LOG_DIR}/nohup.${SERVER_NAME}.out 2>&1 &

### tail stdout log
if [ "${1}" == "tail" ]; then
    tail -f ${LOG_DIR}/nohup.${SERVER_NAME}.out
fi
