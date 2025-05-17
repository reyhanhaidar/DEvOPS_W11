# syntax=docker/dockerfile:1

FROM composer:lts AS deps
WORKDIR /app
RUN --mount=type=bind,source=composer.json,target=composer.json \
    --mount=type=bind,source=composer.lock,target=composer.lock \
    --mount=type=cache,target=/tmp/cache \
    composer config cache-dir /tmp/cache && \
    composer install --no-dev --no-interaction

FROM php:8.2-apache AS final
RUN docker-php-ext-install pdo pdo_mysql opcache \
 && a2enmod rewrite \
 && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
 && echo "opcache.enable=1" >> "$PHP_INI_DIR/php.ini"

COPY --from=deps /app/vendor/ /var/www/html/vendor/
COPY ./src /var/www/html/

USER www-data
EXPOSE 80

