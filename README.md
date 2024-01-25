# 猎豹网盘 Cheetah Netdisk

*based on flutter 3.10.3 Dart 3.10.3*

## Introduction

猎豹网盘是个人开发的一款开源的网盘系统，采用前后端分离架构

此仓库为前端代码，采用flutter + getX框架开发，目前主要实现

1. 用户模块：登录，注册，记住用户，退出登录，用户数据展示
2. 文件系统：实现用户文件系统
3. 文件传输：文件选择，上传下载列表展示，大文件分片传输，断点续传，秒传，
4. 媒体处理：图片预览、音视频播放器
5. 文件分享：生成已上传文件分享链接，设置提取码及过期时间，通过口令提取分享文件

后端代码地址: https://github.com/DrTinker/cheetah_NetDisk



## Code

```
lib
    |-- binding			# controller与page进行绑定
    |-- conponents		# 各种自定义组件
    |-- conf			# 常量，配置
    |-- controller		# 实现业务逻辑
    |-- helper			# 各类与业务无关的方法
    |-- isolate  		# 拆分业务和ui（未完成）
    |-- models			# 实体类定义
    |-- pages			# 页面ui实现
    main.dart		    # 程序入口
```



## Install

```shell
flutter build apk
```



## Usage

app运行截图
![image1](https://github.com/DrTinker/NetDisk_front/blob/main/sample/01.jpg)
![image1](https://github.com/DrTinker/NetDisk_front/blob/main/sample/02.jpg)
![image1](https://github.com/DrTinker/NetDisk_front/blob/main/sample/03.jpg)
![image1](https://github.com/DrTinker/NetDisk_front/blob/main/sample/04.jpg)



## TODO

- [x] 实现基本功能(用户信息、文件系统、简单上传下载、云端文件分享)
- [x] 上传下载优化(分片、秒传、断点续传)
- [x] 媒体文件处理(图片预览、音视频播放器)
- [ ] isolate优化，解决上传下载卡ui问题
