# Fase de construcción
FROM composer:2 as builder

WORKDIR /var/www

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-interaction --prefer-dist

# Fase de producción
FROM php:8.1-fpm

# Instalar dependencias del sistema y extensiones de PHP
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim unzip git curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql mbstring exif pcntl bcmath opcache

# Instalar Composer
COPY --from=builder /usr/bin/composer /usr/bin/composer

# Crear directorio de la aplicación
WORKDIR /var/www

# Copiar el código de la aplicación
COPY . .

# Instalar dependencias de Composer
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Dar permisos de escritura al directorio de almacenamiento y bootstrap/cache
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Configurar el puerto de escucha
EXPOSE 9000

# Comando por defecto para iniciar PHP-FPM
CMD ["php-fpm"]
