#! /bin/bash -

if [ ! -f 'alerts.csv' ]
then
    echo "File alerts.csv not found"
    exit 1
else
    input=$(cat alerts.csv | tail -n 5)
    input=$(echo "$input")
fi

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

    # Time & Date
    if [ $timestamp ]
    then
        # timestamp=$(echo $timestamp | sed -e 's/[[:space:]]*$//')
        timestamp=$(echo $timestamp | sed -e 's/\..*$//')
    else 
        timestamp=0
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
        country='none [pvt ips]'
        state='none [pvt ips]'
        city='none [pvt ip]s'
        postal_code='none [pvt ips]'
        longitude='none [pvt ips]'
        latitude='none [pvt ips]'
    
    fi

    # Print the variables you want to display
    printf "  %s %15s %16s \t %-18s %-18s %-18s %s\n" "$timestamp" "$src" "$dst" "$country" "$state" "$city" "$msg"

    # Return IFS to comma for next loop
    IFS=$IFS_COMMA

done <<< "$input"  # bash-specific "here string"
                   # expands $input string and feeds it to stdin of read
                   # (http://www.tldp.org/LDP/abs/html/x17837.html)

# Put the old file separator back into environment variable
IFS=$DEFAULT_IFS
