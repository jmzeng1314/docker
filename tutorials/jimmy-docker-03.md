# jimmy的docker教程（第三版）

在第一讲我提到了创建docker容器的两种方式，正巧我想使用的一个容器，结果发现它是错误的，现在可以试试看自己创建这样的容器！

还是首先需要复习几个docker指令：

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

### 用 commit 命令创建镜像

> 首先进入下载一个镜像，并以此创建运行容器，这样就可以在容器里面操作它了，整理后就是自己的容器啦。

```shell
sudo docker pull ubuntu
docker run -it ubuntu    
## -it运行的容器是交互式的，直接进入了容器里面，进行下面的操作
cat /etc/issue.net 
uname -a 
cat /etc/lsb-release 
apt update && apt upgrade

apt -y install wget curl g++ gcc make cmake  git 
apt -y install bzip2 zip unzip  zlib1g zlib1g-dev  libncurses5-dev   
apt -y install libbz2-dev liblzma-dev libssl-dev libbamtools-dev libcurl4-openssl-dev
 
mkdir -p /opt/
cd /opt/
git clone git://github.com/nygenome/lancet.git
cd lancet
make
ln -s /opt/lancet/lancet /usr/bin/lancet
mkdir /test && cd  /test  
mkdir ref 
## https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0?pli=1 
# lancet --tumor t1.bam  --normal  n.bam  --ref  ref/Homo_sapiens_assembly38.fasta --reg  chr3:179230000-179240000 > t1.vcf 
exit
```

> 要把它当前状态保存下来，就不必每次都创建一个新容器并再次安装 wget/make这些小工具
> 先用exit命令退出容器，再运行docker commit命令！

```
docker images
sudo docker commit -a 'jimmy' -m ‘lancet:v1.0’ a0db8d411f52 jmzeng/lancet:v1.0
docker images
```

提交镜像: 执行命令**提交镜像到本地**(这个跟git的其实是一样的,先提交镜像到本地,才能推送到你的远程镜像仓库,**一定要注意提交的镜像名格式 帐号/名字:如 jmzeng/lancet,否则无法推送**)  https://hub.docker.com/u/jmzeng/ 
解释参数：

- -m:提交的描述信息
- -a:指定镜像作者

提交镜像到本地可以看到：

```
 docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
jmzeng/lancet       v1.0                f86af09c0cc8        4 seconds ago       548MB
ubuntu              latest              cd6d8154f1e1        4 weeks ago         84.1MB
```

这个`548MB`的就是需要上传到`docker hub`的， 上传需要登录自己的账号密码，执行命令: ` docker login` 登录你的 `hub.docker` 帐号 , 登录成功后就可以使用 来 提交自己自己好的镜像到远程仓库，这个时候就很考验网速啦。

上传完毕就可以去   https://hub.docker.com/u/jmzeng/  里面查看是否成功。

不过，好像大多数人更推荐直接使用`dockerfile`来构建镜像，所以我可以把上面的操作转换为 `dockerfile` 形式的。

### 使用dockerfile创造lancet镜像

代码也很简单，如下：

```shell
# Update the repository sources list
RUN apt update && apt upgrade
RUN apt -y install wget curl g++ gcc make cmake  git 
RUN apt -y install bzip2 zip unzip  zlib1g zlib1g-dev  libncurses5-dev   
RUN apt -y install libbz2-dev liblzma-dev libssl-dev libbamtools-dev libcurl4-openssl-dev
 
RUN mkdir -p /opt/
WORKDIR /opt/
RUN git clone git://github.com/nygenome/lancet.git
WORKDIR /opt/lancet
RUN make
RUN ln -s /opt/lancet/lancet /usr/bin/lancet
RUN mkdir -p /test/
WORKDIR /test/
RUN mkdir -p /ref/
```

参考：http://wiki.jikexueyuan.com/project/docker/docker-hub/builds.html

https://segmentfault.com/a/1190000012662268 

