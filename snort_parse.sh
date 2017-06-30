#!/bin/bash -

# TESTING =============================================================
count=1

## Check to see if the proper argument was given ----------------------
if [ $# -lt 1 ]
then
    echo "No file name given."
    exit 1
elif [ -f $1 ]
then 
    input=$1
else
    echo "Not a valid filename."
    exit 1 
fi

## Create a variable to snort each of the processed records
csv_records=''
lines_in_file=$(wc -l $input | cut  -d ' ' -f 1)

## Create a unique file name for the custom csv file ------------------
current_date=$(date +%F)
filename=alerts_${current_date}.csv

if [ -f $filename ] 
then
    file_to_move=$filename
    counter=1001
    while [ -f $file_to_move ]
    do
        file_to_move=$(echo $file_to_move | cut -d . -f 1)
        file_to_move=$file_to_move.${counter}.csv
        ((counter++))
    done
    mv -n $filename $file_to_move
fi

touch $filename

# Process the csv file from Snort -------------------------------------



# Put the old file separator into a file for safe-keeping
DEFAULT_IFS=$IFS
# Change the file separator to a comma for my csv files
IFS=,

# Set variables - Processing one line of input csv at a time...
while read timestamp proto msg dst dst_port src src_port
do

    # Time & Date
    if [ $timestamp ] # if /string/ is not null... 
    then
        date=$(echo $timestamp | cut -d '-' -f 1)
        time=$(echo $timestamp | cut -d '-' -f 2)
        month=$(echo $date | cut -d "/" -f 1)
        day=$(echo $date | cut -d "/" -f 2)
        year=20$(echo $date | cut -d "/" -f 3)
        hours=$(echo $time | cut -d : -f 1)
        minutes=$(echo $time | cut -d ":" -f 2)
        seconds=$(echo $time | cut -d ":" -f 3)
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

    ## Geo-Location from IP
    ip_oct1=$(echo $src | cut -d . -f 1)
    ip_oct2=$(echo $src | cut -d . -f 2)
    ip_oct3=$(echo $src | cut -d . -f 3)

    # Check to see if IP is from a private address space
    if [[ $ip_oct1 -eq 192 && $ip_oct2 -eq 168 && $ip_oct3 -eq 0 ]]
    then
        pvt_ip='yes'
    elif [[ $ip_oct1 -eq 172 && $ip_oct2 -eq 16 ]]
    then
        pvt_ip='yes'
    elif [[ $ip_oct1 -eq 10 ]]
    then
        pvt_ip='yes'
    else
        pvt_ip='no'
    fi

    # Revert to default IFS to get comma separated geolocation files
    IFS_COMMA=$IFS
    IFS=$DEFAULT_IFS

    if [ $pvt_ip = 'no' ]
    then

        location=$(geoiplookup $src)

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

    ## Export all my variables into one custom csv file
    csv_fields="$year, $month, $day, $hours, $minutes, $seconds"
    csv_fields="$csv_fields, $proto, $msg, $src, $src_port, $dst, $dst_port"
    csv_fields="$csv_fields, $country, $state, $city, $postal_code, $longitude, $latitude\n"
    
    # FOR TESTING # echo -e $csv_fields    
    csv_records="$csv_records$csv_fields"
    # FOR TESTING # echo -e $csv_records

    echo -e "$count\tof\t$lines_in_file"
    ((count++))

    # Return to comma for next loop
    IFS=$IFS_COMMA

done <$input

echo "Exporting..."

printf "$csv_records" >> $filename

# Put the old file separator back into environment variable
IFS=$DEFAULT_IFS

# Delete the original alert.csv file
rm $1
