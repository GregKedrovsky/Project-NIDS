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

#  awk -F, -v 'OFS=\t' '{ print $1, $2, $3, $4, $5, $6, $7, $8 }' $input


# Put the old file separator into a file for safe-keeping
OLDIFS=$IFS
# Change the file separator to a comma for my csv files
IFS=,

while read timestamp msg proto src src_port dst dst_port
do
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

    echo "2. Proto: $proto"

    echo "3. Msg: $msg"
    echo "4. Src: $src"
    echo "5. Src_port: $src_port"
    echo "6. Dst: $dst"
    echo "7. Dst_port: $dst_port"
    echo

done <"$input"

IFS=$OLDIFS
