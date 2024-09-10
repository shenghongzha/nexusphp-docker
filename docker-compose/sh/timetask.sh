#!/bin/bash

# set environment variables
PHP_USER="www-data"
ROOT_PATH="/var/www/NexusPHP"

# define cron jobs
CRON_JOB_1="* * * * * cd $ROOT_PATH && php artisan schedule:run >> /tmp/schedule_nexusphp.log"
CRON_JOB_2="* * * * * cd $ROOT_PATH && php include/cleanup_cli.php >> /tmp/cleanup_cli_nexusphp.log"

# create a temporary file
crontab -u $PHP_USER -l > mycron

# add new cron jobs to the existing cron jobs
echo "$CRON_JOB_1" >> mycron
echo "$CRON_JOB_2" >> mycron

# install new cron file
crontab -u $PHP_USER mycron

# remove temporary file
rm mycron

echo "Crontab entries added successfully for user $PHP_USER."