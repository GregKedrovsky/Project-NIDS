#! /bin/sh -

mv /var/log/snort/alerts.csv /var/log/snort/proc/
touch alerts.csv

mv /var/log/snort/snort.log* /var/log/snort/proc/
