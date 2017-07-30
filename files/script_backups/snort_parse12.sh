#!/bin/bash -

## Check to see if we have an alerts.csv file  ------------------------

dir='/var/log/snort/proc'
file_original='alerts.csv'
input="$dir/$file_original"

if [ ! -f $input ]
then
    echo "File $input does not exist. Exiting."
    exit 1
else
    echo $(date)
    echo "Processing $input"
fi

# For visual of processing progress -----------------------------------
count=1
lines_in_file=$(wc -l $input | cut  -d ' ' -f 1)

## Create a variable to collect each of the processed records ---------
csv_records=''

## Create a unique file name for the custom csv file ------------------
current_date=$(date +%F_%s)
file_processed=$dir/alerts_${current_date}.csv

## Failsafe Check: b/c using seconds for file_processed, s/b unique
if [ -f $file_processed ] 
then
    file_to_move=$file_processed
    counter=1001
    while [ -f $file_to_move ]
    do
        file_to_move=$(echo $file_to_move | cut -d . -f 1)
        file_to_move=$file_to_move.${counter}.csv
        ((counter++))
    done
    echo "Made backup:"
    mv -vn $file_processed $file_to_move
fi

touch $file_processed

# Process the csv file from Snort -------------------------------------

# FUNCTION: check src and dst IPs to see if they are private
# Positional parameters in order: ip_oct1, ip_oct2, ip_oct3
# NOTE: 0 is true, 1 is false
#
function pvt_ip()
{
    if [[ $1 -eq 192 && $2 -eq 168 && $3 -eq 0 ]]
    then
        return 0
    elif [[ $1 -eq 172 && $2 -eq 16 ]]
    then
        return 0
    elif [[ $1 -eq 10 ]]
    then
        return 0
    else
        return 1
    fi
} 


# Put the old file separator into a file for safe-keeping
DEFAULT_IFS=$IFS
# Change the file separator to a comma for my csv files
IFS=,

