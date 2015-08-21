# Building the image using Open JDK 7
FROM gelog/java:openjdk7

MAINTAINER Julien Beliveau

# Setting HBASE environment variables
ENV HBASE_VERSION 1.1.1
ENV HBASE_HOME /usr/local/hbase
ENV PATH $PATH:$HBASE_HOME/bin


# Installing wget
RUN \
    apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

# Installing HBase
RUN	wget https://www.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz && \
	tar -xf hbase-$HBASE_VERSION-bin.tar.gz && \
	rm hbase-$HBASE_VERSION-bin.tar.gz && \
	mv hbase-$HBASE_VERSION /usr/local/hbase


# Mounting the HBase data folder
VOLUME /data


# Editing the HBase configuration file to use the local filesystem
ADD conf/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml


####################
# PORTS
####################
#
# http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.3.0/bk_HDP_Reference_Guide/content/reference_chap2.html
# http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_ports_cdh5.html
# https://github.com/apache/hbase/blob/master/hbase-common/src/main/resources/hbase-default.xml
#
# HBase: HMaster
#	16000 = hbase.master.port		(IPC)
#	16010 = hbase.master.info.port		(HTTP / HBase Web UI)
# HBase: RegionServer (RS)
#	16020 = hbase.regionserver.port		(IPC
#	16030 = hbase.regionserver.info.port	(HTTP)
#	 8080 = hbase.rest.port			(HTTP / REST Server, optional)
#	 8085 = hbase.rest.info.port		(HTTP / REST Server Web UI, optional)
#	 9090 = 				(Thrift / Thrift Server, optional)
#	 9095 = hbase.thrift.info.port		(Thrift / Thrift Server Web UI, optional
#
# Web UI shows link to regionservers using random ports (e.g.: http://hbase-master:50846/rs-status).
# This is probably related to local mode.
# 
EXPOSE 16000 16010 16020 16030

# Starting HBase
CMD ["hbase"]

