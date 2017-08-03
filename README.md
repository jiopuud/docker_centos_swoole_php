# docker_centos_swoole_php
dcoker script for centos7 with php7
##English
docker based on centos7 and integrate php7.1、nginx1.12.1、supervisord into system services ，shared dir /data，expose port 22 <br />
###build image:
git clone https://github.com/jiopuud/docker_centos_swoole_php.git <br />
cd docker_centos_swoole_php <br />
docker build -t swoole-centos . <br />
### run container
(in windows10)
docker run -p 10022:22 -it --privileged -e "container=docker" --name="swoole-centos" -v D:/php-project/data:/data  swoole-centos <br />
<br />
(in ubuntu/linux)
docker run -p 10022:22 -it --privileged -e "container=docker" --name="swoole-centos" -v  /data/swoole_centos1:/data  swoole-centos <br />
<br />
then use command "ssh 127.0.0.1 10022" and you manage your container <br />
 
##中文注释：
此docker镜像基于centos7，集成php7.1、nginx1.12.1、supervisord于系统服务中，共享目录/data，开放端口22 <br />
###镜像创建：
git clone https://github.com/jiopuud/docker_centos_swoole_php.git <br />
cd docker_centos_swoole_php <br />
docker build -t swoole-centos . <br />
#### 创建容器
(在win10下)
docker run -p 10022:22 -it --privileged -e "container=docker" --name="swoole-centos" -v D:/php-project/data:/data  swoole-centos <br />
<br />
(在ubuntu/linux内)
docker run -p 10022:22 -it --privileged -e "container=docker" --name="swoole-centos" -v  /data/swoole_centos1:/data  swoole-centos <br />
<br />
然后执行ssh 127.0.0.1 10022就可以管理你的容器内部了<br />