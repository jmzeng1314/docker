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
apt -y install wget curl g++ gcc make cmake  
apt -y install bzip2 zip unzip  
apt -y install zlib1g zlib1g-dev  libncurses5-dev  
apt -y install libbz2-dev liblzma-dev libssl-dev libbamtools-dev libcurl4-openssl-dev
apt -y install git 
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
sudo docker commit ff5f5009cb28 ubuntu/jimmy
docker images
```

命令中，指定了要提交的修改过的容器的ID、目标镜像仓库、镜像名。commit提交的知识创建容器的镜像与容器的当前状态之间的差异部分，很轻量。

还可以加入一些参数：

- -m:提交的描述信息
- -a:指定镜像作者

PS：不推荐为运行中的容器创建镜像,换言之，不要使用``docker commit``命令来创建镜像。