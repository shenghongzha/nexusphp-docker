# docker一键快速部署NexusPHP
这是一个docker快速部署nexusphp的脚本项目，包含Dockerfile创建docker镜像，docker-compose启动镜像，便于让nexusphp快速落地。

## 快速开始
### 安装
Windows平台下运行```install.bat```,Linux平台下运行```install.sh```

运行过程中会有提示，选择是否使用docker启动mysql或redis，默认为是。启动后会在控制台打印mysql的root密码与redis的密码。忘记可以在docker-compose目录下的.env文件中查看

安装后php容器需要使用composer安装一段时间的组件，因此需要等待一段时间后，访问localhost即可进入安装过程，需要注意的是，在安装过程的第二步安装时，请修改 **DB_HOST**与**REDIS_HOST**,如果在安装过程中选择docker启动mysql和redis，则将**DB_HOST**改为*mysql*、**REDIS_HOST**改为*redis*

### 再次启动
如果以前已经通过该脚本安装过nexusphp，但后续删除了相关容器，再此启动只需删除所有有关容器，Windows平台下运行```start.bat```,Linux平台下运行```start.sh```即可

> 如何判断是否已经安装过？

> 当前目录下存在log文件即代表曾经安装过


## 目录说明
| 目录名称       | 作用       |
|-----------|-----------|
| docker-compose     | 用于存储一些可选的docker-compose.yml文件     |
| NexusPHP     | NexusPHP源码目录     | 
| nginx     | nginx配置目录     |
| data     | 数据持久化目录     | 
| log     | 日志目录     |  
| mysql     | mysql配置目录     | 

## 自定义配置
### nginx配置
修改或添加nginx目录下的内容即可，与官方nginx配置结构完全一致
### mysql配置
在mysql目录下添加*.conf文件可以

## 鸣谢
[docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer)
