# docker-ubuntu-hbase
Dockerfile for running HBase on Ubuntu

# What is HBase?
Apache HBase is an open-source, distributed, versioned, non-relational database modeled after Google's Bigtable: A Distributed Storage System for Structured Data by Chang et al.

[https://hbase.apache.org/](https://hbase.apache.org/)

# Base Docker image
* [gelog/java:openjdk7](https://registry.hub.docker.com/u/gelog/java/)

# How to use this image?
### Starting the container
	docker run -d --name hbase-master -h hbase-master -P -v /hostdirectory/docker-volumes/hbase-master:/data gelog/hbase
	