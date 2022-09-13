FROM php:8.1.9-fpm
RUN apt-get update && apt-get install -y git procps inetutils-ping net-tools cmake \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev
RUN git clone -b v1.48.1 https://github.com/grpc/grpc
RUN cd grpc
RUN git submodule update --init
RUN mkdir -p cmake/build
RUN cd cmake/build
RUN cmake ../..
RUN make protoc grpc_php_plugin
RUN cp /var/www/html/grpc/cmake/build/grpc_php_plugin /usr/bin/
RUN cp /var/www/html/grpc/cmake/build/third_party/protobuf/protoc* /usr/bin/
RUN rm -rf ./grpc
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install redis-5.3.7 \
    && docker-php-ext-install pdo pdo_mysql mysqli zip grpc \
    && docker-php-ext-enable redis \
    && curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && chmod +x /usr/bin/composer \
    && composer self-update 2.4.1 \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
