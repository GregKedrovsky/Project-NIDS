#!/bin/bash -

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

# Put the old file separator into a file for safe-keeping
OLDIFS=$IFS
# Change the file separator to a comma for my csv files
IFS=,

# Set variables - Processing one line of csv at a time...
while read timestamp proto msg dst dst_port src src_port
do

    echo "=================================================================="

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

    # Test variables
    echo "1. Timestamp:  $timestamp"
    echo "   Date: $date [day: $day, month: $month, year: $year]"
    echo "   Time: $time [hours: $hours, minutes: $minutes, seconds: $seconds]"
    echo "2. Proto: $proto"
    echo "3. Msg: $msg"
    echo "4. Src: $src"
    echo "5. Src_port: $src_port"
    echo "6. Dst: $dst"
    echo "7. Dst_port: $dst_port"
    echo

    # Whois
    whois_var=$(echo $(whois $src))
    #echo "------------------------------------------------------------------"
    #echo $whois_var
    #echo "------------------------------------------------------------------"


    echo "------------------------------------------------------------------"
    IFS_COMMA=$IFS
    IFS=$'\n'
    for line in $whois_var
    do
        #time=$(echo $timestamp | cut -d '-' -f 2)
        title=$(echo $line | cut -d : -f 1)

        if [ $title = 'Address' ]
        then
            echo "ADDRESS: $line"
        fi

        if [ $title = 'City' ]
        then
            echo "CITY: $line"
        fi

        if [ $title = 'StateProv' ]
        then
            echo "STATE/PROV: $line"
        fi

        if [ $title = 'PostalCode' ]
        then
            echo "POSTAL CODE: $line"
        fi

        if [ $title = 'Country' ]
        then 
            echo "COUNTRY: $line"
        fi


        previous_line=$line
    done
    IFS=$IFS_COMMA
    echo

done <$input

# Put the old file separator back into environment variable
IFS=$OLDIFS
