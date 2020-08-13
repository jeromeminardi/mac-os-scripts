#!/bin/bash
# author : jérôme Minardi
# version: 1.1
#
# Unix (Mac Os) script to monitor internet connection status and log Up & Donw status with the duration
# Listen on en0

function seconds2time {
   local T=$1
   local D=$((T/60/60/24))
   local H=$((T/60/60%24))
   local M=$((T/60%60))
   local S=$((T%60))

   if [[ ${D} != 0 ]]
   then
      printf '%d days %02d:%02d:%02d' $D $H $M $S
   else
      printf '%02d:%02d:%02d' $H $M $S
   fi
}


function testConnectivity {
  n=0
  while :
  do
    nc -z -w 2 -G 1 -L 5 8.8.8.8 53 >/dev/null 2>&1
    if [ $? -eq 0 ]; then 
      return 0;
    elif [ $n -lt 5 ]; then 
      n=$((n+1)) ;
      sleep 1;
    else
      return 1;
    fi
  done
}


# Program start
echo "`date "+%Y-%m-%d %H:%M:%S"` - MONITORING START" | tee -a log.csv

# variable initialization
testConnectivity
previous=$?
TIMESTAMP=`date +%s`

while [ 1 ]
  do
    testConnectivity
    online=$?

    if [ $online -eq $previous ]; then
      # nothing changed during the loop, nothing to do
      :
    else 
      STATUS=`ifconfig en0 | awk '/status:/{print $2}'`
      TIME=`date +%s`
      if [ $STATUS = "active" ]; then
        if [ $online -eq 0 ]; then
          # connexion is now available
          echo "`date "+%Y-%m-%d %H:%M:%S"` - DOWN DURING [$(($TIME-$TIMESTAMP))] seconds -> (`seconds2time $(($TIME-$TIMESTAMP))`)" | tee -a log.csv
          say "La connexion internet a été indisponible pendant $(($TIME-$TIMESTAMP)) secondes"
        else
          # connexion is not available
          echo "`date "+%Y-%m-%d %H:%M:%S"` - UP DURING [$(($TIME-$TIMESTAMP))] seconds -> (`seconds2time $(($TIME-$TIMESTAMP))`)" | tee -a log.csv
          say "Attention : La connexion internet vient d'être perdue"
        fi
      fi
      TIMESTAMP=`date +%s`
    fi
    sleep 5
    previous=$online
  done;
