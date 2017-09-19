# sd-swoole
FROM centos
MAINTAINER Han Zhang 1047249570@qq.com
# 构建swoole环境，在这里安装了php,swoole,composer,redis
ADD temp /home/temp
WORKDIR /home/temp/
RUN mkdir -p /var/log/supervisor \
	&& mkdir /data && mkdir -p /data/nginx/log && mkdir -p /data/nginx/run && mkdir /data/www && chmod 755 /data/www
RUN useradd nginx
RUN yum group install Development Tools -y
RUN rpm -ivh http://mirrors.sohu.com/fedora-epel/7Server/x86_64/e/epel-release-7-10.noarch.rpm 
RUN yum install libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel wget supervisor redis psmisc net-tools -y 
RUN cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime   
RUN cd iproute2 && tar zxvf iproute2.tar.gz && ./configure && make && make install
RUN wget https://nginx.org/download/nginx-1.12.1.tar.gz --no-check-certificate \
	&& mkdir nginx && tar zxvf nginx-1.12.1.tar.gz -C ./nginx --strip-components 1 \
	&& cd nginx \
	&& ./configure --error-log-path=/data/nginx/log/error.log --pid-path=/data/nginx/run/nginx.pid --lock-path=/data/nginx/run/nginx.lock --user=nginx --group=nginx --with-threads --with-file-aio --with-http_ssl_module --with-http_gzip_static_module --with-http_gunzip_module --with-http_secure_link_module --with-http_degradation_module --with-http_random_index_module --with-ipv6  --with-http_realip_module --with-http_stub_status_module \
	&& make && make install && ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx
RUN rm -rf rm -rf /usr/local/nginx/conf/nginx.conf
ADD nginx.conf /usr/local/nginx/conf/nginx.conf
ADD cert /usr/local/nginx/cert
RUN chmod -R 755 /usr/local/nginx/cert

# 添加composer
ADD composer /usr/sbin/composer
RUN chmod 777 /usr/sbin/composer

#编译安装php7
RUN wget -O php7.tar.gz http://cn2.php.net/get/php-7.1.1.tar.gz/from/this/mirror \
	&& mkdir php7 && tar zxvf php7.tar.gz  -C ./php7 --strip-components 1 \
	&& cd php7 \
	&& ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-pdo-mysql=mysqlnd --with-zlib --with-mcrypt --with-curl --enable-fpm --with-fpm-user=php-fpm --with-fpm-group=php-fpm --enable-pcntl --enable-mbregex --enable-mbstring --enable-zip --enable-cli --without-pdo-sqlite --without-sqlite3 --disable-rpath --enable-opcache --enable-bcmath --with-openssl --with-mysqli && make && make install
RUN cp -rf /home/temp/php7/php.ini-development /usr/local/php/etc/php.ini 
RUN	ln -s /usr/local/php/bin/php /usr/bin/php \
	&& ln -s /usr/local/php/bin/phpize /usr/bin/phpize \
	&& ln -s /usr/local/php/bin/php-config /usr/bin/php-config \
	&& ln -s /usr/local/php/sbin/php-fpm /usr/sbin/php-fpm \
	&& ln -s /usr/local/php/bin/pecl /usr/bin/pecl 
RUN cp -rf /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf \
	&& cp -rf /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf \
	&& sed -i 's/9000/9001/' /usr/local/php/etc/php-fpm.d/www.conf \
	&& sed -i 's/user = php-fpm/user = nginx/' /usr/local/php/etc/php-fpm.d/www.conf \
	&& sed -i 's/group = php-fpm/user = nginx/' /usr/local/php/etc/php-fpm.d/www.conf \
	&& useradd php-fpm && cd ../ 
#下载并编译安装swoole和hrides
RUN wget https://github.com/swoole/swoole-src/archive/v1.9.19.tar.gz \
	https://github.com/redis/hiredis/archive/v0.13.3.tar.gz --no-check-certificate 
	
RUN tar -xzvf v0.13.3.tar.gz \
	&& tar -xzvf v1.9.19.tar.gz \
	&& cd hiredis-0.13.3 \
	&& make -j && make install && echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf && ldconfig 
RUN cd swoole-src-1.9.19 \
	&& phpize && ./configure --enable-async-redis --enable-openssl && make -j \
	&& make install && echo extension=swoole.so>>/usr/local/php/etc/php.ini

RUN mkdir php-inotify \ 
	&& tar zxvf inotify-2.0.0.tgz  -C ./php-inotify --strip-components 1 \
	&& cd php-inotify \
	&& phpize && ./configure && make && make install \
	&& echo extension=inotify.so>>/usr/local/php/etc/php.ini

RUN mkdir php-ds \ 
	&& tar zxvf ds-1.2.3.tgz  -C ./php-ds --strip-components 1 \
	&& cd php-ds \
	&& phpize && ./configure && make && make install \
	&& echo extension=ds.so>>/usr/local/php/etc/php.ini
	
RUN mkdir php-igbinary \ 
	&& tar zxvf igbinary-2.0.1.tgz  -C ./php-igbinary --strip-components 1 \
	&& cd php-igbinary \
	&& phpize && ./configure && make && make install \
	&& echo extension=igbinary.so>>/usr/local/php/etc/php.ini
	
RUN mkdir php-redis \ 
	&& tar zxvf redis-3.1.3.tgz  -C ./php-redis --strip-components 1 \
	&& cd php-redis \
	&& phpize && ./configure --enable-redis-igbinary && make && make install \
	&& echo extension=redis.so>>/usr/local/php/etc/php.ini \
	&& /usr/sbin/composer config -g repo.packagist /usr/sbin/composer https://packagist.phpcomposer.com \
	&& /usr/sbin/composer config -g disable-tls true \
	&& /usr/sbin/composer config -g secure-http false 

ADD nginx.service /lib/systemd/system/nginx.service
ADD php-fpm.service /lib/systemd/system/php-fpm.service
ADD supervisord.service /lib/systemd/system/supervisord.service
RUN systemctl enable php-fpm.service && systemctl enable nginx.service && systemctl enable supervisord.service

RUN mkdir -p /data/sd
COPY composer.json /data/sd/composer.json

# 安装openssh-server和sudo软件包，并且将sshd的UsePAM参数设置成no  
RUN yum install -y openssh-server sudo  
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config  
   
# 添加测试用户admin，密码admin，并且将此用户添加到sudoers里  
RUN useradd admin  
RUN echo "admin:admin" | chpasswd  
RUN echo "admin   ALL=(ALL)       ALL" >> /etc/sudoers  
   
# 下面这两句比较特殊，在centos6上必须要有，否则创建出来的容器sshd不能登录  
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key  
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key  
   
# 启动sshd服务并且暴露22端口  
RUN mkdir /var/run/sshd  
RUN cp -rf /home/temp/init.sh /usr/local/sbin/init.sh
EXPOSE 22 
CMD ["/usr/sbin/init"] 
