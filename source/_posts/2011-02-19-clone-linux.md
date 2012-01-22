--- 
categories: 
  - 杂七杂八
comments: true
layout: post
published: true
status: publish
tags: 
  - 攻略
  - linux
title: Linux全系统复制
type: post
---
千盼万盼，终于盼来实验室的7台R715集群，捣腾了两天好不容易才把机器和交换机都安上机架。机器有点多，我们不想每台机器都重新配置一遍环境，所以准备先配好一台机器再复制到其他机器的硬盘上。

<strong>方案1 – 全盘复制</strong>

直接复制整个硬盘，这样包括boot loader和分区表在内的硬盘所有信息都能完整的复制过去。不过目标盘的容量不能比复制源低，否则文件系统就悲剧了。这种方法需要拷贝整个硬盘，即使你什么文件也没写，所以速度非常慢。

<!--more-->可以用dd复制单块硬盘


``` 
dd if=/dev/sda of=/dev/sdb& ddpid=$!
```


dd会很慢，可以向dd进程发USR1信号监控dd进展


``` 
kill -USR1 $ddpid
```


也可以同时复制到多块硬盘


``` 
dd if=/dev/sda | tee >(dd of=/dev/sdb) >(dd of=/dev/sdc) >(dd of=/dev/sdd) > /dev/null
```


另外还有G4L和CloneZilla这样的工具可以全盘复制，不过我们觉得还是太慢了，500G的硬盘居然复制了11个小时……

<strong>方案2 – 人肉搬家</strong>

1) 用cfdisk/fdisk建好要目标硬盘的分区表，mkfs.ext4/mkswap创建好文件系统和swap分区后，把文件系统mount上来

2-1) 我们装的是Debian squeeze系统，/etc/fstab中的设备是用uuid而不是/dev/sdb1这样的设备名的，所以得把其中的uuid改成新磁盘上相应分区的uuid

可以先查看目标盘分区的uuid：


``` 
ll /dev/disk/by-uuid
```


这个目录里的每个文件都是一个uuid到实际设备的映射（软链接的形式）

然后再根据这些映射更新/etc/fstab中相应设备的uuid。当然我们也可以通过自定义udev[2]规则固定设备名称，然后直接在/etc/fstab中直接填设备名就好了。

2-2) 复制文件系统根目录，注意要排除目标盘mount的目录和系统自己mount的目录（可以用mount -l查看，比如/proc，/sys这些目录）


``` 
tar c --exclude=/proc/* --exclude=$EXCLUDE_DIR / | (cd /mnt/sdb2; tar x)
```


3) 安装boot loader

一开始我们以为直接用dd复制源硬盘MBR的前446字节（启动代码部分）过去就可以了，但启动发现连grub菜单都进不去。

其实grub启动包含了两个阶段的代码，第一阶段代码是在MBR里的，第二阶段在文件系统上，那么grub如何从第一阶段跳转到第二阶段呢？它是把第二阶段代码所在的磁盘扇区位置记录在MBR中[1]。而这份代码在每块硬盘上的位置肯定是不一样的，于是grub没办法跳转到第二阶段继续执行。

所以我们得重新安装boot loader：


``` 
grub-install --root-directory=/mnt/sdb2
```


这里–root-directory是告诉grub说我们的根文件系统是在sdb2上而不是源硬盘上，一开始我们没指定就悲剧了。

现在把目标盘装回其他机器，不出意外应该就成功了。

[1] <a title="The GRUB MBR" href="http://mirror.href.com/thestarman/asm/mbr/GRUB.htm">The GRUB MBR</a>

[2] <a title="udev" href="http://www.kernel.org/pub/linux/utils/kernel/hotplug/udev.html">udev</a>