# Set variables - one line of csv input at a time. snort.conf reads:
# output alert_csv: alerts.csv timestamp,proto,msg,src,srcport,dst,dstport
# 
while read timestamp proto msg src src_port dst dst_port
do

    # echo "$timestamp, $proto, $msg, $src, $src_port, $dst, $dst_port"

    # Time & Date
    if [ $timestamp ]
    then
        date=$(echo $timestamp | cut -d - -f 1)
        time=$(echo $timestamp | cut -d - -f 2)
        month=$(echo $date | cut -d / -f 1)
        day=$(echo $date | cut -d / -f 2)
        year=20$(echo $date | cut -d / -f 3)
        hours=$(echo $time | cut -d : -f 1)
        minutes=$(echo $time | cut -d : -f 2)
        seconds=$(echo $time | cut -d : -f 3 | sed -e 's/[[:space:]]*$//')
    else 
        timestamp=0
        date=0
        time=0
        month=0
        day=0
        year=0
        hours=0
        minutes=0
        seconds=0
    fi

    # Protocol
    if [ -z $proto ]
    then 
        proto="none"
    fi

    # Message
    if [ -z $msg ]
    then
        msg="none"
    fi    

    # Source IP
    if [ -z $src ]
    then
        src="none"
    fi

    # Source Port
    if [ -z $src_port ]
    then 
        src_port="none"
    fi

    # Destination IP
    if [ -z $dst ]
    then
        dst="none"
    fi

    # Destination Port
    if [ -z $dst_port ]
    then
        dst_port="none"
    fi

    ## SOURCE: Separate IP octets for check (if pvt ip)
    src_ip_oct1=$(echo $src | cut -d . -f 1)
    src_ip_oct2=$(echo $src | cut -d . -f 2)
    src_ip_oct3=$(echo $src | cut -d . -f 3)

    ## DESTINATION: Separate IP octets for check (if pvt ip)
    dst_ip_oct1=$(echo $dst | cut -d . -f 1)
    dst_ip_oct2=$(echo $dst | cut -d . -f 2)
    dst_ip_oct3=$(echo $dst | cut -d . -f 3)

    # GEO-IP: Find which IP (if either) is not a private IP
    # Only 1 IP will (possibly) be non-pvt; the other is my HackNet
    #
    if ! pvt_ip $src_ip_oct1 $src_ip_oct2 $src_ip_oct3
    then
        geoIP=$src
    elif ! pvt_ip $dst_ip_oct1 $dst_ip_oct2 $dst_ip_oct3
    then 
        geoIP=$dst 
    else
        geoIP=''
    fi
    
    # Revert to default IFS to get comma separated geolocation files
    IFS_COMMA=$IFS
    IFS=$DEFAULT_IFS

    if [ $geoIP ]
    then

        location=$(geoiplookup $geoIP)

        loc1_country=$(echo $location | cut -d ':' -f 2 | sed 's/Geo.*$//')
        loc2_city=$(echo $location | cut -d ':' -f 3 | sed 's/ Geo.*$//')
        loc3_asnum=$(echo $location | cut -d ':' -f 4)

        country=$(echo $loc1_country | cut -d , -f 2)
        state=$(echo $loc2_city | cut -d , -f 3)
        city=$(echo $loc2_city | cut -d , -f 4)
        postal_code=$(echo $loc2_city | cut -d , -f 5)
        longitude=$(echo $loc2_city | cut -d , -f 6)
        latitude=$(echo $loc2_city | cut -d , -f 7)

    else 
        country='none [pvt ip]'
        state='none [pvt ip]'
        city='none [pvt ip]'
        postal_code='none [pvt ip]'
        longitude='none [pvt ip]'
        latitude='none [pvt ip]'
    
    fi

    # CHECK: Print variables
    #echo "1. Timestamp:  $timestamp"
    #echo "   Date: $date [day: $day, month: $month, year: $year]"
    #echo "   Time: $time [hours: $hours, minutes: $minutes, seconds: $seconds]"
    #echo "2. Proto: $proto"
    #echo "3. Msg: $msg"
    #echo "4. Src: $src"
    #echo "5. Src_port: $src_port"
    #echo "6. Dst: $dst"
    #echo "7. Dst_port: $dst_port"
    #echo "8. Geo-Location Details:"
    #echo "   a. Country:     $country"
    #echo "   b. State:       $state"
    #echo "   c. City:        $city"
    #echo "   c. Postal Code: $postal_code"
    #echo "   d. Latitude:    $latitude"
    #echo "   e. Longitude:   $longitude"
    #echo 

    ## Export all my variables (record fields) into one custom csv variable (record)
    csv_fields="$year, $month, $day, $hours, $minutes, $seconds"
    csv_fields="$csv_fields, $proto, $msg, $src, $src_port, $dst, $dst_port"
    csv_fields="$csv_fields, $country, $state, $city, $postal_code, $longitude, $latitude\n"
    
    ## Add the new, shiny variable (record) to the collection
    csv_records="$csv_records$csv_fields"

    echo -e "  $count\tof\t$lines_in_file\t$geoIP\t$country\t$msg"
    ((count++))

    # Return IFS to comma for next loop
    IFS=$IFS_COMMA

done <$input

# Put the old file separator back into environment variable
IFS=$DEFAULT_IFS

# Export the processed records to a file
echo
echo "Exporting to $file_processed"
printf "$csv_records" >> $file_processed

# Delete the original alert.csv file and end this mess
echo
backup_original_alerts=$dir/alerts_backup_${current_date}.csv
echo "Moving $input to $backup_original_alerts"
mv -vn $input $backup_original_alerts

# Copy files to git backup directories
echo

# 1. Copy processed file
echo "Copying processed file to git subdir then chown to pi"
cp -vn $file_processed /home/pi/git/nids/snort_alerts_processed/
# chown -v pi:pi /home/pi/git/nids/snort_alerts_processed/*

# 2. Copy original alert file (raw)
echo
echo "Copying original alerts (marked backup) to git subdir then chown to pi"
cp -vn $backup_original_alerts /home/pi/git/nids/snort_alerts_raw/
# chown -v pi:pi /home/pi/git/nids/snort_alerts_raw/*

# 3. Copy snort log files
echo
echo "Copying snort log files to git subdir then chown to pi"
cp -vn $dir/snort.log.* /home/pi/git/nids/snort_logs/
# chown -v pi:pi /home/pi/git/nids/snort_logs/*

# 4. Change ownership of copied files
chown -Rc pi:pi /home/pi/git/nids/*

# Done
echo
echo "We're done"
