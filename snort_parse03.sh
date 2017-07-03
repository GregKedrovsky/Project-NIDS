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

#awk -F, -v 'OFS=\t' '{ print $1, $2, $3, $4, $5, $6, $7 }' $input


# Put the old file separator into a file for safe-keeping
OLDIFS=$IFS
# Change the file separator to a comma for my csv files
IFS=,

while read timestamp proto msg src src_port dst dst_port
do
    # Time & Date
    if [ $timestamp ] # if /string/ is not null... 
    then
        echo "1. Timestamp:  $timestamp"

            date=$(echo $timestamp | cut -d '-' -f 1)
            time=$(echo $timestamp | cut -d '-' -f 2)
            month=$(echo $date | cut -d "/" -f 1)
            day=$(echo $date | cut -d "/" -f 2)
            year=20$(echo $date | cut -d "/" -f 3)
            hours=$(echo $time | cut -d : -f 1)
            minutes=$(echo $time | cut -d ":" -f 2)
            seconds=$(echo $time | cut -d ":" -f 3)
 
        echo "   Date: $date [day: $day, month: $month, year: $year]"
        echo "   Time: $time [hours: $hours, minutes: $minutes, seconds: $seconds]"
    else 
        echo "1. Timestamp: none"
    fi

    # Protocol
    if [ $proto ]
    then 
        echo "2. Proto: $proto"
    else
        echo "2. Proto: none"
    fi

    # Message
    if [ $msg ]
    then
        echo "3. Msg: $msg"
    else
        echo "3. Msg: none"
    fi    

    # Source IP
    if [ $src ]
    then
        echo "4. Src: $src"
    else
        echo "4. Src: none"
    fi

    # Source Port
    if [ $src_port ]
    then 
        echo "5. Src_port: $src_port"
    else
        echo "5. Src_port: none"
    fi

    # Destination IP
    if [ $dst ]
    then
        echo "6. Dst: $dst"
    else
        echo "6. Dst: none"
    fi

    # Destination Port
    if [ $dst_port ]
    then
        echo "7. Dst_port: $dst_port"
    else 
        echo "7. Dst_port: none"
    fi


    echo

done <$input

IFS=$OLDIFS
