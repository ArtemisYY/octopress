--- 
categories: 
  - 杂七杂八
comments: true
layout: post
published: true
status: publish
tags: 
  - mapreduce
  - hadoop
  - data
title: Hadoop的下一代MapReduce框架
type: post
---
最近雅虎开发者博客发了一篇介绍<a title="The Next Generation of Apache Hadoop MapReduce" href="http://yhoo.it/fDoTzt" target="_blank">Hadoop重构计划</a>的文章。他们发现当集群的规模达到4000台机器的时候，Hadoop遭遇到伸缩性的瓶颈。目前Hadoop各个模块的紧耦合使得在现有设计的基础上的继续改进举步维艰。这一点早已在社区内达成共识，目前他们正准备开始对Hadoop进行重构。

新架构的主要思想是把原来JobTracker的功能一分为二：ResourceManager管理资源的分配，ApplicationMaster管理任务监控和调度。ResourceManager与原有的JobTracker类似，作为整个集群的控制中心；而ApplicationMaster则是每个application都有一个单独的实例，application是用户提交的一组任务，它可以由一个或多个job组成。每台slave运行一个NodeManager实例，功能类似于原来的TaskTracker。

<a href="http://ydn.zenfs.com/blogs/22/MapReduce_NextGen.jpg"><img class="alignnone" title="Hadoop Nextgen Architecture" src="http://ydn.zenfs.com/blogs/22/MapReduce_NextGen.jpg" alt="Hadoop Nextgen Architecture" width="624" height="386"></a>

雅虎的博客已经对新架构的优势作了全面的介绍，这里只列出几点我个人比较关注的：

1、层次化的管理

目前Hadoop的资源管理和任务调度都是在JobTracker中进行的，它需要复制所有task的资源分配和调度。而task是非常微观的调度单位，通常每个job都会产生成百上千个task，而系统同一时刻又会有大量的job同时运行，这让JobTracker的管理负担变得非常繁重。新架构将这一管理任务下放到各个ApplicationMaster，ResourceManager只管理每个application的资源分配。这样即使系统中存在很多application，ResourceManager的负担也能控制在一个合理的程度；这也是新架构最大的优势。

2、ApplicationMaster应该在Master还是Slave上运行？

新架构实际上将管理和调度的任务转移到ApplicationMaster上来，如果ApplicationMaster所在的节点挂掉，整个任务都需要重做。原来JobTracker可以跑在相对稳定的Master上，出错概率低；现在ApplicationMaster跑在好些Slave上，出错的概率就非常高了。而且新架构打破了原来简单的Master-Slave模型，节点之间的通讯和依赖关系变得更加复杂，增加了网络优化的难度。如果把ApplicationMaster全都放在Master上执行，则Master的负担会非常重（需要处理各种持续性的heartbeat和爆发性的如getTaskCompletionEvents这样的rpc请求），不过这个问题可以通过分布式的Master解决（Google已经实现）。

3、资源管理方式

原来单纯地以简单静态的slot作为资源单位确实不能很好描述集群的资源状况。新架构将更细粒度地控制CPU，内存，磁盘，网络这些资源。每个task都将在Container中执行，并只能使用其所分配到的系统资源。资源的分配可以用静态估计动态调整的方式实现。

4、支持其他编程模型

由于任务的管理和调度都由ApplicationMaster进行，ApplicationMaster又相对独立于系统的其他模块，用户甚至可以部署自己的ApplicationMaster，实现对其他编程模型的支持。这使得其他不大适合用MapReduce实现的应用程序也能在同一个Hadoop集群中运行。
