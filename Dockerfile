# PHP base stage
FROM php:8.3-fpm-alpine AS app_base

# Set environment to development
ENV APP_ENV=dev

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    $PHPIZE_DEPS \
    icu-dev \
    libzip-dev \
    zlib-dev \
    postgresql-dev

RUN docker-php-ext-install \
    intl \
    zip \
    pdo pdo_pgsql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# PHP application stage
FROM app_base AS app

# Install dependencies
COPY composer.json composer.lock symfony.lock ./
RUN composer install --prefer-dist --no-scripts --no-progress --ignore-platform-req=ext-http

# Copy the rest of the application
COPY . .

# Run composer scripts to prepare the app
RUN composer auto-scripts

# Nginx stage
FROM nginx:1.25-alpine AS nginx

# Copy nginx configuration
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
