---
layout: post
title: "Emacs desktop configuration persistence"
date: 2012-04-08 16:20
comments: true
categories: 杂七杂八
---
之前一直用Emacs的desktop来保存工作状态，其实主要就是记录打开的buffer（文件）。desktop可以保存多个桌面，每个桌面都保存在单独的目录里，但是每次要切换桌面都得填路径这点比较麻烦。[my-desktop](http://scottfrazersblog.blogspot.com/2009/12/emacs-named-desktop-sessions.html)在其基础上增加了命名功能，这样保存和读取桌面都只要用名字就可以了。my-desktop里的路径处理都是用字符串操作来做的，比较丑，我都改了过来，还加了个删除功能，另外还有些小改动。  

新的接口如下：  
* `my-desktop-save` 保存当前桌面  
* `my-desktop-save-as` 重命名当前桌面  
* `my-desktop-save-and-read` 加载指定桌面  
* `my-desktop-new` 新建桌面  
* `my-desktop-destroy` 删除桌面  
* `my-desktop-name` 查看当前桌面名  

代码：  
{% gist 2329912 my-desktop.el %}

desktop虽然能记录打开的buffer，但是它并不能保存窗口的配置信息。比如我写代码时习惯先垂直划分大窗口，再水平划分右半窗口，而在退出Emacs之后desktop并没有保存这个配置。

其实Emacs的桌面配置可以保存在[Emacs Register](http://www.gnu.org/software/emacs/manual/html_node/emacs/RegConfig.html#RegConfig)里，不过就是一直没找到很好用的包。后来发现[workgroups](https://github.com/tlh/workgroups.el)这个扩展能保存窗口状态，封装得也还不错，而且还是有人在维护的。但它的master分支没有记录打开的buffer的功能，可以配合desktop使用，这样做有个问题是保存的buffer历史和窗口配置之间没有关联，需要手动分别切换。而workgroups的experimental分支就支持buffer历史和窗口配置的关联，但是`kill-buffer`似乎有点bug，关闭最后一个buffer之后会出现其他窗口的buffer，有空再研究下。这些Emacs桌面的问题在workgroups的文档里都提到了，看来大家遇到的情况都差不多。
