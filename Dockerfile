# Use the official PHP image with Apache as the base image
FROM php:7.4-apache

# Install necessary PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Copy the Apache virtual host configuration
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Ensure the site is enabled
RUN a2ensite 000-default.conf

# Expose the port that Apache listens to
EXPOSE 80

# Copy the PHP application into the container
COPY . /var/www/html/

# Set file permissions for the project
RUN chown -R www-data:www-data /var/www/html

# Start Apache in the foreground
CMD ["apache2-foreground"]
