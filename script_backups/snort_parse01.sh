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


OLDIFS=$IFS
IFS=,
while read timestamp sig_gen sig_id sig_rev msg proto src src_port dst dst_port eth_src eth_dst eth_len tcp_flags tcp_seq tcp_ack tcp_len tcp_window ttl tos id dgmlen iplen icmp_type icmp_code icmp_id icmp_seq
do
   echo "1. Timestamp:  $timestamp"

   date=$(echo $timestamp | cut -d '-' -f 1)
   time=$(echo $timestamp | cut -d '-' -f 2)
   month=$(echo $date | cut -d "/" -f 1)
   day=$(echo $date | cut -d "/" -f 2)
   year=$(echo $date | cut -d "/" -f 3)
   hours=$(echo $time | cut -d : -f 1)
   minutes=$(echo $time | cut -d ":" -f 2)
   seconds=$(echo $time | cut -d ":" -f 3)

   echo "   Date: $date"
   echo "     day: $day"
   echo "     month: $month"
   echo "     year: $year"
   echo "   Time: $time"
   echo "     hours: $hours"
   echo "     minutes: $minutes"
   echo "     seconds: $seconds"
   echo
   echo "2. Sig_gen: $sig_gen"
   echo "3. Sig_id: $sig_id"
   echo "4. Sig_rev: $sig_rev"
   echo "5. Msg: $msg"
   echo "6. Proto: $proto"
   echo "7. Src: $src"
   echo "8. Src_port: $src_port"
   echo "9. Dst: $dst"
   echo "10. Dst_port: $dst_port"
   echo "11. Eth_src: $eth_src"
   echo "12. Eth_dst: $eth_dst"
   echo "13. Eth_len: $eth_len"
   echo "14. TCP_flags: $tcp_flags"
   echo "15. TCP_seq: $tcp_seq"
   echo "16. TCP_ack: $TCP_ack"
   echo "17. TCP_len: $tcp_len"
   echo "18. TCP_window: $tcp_window"
   echo "19. TTL: $ttl"
   echo "20. TOS: $tos"
   echo "21. ID: $id"
   echo "22. DGM_len: $dgmlen"
   echo "23. IP_len: $iplen"
   echo "24. ICMP_type: $icmp_type"
   echo "25. ICMP_code: $icmp_code"
   echo "26. ICMP_id: $icmp_id"
   echo "27. ICMP_seq: $icmp_seq"
   echo
done <"$input"
IFS=$OLDIFS
