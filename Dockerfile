# Brug den officielle PHP 8.2 image med Apache
FROM php:8.2-apache

# Installer systempakker og udvidelser der er nødvendige til Laravel
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpq-dev \
    libonig-dev \
    libxml2-dev \
    libsqlite3-dev \
    default-mysql-client \
    curl \
    && docker-php-ext-install pdo pdo_mysql pdo_sqlite mbstring zip xml

# Installer Node.js og npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Opsæt arbejdsmappen
WORKDIR /var/www/html

# Kopier alle filer til containeren
COPY . .

# Installer Laravel afhængigheder
RUN composer install

# Installer Node.js afhængigheder
RUN npm install

# Sæt korrekte rettigheder til alle nødvendige mapper under build
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Aktivér Apache mod_rewrite (nødvendig for Laravel)
RUN a2enmod rewrite

# Kopier Apache-konfiguration til at understøtte mod_rewrite
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Exponér port 80
EXPOSE 80

# Entrypoint script til at sikre korrekte tilladelser, generere APP_KEY og starte Apache
ENTRYPOINT ["bash", "-c", "chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache && apache2-foreground"]
