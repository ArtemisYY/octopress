---
layout: post
title: "在HP TouchPad上安装Android 4.0"
date: 2012-02-10 22:43
comments: true
categories: 杂七杂八
---
暑假赶上HP挥泪甩卖，拼到TouchPad一只。TouchPad的原生系统是webOS，虽然上面的应用及其稀少，但也有其独到之处：醒目而又不烦人的**通知系统**，富有操作感的**卡片式任务管理**，以及对**Flash**的完美支持。而且在后来的一次版本升级里还加入了一个彩蛋，当你以某一个特定方位查看任务卡片时，往下拉卡片会有弹弓被拉紧的声效，松指让卡片飞出的时候就能听到后面有只愤怒的小鸟也欢乐地“hui”出来。

无奈应用确实少得可怜，前天终于抽空把它刷成webOS和Android双系统。目前移植得比较成功的是CyanogenMod(CM)这个发行版，最新版本是CM9，基于Android 4.0。网上的教程大多很啰嗦，中文的也都还是CM7(Android 2.3)版本，所以简单记录下。我是在Mac OS X 10.7.3下刷机的，Windows和Linux的步骤也都类似。

#### 0. 先下载下面这几个文件/工具：
* ACMEInstaller2  
* update-cm-9.0.0-RC0-Touchpad-alpha0.6-fullofbugs.zip  
* update-cwm_tenderloin-1012.zip  
* moboot_0.3.5.zip  
* novacom

前四个文件都可以在开发团队的[论坛发布贴][1]下载。其中ACMEInstaller2(**A** **C**yanogen**M**od **E**xperimental Installer)是用来将CyanogenMod刷进TouchPad的工具；update-cm这个就是CM(Android)的镜像；update-cwm_tenderloin是一个专门刷Android ROM的工具(ClockworkMod)；moboot提供多系统启动的支持。

而最后一个novacom则是HP官方提供的TouchPad驱动和刷机工具，包含在[HP webOS SDK](https://developer.palm.com/content/resources/develop/sdk_pdk_download.html)里，不过因为整个SDK太大了，[有人](http://code.google.com/p/universal-novacom-installer/downloads/list)就专门把这novacom从SDK抽取出来。我一开始试了好几个第三方的novacom都不成功，最后还是装了SDK才认出设备来。

#### 1. 安装novacom

#### 2. 准备刷机文件  
让TouchPad以USB drive mode连接电脑，把

* update-cm-9.0.0-RC0-Touchpad-alpha0.6-fullofbugs.zip  
* update-cwm_tenderloin-1012.zip  
* moboot_0.3.5.zip

这三个文件复制到TouchPad根目录下的`cminstall`(一定要叫这个名字)这个目录去(需要自己新建目录)。

#### 3. 进入开发模式  
重启TouchPad，在屏幕变暗时按住**增大音量键**(也有说法是要同时按住电源键，不过我只按增大音量键就行了，可能是TouchPad版本问题吧)，直到屏幕出现USB连接图示的时候才松手。这时候要等一下让电脑安装驱动。

#### 4. 刷机  
在终端执行下面这个命令，其中`/path/to/ACMEInstaller2`是ACMEInstaller2文件路径

```
novacom boot mem:// < /path/to/ACMEInstaller2
```

你应该会看到TouchPad屏幕上哗啦啦的一溜输出，等到它完成后会自动重启，这时候TouchPad就已经安装上Android系统了。刷机后启动会先进入moboot的选择启动界面，默认是5秒后进Android，你也可以用音量键上下移动，用菜单键选择启动项。

### 问题

Q: novacom报`failed to connect to server`错误。  
A: 这个可能是硬件问题，换根USB线，换个电压大点的USB插口；也可能是软件问题，比如novacom没装好，系统没驱动认不出TouchPad来。

Q: Android下连接电脑没法识别出USB存储设备。  
A: Settings -> Storage -> 注意到右上角那个小菜单没有 -> USB Settings -> 选上MTP模式。

Q: Mac下还是看不到挂载的USB设备。  
A: 装一个[Android File Trasfer](http://www.android.com/filetransfer)

Q: 怎么刷完机就充不上电啊！  
A: 最近天气冷，把TouchPad丢被窝里暖暖再充。

---
3月4日更新：  
### 升级至更新版的CM9
目前CM9的移植已经更新至[Alpha 2][cm9-2]版本，解决了硬解码问题。只要把新的CM9内核放到TouchPad上，然后重启TouchPad进入ClockworkMod模式，执行Wipe cache partition，清除缓存后执行Install zip from sdcard，选择新的CM9内核，执行后重启后就进入新的系统了。具体的升级过程可以参考这个[教程][upgrade]和[视频][upgrade-video]。

### 参考  
[1] [[Release][Alpha0.6] CyanogenMod 9 Touchpad][cm9-0.6]  
[2] [How to install Android 4.0 on the HP TouchPad (CyanogenMod 9 Alpha)][how-to]  
[3] [[Release][Alpha2] CyanogenMod 9 Touchpad][cm9-2]


[cm9-0.6]: http://rootzwiki.com/topic/15509-releasealpha06-cyanogenmod-9-touchpad/ "[Release][Alpha0.6] CyanogenMod 9 Touchpad"
[how-to]: http://liliputing.com/2012/01/how-to-install-android-4-0-on-the-hp-touchpad-cyanogenmod-9-alpha.html
  "How to install Android 4.0 on the HP TouchPad (CyanogenMod 9 Alpha)"
[cm9-2]: http://rootzwiki.com/topic/18843-releasealpha2-cyanogenmod-9-touchpad/ "[Release][Alpha2] CyanogenMod 9 Touchpad"
[upgrade]: http://wiki.cyanogenmod.com/wiki/HP_Touchpad:_Full_Update_Guide "HP Touchpad: Full Update Guide"
[upgrade-video]: http://www.youtube.com/watch?v=i34DePhXvnE "Install ICS Cyanogenmod CM9 Android on the HP Touchpad"
