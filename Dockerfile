# Building the image using Hadoop
FROM gelog/hadoop

MAINTAINER Julien Beliveau

# Setting HBASE environment variables
ENV HBASE_VERSION 1.0.1.1
ENV HBASE_INSTALL /usr/local/hbase

# Installing HBase
RUN	wget https://www.apache.org/dist/hbase/stable/hbase-$HBASE_VERSION-bin.tar.gz && \
	tar -xvf hbase-$HBASE_VERSION-bin.tar.gz && \
	rm hbase-$HBASE_VERSION-bin.tar.gz && \
	mv hbase-$HBASE_VERSION /usr/local/hbase
		
# Editing the conf files
RUN	echo export JAVA_HOME=/usr/lib/jvm/jdk >> $HBASE_INSTALL/conf/hbase-env.sh && \
	echo export HBASE_HOME=$HBASE_INSTALL >> ~/.bashrc && \
	echo export PATH='$PATH':'$HBASE_HOME'/bin >> ~/.bashrc

RUN head -n -2 $HBASE_INSTALL/conf/hbase-site.xml > $HBASE_INSTALL/conf/hbase-site.xml && \
	echo '<configuration>' >> $HBASE_INSTALL/conf/hbase-site.xml && \
	echo '<property>' >> $HBASE_INSTALL/conf/hbase-site.xml && \
	echo '<name>hbase.rootdir</name>' >> $HBASE_INSTALL/conf/hbase-site.xml && \
	echo '<value>file:/usr/local/hbase/HFiles</value>' >> $HBASE_INSTALL/conf/hbase-site.xml && \
	echo '</property>' >> $HBASE_INSTALL/conf/hbase-site.xml && \
	echo '<property>' >> $HBASE_INSTALL/conf/hbase-site.xml && \
	echo '<name>hbase.zookeeper.property.dataDir</name>' >> $HBASE_INSTALL/conf/hbase-site.xml && \
	echo '<value>/usr/local/hbase/zookeeper</value>' >> $HBASE_INSTALL/conf/hbase-site.xml && \
	echo '</property>' >> $HBASE_INSTALL/conf/hbase-site.xml && \
	echo '</configuration>' >> $HBASE_INSTALL/conf/hbase-site.xml

# Once the container is started, execute "./usr/local/hbase/bin/start-hbase.sh" and then "hbase shell"]
