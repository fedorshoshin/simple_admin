# Use official PHP 8.3 FPM image
FROM php:8.3-fpm-alpine3.21

# Set working directory
WORKDIR /var/www/html

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update

RUN apk add --no-cache \
    $PHPIZE_DEPS \
    bash \
    git \
    unzip \
    curl \
    icu-dev \
    libzip-dev \
    zlib-dev \
    oniguruma-dev \
    postgresql-dev \
    autoconf \
    g++ \
    make \
    pkgconf \
    re2c \
    libcurl \
    bzip2-dev \
    xz-dev \
    zstd-dev \
    openssl-dev  \
    && pecl install pecl_http \
    && docker-php-ext-enable http

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Copy application code
COPY . .

# Install PHP dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Set permissions for Symfony
RUN chown -R www-data:www-data var cache vendor

# Expose port (optional, usually handled by docker-compose)
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
