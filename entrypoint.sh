#!/bin/bash

SPARK_HOME="/opt/spark-1.6.2-bin-hadoop2.6"
#HADOOP_HOME="opt/hadoop"
#HADOOP_SBIN_DIR="opt/hadoop/sbin"
HADOOP_CONF_DIR="/opt/spark-1.6.2-bin-hadoop2.6/conf"
YARN_CONF_DIR="/opt/spark-1.6.2-bin-hadoop2.6/conf"

echo Using SPARK_HOME=$SPARK_HOME

. "${SPARK_HOME}/sbin/spark-config.sh"

. "${SPARK_HOME}/bin/load-spark-env.sh"

. "/root/.bashrc"

if [ "$SPARK_MASTER_PORT" = "" ]; then
  SPARK_MASTER_PORT=7077
fi

if [ "$SPARK_MASTER_IP" = "" ]; then
  SPARK_MASTER_IP="0.0.0.0"
fi

if [ "$SPARK_MASTER_WEBUI_PORT" = "" ]; then
  SPARK_MASTER_WEBUI_PORT=8080
fi

if [ "$SPARK_WORKER_WEBUI_PORT" = "" ]; then
  SPARK_WORKER_WEBUI_PORT=8081
fi

if [ "$SPARK_WORKER_PORT" = "" ]; then
  SPARK_WORKER_PORT=8581
fi

if [ "$SPARK_MASTER_HOSTNAME" = "" ]; then
  SPARK_MASTER_HOSTNAME=`hostname -f`
fi

if [ "$HOSTNAME" = "" ]; then
  HOSTNAME=`hostname -f`
fi

sed "s/HOSTNAME_MASTER/$SPARK_MASTER_HOSTNAME/" /opt/spark-1.6.2-bin-hadoop2.6/conf/spark-defaults.conf.template > /opt/spark-1.6.2-bin-hadoop2.6/conf/spark-defaults.conf
sed "s/HOSTNAME/$SPARK_MASTER_HOSTNAME/" /opt/spark-1.6.2-bin-hadoop2.6/conf/core-site.xml.template > /opt/spark-1.6.2-bin-hadoop2.6/conf/core-site.xml
sed "s/HOSTNAME/$HOSTNAME_MASTER/" /opt/spark-1.6.2-bin-hadoop2.6/conf/yarn-site.xml.template > /opt/spark-1.6.2-bin-hadoop2.6/conf/yarn-site.xml	

SPARK_MASTER_URL="spark://$SPARK_MASTER_HOSTNAME:$SPARK_MASTER_PORT"
echo "Using SPARK_MASTER_URL=$SPARK_MASTER_URL"

if [ "$MODE" = "" ]; then
MODE=$1
fi

if [ "$MODE" == "headnode" ]; then 
	
	#/opt/hadoop/bin/hdfs namenode -format
	#${HADOOP_SBIN_DIR}/hadoop-daemons.sh --config "$HADOOP_CONF_DIR" --hostnames "spark.marathon.mesos" --script "/opt/hadoop/bin/hdfs" start namenode
	#${HADOOP_SBIN_DIR}/yarn-daemon.sh --config "$YARN_CONF_DIR" start resourcemanager 
	
	#jupyter notebook --ip=0.0.0.0  &
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" --ip $SPARK_MASTER_IP --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT

elif [ "$MODE" == "datanode" ]; then
	
	#${HADOOP_SBIN_DIR}/hadoop-daemons.sh --config "$HADOOP_CONF_DIR" --script "/opt/hadoop/bin/hdfs" start datanode
	#${HADOOP_SBIN_DIR}/yarn-daemon.sh --config "$YARN_CONF_DIR" start nodemanager 
	
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL
else
	#/opt/hadoop/bin/hdfs namenode -format
	#${HADOOP_SBIN_DIR}/hadoop-daemons.sh --config "$HADOOP_CONF_DIR" --hostnames "spark.marathon.mesos" --script "/opt/hadoop/bin/hdfs" start namenode
	#${HADOOP_SBIN_DIR}/yarn-daemon.sh --config "$YARN_CONF_DIR" start resourcemanager
	
	#${HADOOP_SBIN_DIR}/hadoop-daemons.sh --config "$HADOOP_CONF_DIR" --script "/opt/hadoop/bin/hdfs" start datanode
	#${HADOOP_SBIN_DIR}/yarn-daemon.sh --config "$YARN_CONF_DIR" start nodemanager 
	
	#jupyter notebook --ip=0.0.0.0  &
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" --ip $SPARK_MASTER_IP --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT &
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL	
fi
