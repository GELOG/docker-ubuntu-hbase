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
Note: currently this image has only been tested in local mode, using local file system. For HDFS support, see "Using HDFS" below.

### Data storage
This image is configured (in `hbase-site.xml`) to store the HBase data at `file:///data/hbase`.
To enable data persistence accross hbase restarts, the data must be stored outside Docker. In the examples below, a directory from the host is mounted into the container. To follow these examples, please do:
```bash
mkdir -p ~/data/hbase
```

### Starting a HBase container in local mode
This command starts a container for the HBase master in the background, and starts tailing its logs.
```bash
docker run -d --name hbase-master -h hbase-master -p 16010:16010 \
       -v $HOME/data/hbase:/data \
       gelog/hbase hbase master start && \
docker logs -f hbase-master
```
If everything looks good in the logs (no errors), hit `CTRL + C` to detach the console from the logs.

### Starting an interactive HBase shell session on a client container
```bash
docker run --rm -ti --name hbase-shell -h hbase-shell \
		--link=hbase-master:hbase-master \
		gelog/hbase hbase shell
```

### Starting a HBase client container to run Java programs
```bash
docker run --rm -ti --name hbase-java -h hbase-java \
		--link=hbase-master:hbase-master \
		gelog/hbase bash
```
You'll then be able to compile and execute Java programs that query the tables of the master container.
```bash
root@hbase-java:/# javac -cp .:$(hbase classpath) HbaseProgram.java
root@hbase-java:/# java -cp .:$(hbase classpath) HbaseProgram
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

### Thrift
Running with Thrift is as simple as:
```bash
docker run -d --name hbase-master -h hbase-master -p 16010:16010 -p 9090:9090 \
       -v $HOME/data/hbase:/data \
       gelog/hbase hbase master start && \
docker exec -d hbase-master hbase thrift start && \
docker logs -f hbase-master
```
Thrift can then be connected to at port 9090. If additional ports are needed, rerun and add a `-p [port]`.

### Using with HDFS
We'll be using [harisekhon's](https://hub.docker.com/r/harisekhon/hadoop/) Hadoop image, which can be downloaded using `docker pull harisekhon/hadoop`. That image writes to `/tmp`/ by default, which we'd like to change. Create a new file called `hdfs-site.xml` in your home directory with contents:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///data</value>
    </property>
</configuration>
```
Setting the `dfs.datanode.data.dir` property changes the default directory that HDFS writes data to, which we've set to `/data`. We can now mount a host directory there to enable data persistence across restarts. We create an empty directory at `$HOME/hdfs-data` for this purpose.

Create a Hadoop container with the following command:
```bash
docker run -d --name hdfs -p 8042:8042 -p 8088:8088 -p 19888:19888 -p 50070:50070 -p 50075:50075 -v $HOME/hdfs-data:/data -v $HOME/hdfs-site.xml:/hadoop/etc/hadoop/hdfs-site.xml harisekhon/hadoop
```

Now HDFS is running. Run `docker inspect hbase-master` and look for `IPAddress` near the bottom. Note the value, ours was `172.17.0.2`. 

Next, we need to connect HBase. We can do this by rewriting `hbase-site.xml`. Create a file in `$HOME/hbase-site.xml` with the following contents:
```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <!-- Fixes #1: Allow a client container to connect to the master container -->
  <property>
    <name>hbase.zookeeper.quorum</name>
    <value>hbase-master</value>
  </property>
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://172.17.0.2:8020/hbase/</value>
  </property>
  <property>
    <name>hbase.zookeeper.property.dataDir</name>
    <value>/data/hbase/zookeeper</value>
  </property>
</configuration>
```

Then run HBase with the following:
```bash
docker run -d --name hbase-master -h hbase-master -p 16010:16010 \
       -v $HOME/hbase-site.xml:/usr/local/hbase/conf/hbase-site.xml \
       gelog/hbase hbase master start && \
docker logs -f hbase-master
```

You can now browse to `http://localhost:50070/explorer.html#/` to see the contents of HDFS. You should see a `hbase` folder at the top-level directory.
