# Building the image using Oracle JDK 7
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
		
# Mounting the HBase data folder and exposing the ports
VOLUME /data
EXPOSE 16000 16010 16020 16030 16100 

# Editing the HBase configuration file to use the local filesystem
ADD https://raw.githubusercontent.com/GELOG/docker-ubuntu-hbase/master/conf/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml

# Starting HBase
CMD $HBASE_HOME/bin/hbase master start