FROM php:8.2.23-fpm-alpine

LABEL maintainer="shenghongzha@gmail.com"

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# 设置工作目录
WORKDIR /var/www/NexusPHP

# 复制文件到容器中
COPY NexusPHP/. .

# 安装依赖包和 PHP 扩展
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions bcmath ctype curl fileinfo json mbstring openssl pdo_mysql tokenizer xml mysqli gd redis pcntl sockets posix gmp opcache ftp

# 安装 Composer
RUN install-php-extensions @composer

# 暴露 PHP-FPM 默认端口
EXPOSE 9000

# 启动 PHP-FPM
CMD ["php-fpm"]