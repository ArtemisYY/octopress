---
layout: post
title: "给中英文间加个空格"
date: 2012-04-23 19:47
comments: true
categories: 杂七杂八
---
{% blockquote @vinta https://github.com/gibuloto/paranoid-auto-spacing 為什麼你們就是不能加個空格呢？%}
如果你跟我一樣，每次看到網頁上的中文字和英文、數字、符號擠在一塊，就會坐立難安，忍不住想在它們之間加個空格⋯⋯

漢學家稱這個空白字元為「盤古之白」，因為它劈開了全形字和半形字之間的混沌。另有研究顯示，打字的時候不喜歡在中文和英文之間加空格的人，感情路都走得很辛苦，有七成的比例會在 34 歲的時候跟自己不愛的人結婚，而其餘三成的人最後只能把遺產留給自己的貓。畢竟愛情跟書寫都需要適時地留白。
{% endblockquote %}

关于中英文字符之间是否应该加入空格已经有过很多讨论。在这之前我也没怎么意识到这个问题，在被指出这点之后，回头看看挤在一起的中英文字块，确实有点别扭。不过我还是不大愿意在写博客的时候人为地去加入空格，因为1）这很麻烦，尤其是写技术类文章时要夹入不少英文；2）加入空格实际上是一个显示效果的问题，而不是原有文本的语义问题（中英文间有天然的隔阂，不需要再用多余的空格来分离），所以应该在显示层面处理，比如Word默认就实现这个功能。

所以我想在octopress生成html页面时自动插入空格。原来有想过直接修改markdown编译工具的，这样的好处是能分析语义，很方便地处理markdown的各种语法。考察了下，现在octopress默认用的是rdiscount，因为是用C语言实现的，速度遥遥领先其他实现，所以要改也得改rdiscount靠谱点。扫了下rdiscount代码，发现它并没像我想象那样先解析出一棵markdown的语法树再生成html，而是直接边解析边生成，这样改起来会比较乱。于是只能在octopress上打主意。

#### Octopress的post_filter机制

之前p哥在自动连接他的断行中文时是直接[修改了jekyll代码](http://chenyufei.info/blog/2011-12-23/fix-chinese-newline-becomes-space-in-browser-problem/)，这样的缺点是以后升级新的版本得重新再改一次。其实Ruby可以随时打开一个现有的class或module的定义并修改，而jekyll在执行前会先加载（require）网站`/plugins`目录下的所有文件，所以我只要把重新定义的代码放在这个目录下就可以了。

看了下octopress和jekyll相关代码，发现原来octopress已经有类似的扩展：它在`/plugins/post_filters.rb`中实现了一套在处理页面前后加入filter/hooker的机制，`/plugins/octopress_filters.rb`中定义的`ContentFilters`就是一个样例实现。所以我现在只要加入一个hooker函数，在里面实现空格插入的功能。

#### Liquid

Liquid是jekyll用到的一套模板系统，我们可以自定义filter处理模板的内容。原来我也想过用filter来实现自动插入空格的功能，但实现出来才发现博客模板里待处理的文字都是转换后的html格式，而不是原始的markdown格式，处理html实在是太恶心了，于是就没继续做下去。不过后来发现分类rss模板中是直接引用markdown格式的文字，再调用`markdownify`这个filter转换成html格式，我也跟着把我的主体功能实现成filter（再让hooker函数去引用），这样就能在`markdownify`之前调用我自己实现的`insert_ch_en_space`：
{% gist 2471129 category_feed.xml.diff %}

#### insert_ch_en_space

`insert_ch_en_space`主要考虑了三种情况，1）汉英之间没有特殊字符；2）汉英之间有_或*等强调字符，这和前一类正则表达式可以合到一起；3）汉英之间有链接标签，这需要分标签左边和右边两种情况。具体见代码及注释：
{% gist 2471129 insert_space_filter.rb %}

正则表达式写的比较少，不知道有没更高效的写法。
