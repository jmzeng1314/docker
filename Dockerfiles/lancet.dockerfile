############################################################
# Dockerfile to build lofreq variant caller container
# Based on Ubuntu
#
# lancet is on the path
#
# usage:
#   docker run jmzeng/lancet lancet ....
#
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / jmzeng
MAINTAINER jianming zeng <jmzeng1314@163.com>

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

