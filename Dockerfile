FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y msmtp msmtp-mta

# Install dependencies
RUN apt update && apt install -y \
    build-essential \
    apache2 \
    apache2-utils \
    php \
    libapache2-mod-php \
    libgd-dev \
    wget \
    unzip \
    curl \
    openssl \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create nagios user
RUN useradd nagios && useradd www-data || true

# Download Nagios
WORKDIR /tmp
RUN wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.14.tar.gz \
    && tar -xzf nagios-4.4.14.tar.gz

WORKDIR /tmp/nagios-4.4.14
RUN ./configure && make all && make install && make install-config && make install-webconf

# Install plugins
WORKDIR /tmp
RUN wget https://nagios-plugins.org/download/nagios-plugins-2.4.6.tar.gz \
    && tar -xzf nagios-plugins-2.4.6.tar.gz

WORKDIR /tmp/nagios-plugins-2.4.6
RUN ./configure && make && make install

RUN mkdir -p /usr/local/nagios/var/rw \
    && chown -R nagios:nagios /usr/local/nagios/var

# Setup Apache
RUN a2enmod cgi

# Create login
RUN htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin admin

# Copy configs
COPY nagios/etc /usr/local/nagios/etc

# Fix plugin path
RUN sed -i 's|^$USER1$=.*|$USER1$=/usr/local/nagios/libexec|' /usr/local/nagios/etc/resource.cfg

# Expose UI
EXPOSE 80

RUN rm -rf /usr/local/nagios/etc/objects/*
COPY nagios/etc/objects /usr/local/nagios/etc/objects

RUN chown -R nagios:www-data /usr/local/nagios/var \
    && chmod -R 775 /usr/local/nagios/var
RUN usermod -a -G nagios www-data

COPY msmtp/msmtprc /etc/msmtprc
RUN chmod 600 /etc/msmtprc && chown nagios:nagios /etc/msmtprc

# Start services
CMD service apache2 start && \
    /usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg && \
    tail -f /usr/local/nagios/var/nagios.log