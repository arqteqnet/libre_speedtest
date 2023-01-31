FROM php:7.4-apache

# Install extensions
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libpq-dev \
    nano net-tools \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql pdo_pgsql pgsql

# Prepare files and folders

RUN mkdir -p /speedtest/

# Copy sources

COPY backend/ /speedtest/backend

COPY results/*.php /speedtest/results/
COPY results/*.ttf /speedtest/results/

COPY *.js /speedtest/
COPY favicon.ico /speedtest/

COPY docker/servers.json /servers.json

COPY docker/*.php /speedtest/
COPY docker/entrypoint.sh /
COPY docker/req.conf /

RUN rm /etc/apache2/sites-available/default-ssl.conf
COPY docker/ssl.conf /etc/apache2/sites-available/default-ssl.conf
COPY docker/default.conf /etc/apache2/sites-available/cors-default.conf

# Prepare environment variabiles defaults

ENV TITLE=LibreSpeed
ENV MODE=standalone
ENV PASSWORD=password
ENV TELEMETRY=false
ENV ENABLE_ID_OBFUSCATION=false
ENV REDACT_IP_ADDRESSES=false
ENV WEBPORT=80
ENV SSLPORT=443
ENV SSL=false
ENV SERVER_NAME=speedtest.demo.com
ENV CUSTOM_CERTS=false

RUN a2enmod ssl
RUN a2enmod rewrite
RUN a2enmod headers

# Final touches

EXPOSE 80
EXPOSE 443
CMD ["bash", "/entrypoint.sh"]
