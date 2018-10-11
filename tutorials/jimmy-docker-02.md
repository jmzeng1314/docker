# jimmy的docker教程（第2讲）

首先需要复习几个docker指令：

```shell
docker
docker info ## 可以查看目前机器上面的docker里面有多少容器或者镜像。
docker version
sudo docker search ubuntu
sudo docker run hello-world 
## 上面代码下载了一个镜像，启动了一个容器，下面就可以查看它们
docker ps -a  ## 查看目前所有没有被销毁的容器进程。
docker images -a ## 查看目前所有的本地镜像 
docker volume ls  
docker network ls 
```

### 根据需求下载docker镜像

在服务器上面GitHub里面的软件https://github.com/nygenome/lancet非常困难

就想求助于docker版本：https://hub.docker.com/r/seandavi/lancet/ 

```shell
docker run  seandavi/lancet
```

可以看到：

```
jianmingzengs-iMac:~ jmzeng$ docker images -a
REPOSITORY                                       TAG                 IMAGE ID            CREATED             SIZE
seandavi/lancet                                  latest              1a83521f4492        12 days ago         490MB
```

的确是有了这个本地镜像，现在可以启动该容器来处理自己的数据。

### 启动镜像

首先可以用交互式命令行进入该镜像：

```
docker run -it  seandavi/lancet  /bin/bash
```

简单查看配置还有该容器的路径，接下来就可以**把本地数据盘挂载进入**进行处理。这样在容器启动后，容器内的虚拟电脑会自动创建被添加的目录。-v参数中，冒号":"前面的目录是宿主机目录，后面的目录是容器内目录。详见：http://blog.csdn.net/magerguo/article/details/72514813

```
docker run -it -v   /Users/jmzeng/tmp:/work_dir seandavi/lancet  /bin/bash 
docker run -it -v  /Users/jmzeng/data/project/ping_organoids/bams/:/work_dir seandavi/lancet  /bin/bash 
```

这样docker能访问本机的` /Users/jmzeng/tmp`的内容，同时对镜像容器里面的`/work_dir`目录的修改等同于对本机的` /Users/jmzeng/tmp`的修改。

### 处理数据

软件示例代码很简单：

```shell
lancet --tumor T.bam --normal N.bam --ref ref.fa --reg 22:1-51304566 --num-threads 8 > out.vcf

```

有趣的是作者制作的镜像其实也有错误，lancet软件安装是失败的，不过docker的好处是里面可以使用root权限。

```
apt-get install libbz2-dev
apt-get install zlib1g-dev
apt-get install liblzma-dev
apt-get install libssl-dev
apt-get install libbamtools-dev
apt-get install libcurl4-openssl-dev
```

但是我为什么不自己创建一个成功的`lancet镜像`呢？





