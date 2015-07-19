# Building the image using Oracle JDK 7
FROM gelog/java:openjdk7

MAINTAINER Julien Beliveau

# Setting HBASE environment variables
ENV HBASE_VERSION 1.1.1
ENV HBASE_HOME /usr/local/hbase

# Installing wget
RUN \
    apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

# Installing HBase
RUN	wget https://www.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz && \
	tar -xvf hbase-$HBASE_VERSION-bin.tar.gz && \
	rm hbase-$HBASE_VERSION-bin.tar.gz && \
	mv hbase-$HBASE_VERSION /usr/local/hbase
		
# Adding HBase to bashrc
RUN	echo export PATH='$PATH':'$HBASE_HOME'/bin >> ~/.bashrc

# Mounting the HBase data folder and exposing the ports
VOLUME /data/persistent/hbase
EXPOSE 60000 60010 60020 60030

# Editing the HBase configuration file to use the local filesystem
ADD https://raw.githubusercontent.com/GELOG/docker-ubuntu-hbase/master/conf/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml

# Starting HBase
CMD $HBASE_HOME/bin/hbase master start