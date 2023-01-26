#!/bin/bash

## vars

## functions

## look at me go!
# install /root .profile
cp -fv root/.profile /root

# setup some dirs
mkdir -p /root/loot /root/looted /root/scripts

# copy the scripts
cp -fv cron/* /root/scripts/

# setup crons
# getloot.sh
FILE="/etc/crontabs/root"
STRING="*/5 * * * * bash /root/scriipts/getloot.sh"
if [[ ! -z $(grep -F "$STRING" "$FILE") ]]
then
  echo "$STRING found!"
else
  echo "$STRING" >> $FILE
  echo "$STRING added!"
fi

STRING="0 */6 * * * bash /root/scriipts/getloot-6.sh"
if [[ ! -z $(grep -F "$STRING" "$FILE") ]]
then
  echo "$STRING found!"
else
  echo "$STRING" >> $FILE
  echo "$STRING added!"
fi