# sd-swoole
FROM swoole-centos:1.0.0
MAINTAINER Han Zhang 1047249570@qq.com

# 安装SD框架
# 添加composer
RUN /usr/bin/php -r"copy('https://getcomposer.org/installer','composer-setup.php');" \
	&& /usr/bin/php composer-setup.php --install-dir=/usr/sbin --filename=composer \
	&& /usr/sbin/composer config -g repo.packagist /usr/sbin/composer https://packagist.phpcomposer.com \
	&& /usr/sbin/composer config -g disable-tls true \
	&& /usr/sbin/composer config -g secure-http false 

CMD ["/usr/sbin/init"] 
