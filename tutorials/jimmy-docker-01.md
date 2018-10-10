# jimmy的docker教程（第一版）

## 写在前面
> 以前胡兄为我们生信技能树公众号写一个**阿里云服务器处理RNA-seq和ChIP-seq数据**的教程的时候提到了docker这个打包技术，可以迅速的重现一个pipeline。
>
> 虽然我以前也偶尔看到过这个名词，但是这是它第一次以生物信息学相关角色进入我的知识库。

这么神奇的东东，我岂能错过。下面就简单描述一下我的学习过程及理解：

## 首先安装docker

> 需要root权限，我们一般是在亚马逊等云服务器上面折腾！你可以先搜索一些它的基础知识，再回来看我的教程，因为我不喜欢照搬基础。

我是通过谷歌找到的下面的安装代码：

```shell
sudo apt-get update
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
sudo apt-get update
apt-cache policy docker-engine
sudo apt-get install -y docker-engine
```

可以看到代码略微有点复杂，亲测可用。

如果不是计算机专业也没必要去全部弄懂，反正运行代码在ubuntu 16上面肯定是能成功的。其余的报错就谷歌，这是生信工程师的基本技能。

当然， 现在有了更方便的安装代码，安装之后进行简单的权限管理。

```shell
sudo systemctl status docker ## 查看docker服务启动情况
ps -Af | grep docker ##查看是否有这个docker进程。
id
sudo usermod -aG docker $(whoami)
id
id $(whoami) ## 需要把自己的用户添加docker权限，因为docker需要root权限，但我们不能随便乱用root用户操作。
#  you need to close you session in order to have the change taken into account.
sudo usermod -aG docker jimmy 
```

## docker 的基本指令

> 这个其实没什么好讲的，docker这个软件安装好了，就可以运行下面的命令，看一遍就知道啥意思了，而且这些命令都是有参数的，慢慢熟悉呗。

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

上面的命令都是安全的，可以随便玩,玩的过程会产生很多垃圾image和container~

## 镜像和容器

一般人是不需要自己构建镜像的，这个比较麻烦，初学者下载一些公共的镜像玩一玩就好了。下载的镜像启动一次就是一个容器！

> Docker 两个基本步骤：
1. 构建一个镜像。 sudo docker pull busybox
2. 运行容器。 docker run busybox /bin/echo Hello Docker

> Docker 三个基本要素分别是：
* Docker Containers负责应用程序的运行，包括操作系统、用户添加的文件以及元数据。
* Docker Images是一个只读模板，用来运行Docker容器。
* DockerFile是文件指令集，用来说明如何自动创建Docker镜像。

## 先看容器

前面说到``Docker``两个基本步骤，下载镜像和运行容器。下载很简单，就``docker pull``即可，我们主要讲容器(``docker run ``)的各种花式操作。虽然就一个run的命令，但是参数非常多，大家自己看help，我随便描述几个常见的用法。

### 后台进程的方式运行 
```
sample_job=$(docker run -d busybox /bin/sh -c "while true; do echo Docker; sleep 1; done)
```
-d参数把该次运行的容器的ID保存下来了，赋值给了sample_job变量。

### 运行docker logs命令来查看job的当前状态：
```
docker logs $sample_job
```

### 改变容器的状态

> 各种命令，我就不一一介绍了。
```
restart / stop / rm /
```
我们在镜像的基础上面启动的容器经常是需要丢弃的，如果要删除，需要先stop再rm

### 将容器的状态保存为镜像
```
docker commit $sample_job job1
```
注意，镜像名称只能取字符[a-z]和数字[0-9]。


## 构建镜像
> 上面提到了可以把正在运行着的容器保存为镜像，但是通常镜像不是这样产生的，也不建议大家这样构建镜像。构建镜像的两种方法：
* 使用docker commit 命令从已经创建的容器中更新镜像，并且提交这个镜像
* 使用docker build命令和Dockerfile文件创建一个新的镜像

一般来说不是真的“创建”新镜像，而是基于一个已有的基础镜像，比如Ubuntu、Fedora等，构建新的镜像而已。

### 用 commit 命令创建镜像

> 首先进入下载一个镜像，并以此创建运行容器，这样就可以在容器里面操作它了，比如下面在里面安装了wget/make等等小工具

```
sudo docker pull ubuntu
docker run -it ubuntu    
## -it运行的容器是交互式的，直接进入了容器里面，进行下面的操作
cat /etc/issue.net 
uname -a 
cat /etc/lsb-release 

apt update && apt upgrade
apt install wget
apt install make
apt install cmake
apt install bzip2 # tar 
apt install zip unzip

apt install zlib1g-dev #samtools
apt install libncurses5-dev #samtools
apt install g++ # vcftools
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

* -m:提交的描述信息
* -a:指定镜像作者

PS：不推荐为运行中的容器创建镜像,换言之，不要使用``docker commit``命令来创建镜像。

### Docker自动创建镜像

> Docker为我们提供了Dockerfile来解决自动化创建镜像，

所有Dockerfile都必须以FROM命令开始。 FROM命令会指定镜像基于哪个基础镜像创建，接下来的命令也会基于这个基础镜像!

胡兄的 Docker 文件如下：https://github.com/huboqiang/tangEpiNGSInstall

这里我们把上面用``docker commit``命令来创建镜像用dockerfile再来一次！

```
FROM ubuntu
MAINTAINER jianmingzeng<jmzeng1314@163.com>
RUN apt -y update 
RUN apt -y upgrade
RUN apt install -y wget curl make cmake 
RUN apt install -y bzip2 # tar 
RUN apt install -y zip unzip
RUN apt install -y zlib1g-dev #samtools
RUN apt install -y libncurses5-dev #samtools
RUN apt install -y g++ # vcftools
```
请注意那些-y参数，因为dockerfile里面是不交互的，所以没办法像上面那种情况那样进入容器，慢慢运行代码，而且批量的一次性的构建好这个镜像，构建的代码如下：
```
docker build -t="test" .
```
> 需要保证运行命令的目录有一个文件叫做dockerfile，而且这个dockerfile里面存储的内容就是上面那些FROM,RUN,至于它们命令的意思，可以自己去搜索。如果想建立自己的镜像，需要学习的路还很长哦。

可以查看docker images，发现本来基本的ubuntu只有117MB，我在此基础上面安装了几个小工具，就变成了427MB啦！

## 写在最后

很早以前就有人建议我把我的**1000个生物信息学软件安装代码以及100个生物信息学数据库文件**下载一起打包成一个docker供大家使用，但是在深入学习docker之后发现其实意义不大，现在软件管理我还是比较推荐conda，数据库文件下载放在docker那样这个镜像就会变的非常巨大，可能超过50G，这就违背了docker轻量级的初衷了。

参考资料：
优先用dockerfile： http://www.oschina.net/translate/10-things-to-avoid-in-docker-containers

报错解决：https://linux.cn/article-7276-1.html

dockerFiles: http://dockone.io/article/103

Dockerfile的最佳实践:http://crosbymichael.com/dockerfile-best-practices.html

Docker 命令大全 http://www.runoob.com/docker/docker-command-manual.html