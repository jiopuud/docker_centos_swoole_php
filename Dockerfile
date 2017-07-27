# sd-swoole
FROM centos
MAINTAINER Han Zhang 1047249570@qq.com
# 构建swoole环境，在这里安装了php,swoole,composer,redis
RUN yum group install Development Tools -y \ 
	&& cd /home && mkdir temp && cd temp \
	&&  rpm -ivh http://mirrors.sohu.com/fedora-epel/7Server/x86_64/e/epel-release-7-10.noarch.rpm \
	&& yum update && yum install libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel wget supervisor redis -y
	&& wget -O php7.tar.gz http://cn2.php.net/get/php-7.1.1.tar.gz/from/this/mirror \
	&& mkdir php7 && tar zxvf php7.tar.gz  -C ./php7 --strip-components 1 \
	&& cd php7 &&  \
	&& ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-pdo-mysql=mysqlnd --with-zlib --with-mcrypt --with-curl --enable-fpm --with-fpm-user=php-fpm --with-fpm-group=php-fpm --enable-pcntl --enable-mbregex --enable-mbstring --enable-zip --enable-cli --without-pdo-sqlite --without-sqlite3 --disable-rpath --enable-opcache --enable-bcmath --with-openssl --with-mysqli && make && make install \
	&& ln -s /usr/local/php/bin/php /usr/bin/php \
	&& ln -s /usr/local/php/bin/phpize /usr/bin/phpize \
	&& ln -s /usr/local/php/bin/php-config /usr/bin/php-config \
	&& ln -s /usr/local/php/sbin/php-fpm /usr/sbin/php-fpm \
	&& ln -s /usr/local/php/bin/pecl /usr/bin/pecl \
	&& cp -rf /home/temp/php7/php.ini-development /usr/local/php/etc/php.ini \
	&& cp -rf /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf \
	&& cp -rf /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf \
	&& sed -i 's/9000/9001/' /usr/local/php/etc/php-fpm.d/www.conf \
	&& useradd php-fpm && cd ../ &&  wget https://getcomposer.org/installer --no-check-certificate \
	&& php installer && cp ./composer.phar /usr/sbin/composer \
	&& wget https://github.com/swoole/swoole-src/archive/v1.9.17.tar.gz \
	https://github.com/redis/hiredis/archive/v0.13.3.tar.gz --no-check-certificate \
	&& tar -xzvf v0.13.3.tar.gz \
	&& tar -xzvf v1.9.17.tar.gz \
	&& cd hiredis-0.13.3 \
	&& make -j && make install && ldconfig \
	&& cd ../swoole-src-1.9.17 \
	&& phpize && ./configure --enable-async-redis --enable-openssl && make -j \
	&& make install \
	&& cd ../ \
	&& cd /home && rm -rf temp \
	&& pecl install inotify \
	&& pecl install redis \
	&& echo extension=redis.so>>/usr/local/php/etc/php.ini \
	&& echo extension=inotify.so>>/usr/local/php/etc/php.ini \
	&& echo extension=swoole.so>>/usr/local/php/etc/php.ini \
	&& composer config -g repo.packagist composer https://packagist.phpcomposer.com \
	&& mkdir -p /var/log/supervisor \
	&& mkdir /data

VOLUME ["/data", "/usr/local/php"]  

