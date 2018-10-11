# jimmy的docker教程（第4讲）

前面第三讲我创建了自己的docker容器而且还成功的在小数据集上面测试成功啦，但是想真正分析大数据的时候发现进程总是被killed，仔细想了想应该是docker容器能调用的资源被限制，所以也搜索学习了一些。

在使用 docker 运行容器时，一台主机上可能会运行几百个容器，这些容器虽然互相隔离，**但是底层却使用着相同的 CPU、内存和磁盘资源。**如果不对容器使用的资源进行限制，那么容器之间会互相影响，小的来说会导致容器资源使用不公平；大的来说，可能会导致主机和集群资源耗尽，服务完全不可用。

docker 作为容器的管理者，自然提供了控制容器资源的功能。正如使用内核的 namespace 来做容器之间的隔离， docker 也是通过内核的 cgroups 来做容器的资源限制。  可以参考：

- [使用 docker 对容器资源进行限制](https://cizixs.com/2017/08/04/docker-resources-limit/)
- [Docker 运行时资源限制](https://blog.csdn.net/candcplusplus/article/details/53728507) 

但是，我的docker是安装在我的iMac上面，所以这些教程都不能使用。

如果我要修改内存和CPU，直接跳转界面版本的docker的preference 即可。

```shell
docker run -it -v  /Users/jmzeng/data/project/ping_organoids/:/work_dir jmzeng/lancet:v1.0   /bin/bash
root@ca3a9e72b32f:/# cd /work_dir/lancet/
## 脚本如下：
## 也可以设置；--num-threads 
ref=/work_dir/ref/Homo_sapiens_assembly38.fasta
cat config  |while read id;
do
	arr=($id)
	normal_bam=${arr[1]}
	tumor_bam=${arr[2]}
	sample=${arr[0]}
	echo $id;

	for chrom in {1..22} X Y  M;do
		echo $chrom
		echo "lancet --tumor $tumor_bam --normal $normal_bam --ref $ref --reg chr$chrom > ${sample}_chr${chrom}.vcf"
		lancet  --tumor   $tumor_bam  --normal   $normal_bam --ref   $ref --reg chr$chrom > ${sample}_chr${chrom}.vcf
	done

done
# lancet --tumor t1.bam  --normal  n.bam  --ref  ref/Homo_sapiens_assembly38.fasta --reg  chr3:179230000-179240000 > t1.vcf

```



