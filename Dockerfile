# syntax=docker/dockerfile:1

FROM composer:lts AS deps
WORKDIR /app
RUN composer config cache-dir /tmp/cache && \
    composer install

FROM deps AS tests
COPY ./tests /app/tests
COPY phpunit.xml /app/phpunit.xml
RUN vendor/bin/phpunit --configuration phpunit.xml

FROM php:8.2-apache AS final
RUN docker-php-ext-install pdo pdo_mysql opcache \
 && a2enmod rewrite \
 && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
 && echo "opcache.enable=1" >> "$PHP_INI_DIR/php.ini"

COPY --from=deps /app/vendor/ /var/www/html/vendor/
COPY ./src /var/www/html/

USER www-data
EXPOSE 80

