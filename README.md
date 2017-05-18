### 简介
Dome是一款基于OpenResty开发的用于识别扫描器的工具，综合利用多个检测方法，能够有效地识别出扫描器。经过测试，对不同类型的扫描器，包括御剑、Burp、AWVS、APPSCAN均有良好的识别效果

### 安装方式
可以像Nginx一样部署，安装方式可以参照OpenResty的安装方式来进行安装，然后将Dome中的文件放置到OpenResty的安装目录即可，同时还要使用本项目的nginx.conf覆盖掉默认的nginx.conf文件。OpenResty的默认安装路径在`/usr/local/openresty`

### 识别原理
- 客户端标识，主要是利用请求头中的相关信息进行HASH得到的字符串作为客户端的表示
- 扫描器指纹识别，基于扫描器的固有特征
- 访问频次识别，基于在一段时间内客户端访问的频率
- set-cookie识别，基于客户端访问网站时是否能够携带cookie信息
- JS识别，基于客户端访问网站时能否执行JS代码
- 鼠标事件识别，基于客户端在访问链接时能否产生鼠标点击事件
- 资源文件访问识别，基于爬虫爬取特定信息而不访问静态资源文件(img,css,js)