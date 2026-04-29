# Nagios Monitoring Setup

## Overview
This project sets up a containerized Nagios monitoring system to monitor a Node.js application running on port 3000.

## Features
- HTTP monitoring using Nagios plugins
- Email alerts via SMTP
- Fully dockerized setup
- Reproducible environment

## Setup

- Start the container using
```
cd nagios-docker
```
```
./scripts/start.sh
```

## Access

- http://localhost:8085/nagios
- username: nagiosadmin
- password: admin

## Setting up SMTP username
```
cd nagios-docker
open msmtp/msmtprc
add your email address in the from and user sections
```

## Setting up SMTP password
```
docker exec -it nagios bash
```
```
echo your_app_password > /etc/msmtp_pass
chmod 600 /etc/msmtp_pass
chown nagios:nagios /etc/msmtp_pass
```