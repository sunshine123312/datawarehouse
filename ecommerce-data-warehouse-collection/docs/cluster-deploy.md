# 集群部署文档

## 一、前置环境

### 1.1 主机与网络配置

```bash
# /etc/hosts（三台机器均配置）
192.168.1.102  hadoop102
192.168.1.103  hadoop103
192.168.1.104  hadoop104

# 免密登录（hadoop102 执行到所有节点）
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
ssh-copy-id hadoop102
ssh-copy-id hadoop103
ssh-copy-id hadoop104
```

### 1.2 JDK 安装

```bash
tar -zxvf /opt/software/jdk-8u212-linux-x64.tar.gz -C /opt/module/
# 配置 JAVA_HOME 到 /etc/profile.d/my_env.sh
export JAVA_HOME=/opt/module/jdk1.8.0_212
export PATH=$PATH:$JAVA_HOME/bin
```

## 二、Hadoop 部署

```bash
# 1. 解压
tar -zxvf /opt/software/hadoop-3.1.3.tar.gz -C /opt/module/

# 2. 配置 $HADOOP_HOME/etc/hadoop/core-site.xml
#    添加 NameNode 地址和临时目录

# 3. 配置 hdfs-site.xml
#    添加副本数 (3)、SecondaryNameNode 地址、namenode/datanode 数据目录

# 4. 配置 yarn-site.xml
#    添加 ResourceManager 地址、MR 框架、日志聚合

# 5. 配置 mapred-site.xml
#    指定 MapReduce 框架为 YARN

# 6. 配置 workers
echo "hadoop102" > workers
echo "hadoop103" >> workers
echo "hadoop104" >> workers

# 7. 同步到 hadoop103、hadoop104
rsync -av /opt/module/hadoop-3.1.3 hadoop103:/opt/module/
rsync -av /opt/module/hadoop-3.1.3 hadoop104:/opt/module/

# 8. 格式化 NameNode（仅首次）
hdfs namenode -format

# 9. 启动
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh
```

## 三、ZooKeeper 部署

```bash
# 1. 解压
tar -zxvf /opt/software/apache-zookeeper-3.5.7-bin.tar.gz -C /opt/module/

# 2. 创建数据目录和 myid
mkdir -p /opt/module/zookeeper/data
echo 1 > /opt/module/zookeeper/data/myid   # hadoop102
echo 2 > /opt/module/zookeeper/data/myid   # hadoop103
echo 3 > /opt/module/zookeeper/data/myid   # hadoop104

# 3. 配置 zoo.cfg
cp /opt/module/zookeeper/conf/zoo_sample.cfg /opt/module/zookeeper/conf/zoo.cfg
# 修改 dataDir=/opt/module/zookeeper/data
# 末尾添加：
# server.1=hadoop102:2888:3888
# server.2=hadoop103:2888:3888
# server.3=hadoop104:2888:3888

# 4. 同步到 hadoop103、hadoop104
rsync -av /opt/module/zookeeper hadoop103:/opt/module/
rsync -av /opt/module/zookeeper hadoop104:/opt/module/
```

## 四、Kafka 部署

```bash
# 1. 解压
tar -zxvf /opt/software/kafka_2.12-2.4.1.tgz -C /opt/module/
mv /opt/module/kafka_2.12-2.4.1 /opt/module/kafka

# 2. 配置 server.properties（hadoop102）
# broker.id=0 (hadoop102), broker.id=1 (hadoop103), broker.id=2 (hadoop104)
# log.dirs=/opt/module/kafka/datas
# zookeeper.connect=hadoop102:2181,hadoop103:2181,hadoop104:2181

# 3. 同步到 hadoop103/hadoop104，分别修改 broker.id

# 4. 创建 Kafka 数据目录（三台）
mkdir -p /opt/module/kafka/datas
```

## 五、Flume 部署

```bash
# 1. 解压
tar -zxvf /opt/software/apache-flume-1.9.0-bin.tar.gz -C /opt/module/
mv /opt/module/apache-flume-1.9.0-bin /opt/module/flume

# 2. 拷贝到 hadoop103、hadoop104
#    采集 Flume 部署在 hadoop102，消费 Flume 部署在 hadoop104
```

## 六、一键启动脚本

所有启动脚本位于 `scripts/cluster/start-cluster.sh`，按顺序执行以下步骤：

1. start-dfs.sh + start-yarn.sh（hadoop102）
2. zkServer.sh start（三台分别在 console 或 ssh 执行）
3. 启动采集 Flume（hadoop102）
4. kafka-server-start.sh（三台）
5. 启动消费 Flume（hadoop104）
6. 启动日志生成器 / KafkaManager
