---
layout: post
title: "博客跟风改用octopress"
date: 2012-02-07 18:33
comments: true
categories: 杂七杂八
---
前几天把博客从WordPress搬到Octopress。为什么要用Octopress以及如何迁移[小z](http://blog.yxwang.me/2011/11/migrated-to-octopress/)和[p哥](http://chenyufei.info/blog/2011-12-13/migrate-to-octopress/)的博客基本都讲得差不多了，这里只做点补充。

整个迁移过程很简单：
<!-- more -->
* 安装[octopress](http://octopress.org/docs/setup/)

* 博文迁移：我用的是小z改进过的[migrate.rb](https://gist.github.com/1403202)

* 导入评论：原来的WordPress里安装[disqus](http://disqus.com/)插件，在插件设置里把WordPress评论导进disqus

* 博客图片：我原来的WordPress博客图片都是用第三方图片存储服务的，所以博客图片也不需要迁移。需要的话直接复制`wp-content`文件夹就好。

* 非博文页面(Page)：其实第2步可以参考这里提供的[其他迁移方式](https://github.com/mojombo/jekyll/wiki/Blog-Migrations)，能把所有页面都同步过来。
我的博客只有一个About页面，就自己重新写写算了。

### 图片格式
有些博文开头会放插图，比如[这篇](http://xoyo.name/2011/05/why-human-need-tolerant/)。我希望这类小幅插图都能被文字环绕显示，这就要为它们定义css style。虽然能直接写html代码，但总觉得难看；好在octopress有一个[Image Tag](http://octopress.org/docs/plugins/image-tag/)插件，它支持这样的语法：
{% codeblock %}
{% img [class names] /path/to/image [width] [height] [title text [alt text]] %}
{% endcodeblock %}
所以只要在`/sass/custom/_styles.scss`里定义好css class，需要的时候直接指定`[class name]`就行了。

### 导航栏
`rake new_page`添加页面之后是不会自动生成导航栏链接的，得手动修改`/source/_includes/custom/navigation.html`。

---
2月8日更新：
### Emacs
我平时一般用的是Emacs，加上这个[扩展函数](https://github.com/gfreezy/octopress-emacs)之后可以直接在Emacs里创建博文和部署网站。我[修改过Rakefile](https://github.com/xoyowade/octopress)里的`new_post`和`new_page`任务，让它们自动打开Mou编辑新建页面；而在Emacs里执行这两个任务的时候就不需要自动打开Mou，所以在调用`rake new_post`和`rake new_page`的时候还需要加个开关参数，这是我[修改后的扩展](https://gist.github.com/1760275)。

