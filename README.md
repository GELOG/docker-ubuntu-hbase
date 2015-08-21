# Docker image for HBase

[ ![issues](https://img.shields.io/github/issues/gelog/docker-ubuntu-hbase.svg) ](https://github.com/gelog/docker-ubuntu-hbase)


## What is HBase?
Use Apache HBase™ when you need random, realtime read/write access to your Big Data. This project's goal is the hosting of very large tables -- billions of rows X millions of columns -- atop clusters of commodity hardware. Apache HBase is an open-source, distributed, versioned, non-relational database modeled after Google's [Bigtable: A Distributed Storage System for Structured Data by Chang et al](http://research.google.com/archive/bigtable.html). Just as Bigtable leverages the distributed data storage provided by the Google File System, Apache HBase provides Bigtable-like capabilities on top of Hadoop and HDFS.

[http://hbase.apache.org/](http://hbase.apache.org/)


## What is Docker?
Docker is an open platform for developers and sysadmins to build, ship, and run distributed applications. Consisting of Docker Engine, a portable, lightweight runtime and packaging tool, and Docker Hub, a cloud service for sharing applications and automating workflows, Docker enables apps to be quickly assembled from components and eliminates the friction between development, QA, and production environments. As a result, IT can ship faster and run the same app, unchanged, on laptops, data center VMs, and any cloud.

https://www.docker.com/whatisdocker/

### What is a Docker Image?
Docker images are the basis of containers. Images are read-only, while containers are writeable. Only the containers can be executed by the operating system.

https://docs.docker.com/terms/image/


## How to use this image?
Note: currently this image has only been tested in local mode, using local file system.

### Data storage
This image is configured (in `hbase-site.xml`) to store the HBase data at `file:///data/hbase`.
To enable data persistence accross hbase restarts, the data must be stored outside Docker. In the examples below, a directory from the host is mounted into the container. To follow these examples, please do:
```bash
mkdir -p ~/data/hadoop/hbase
```

### Starting a HBase container in local mode
This command starts a container for the HBase master in the background, and starts tailing its logs.
```bash
docker run -d --name hbase-master -h hbase-master -p 16010:16010 \
       -v $HOME/data/hadoop/hbase:/data \
       gelog/hbase hbase master start && \
docker logs -f hbase-master
```
If everything looks good in the logs (no errors), hit `CTRL + C` to detach the console from the logs.

### Starting an interactive HBase shell session
(temporary) Currently the recommended approach is execute the shell inside the hbase-master container
```bash
docker exec -ti hbase-master hbase shell
```

### Executing a HBase shell command and detaching immediately
Prints the list of commands available in the hbase shell
```bash
echo "help" | docker exec -i hbase-master hbase shell
```
Or to send multiple commands to the HBase shell, try:
```bash
docker exec -i hbase-master hbase shell << EOF
  create 'test', 'cf'
  list
  put 'test', 'row1', 'cf:a', 'value1'
  put 'test', 'row2', 'cf:b', 'value2'
  put 'test', 'row3', 'cf:c', 'value3'
  put 'test', 'row4', 'cf:d', 'value4'
  scan 'test'
  get 'test', 'row1'
  disable 'test'
  enable 'test'
EOF
```

### Accessing the web interface
Open you browser at the URL `http://docker-host:16010/`, where `docker-host` is the name / IP of the host running the docker daemon. If using Linux, this is the IP of your linux box. If using OSX or Windows (via Boot2docker), you can find out your docker host by typing `boot2docker ip`. On my machine, the web UI runs at `http://192.168.59.103:16010/`
