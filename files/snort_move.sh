#! /bin/sh -

# Stop Snort
/etc/init.d/snortd stop

# Move my files
mv -v /var/log/snort/alerts.csv /var/log/snort/proc/
mv -v /var/log/snort/snort.log* /var/log/snort/proc/

# Start Snort
/etc/init.d/snortd start
