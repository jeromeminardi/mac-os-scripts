#!/bin/bash
# Author: Jérôme Minardi
# version: 1.0
# date: 10-08-2020
# Monitor on en0 (change line 24 if needed to monitor on another device)

# Program start
echo "`date "+%Y-%m-%d %H:%M:%S"` - MONITORING START" | tee -a internet.log

# variable initialization
nc -z -w 2 -G 1 8.8.8.8 53 >/dev/null 2>&1
previous=$?
TIMESTAMP=`date +%s`

while [ 1 ]
  do
    nc -z -w 2 -G 1 8.8.8.8 53 >/dev/null 2>&1
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
          echo "`date "+%Y-%m-%d %H:%M:%S"` - DOWN DURING [$(($TIME-$TIMESTAMP))]" | tee -a internet.log
          say "La connexion internet a été indisponible pendant $(($TIME-$TIMESTAMP)) secondes"
        else
          # connexion is not available
          echo "`date "+%Y-%m-%d %H:%M:%S"` - UP DURING [$(($TIME-$TIMESTAMP))]" | tee -a internet.log
          say "Attention : La connexion internet vient d'être perdue"
        fi
      fi
      TIMESTAMP=`date +%s`
    fi
    sleep 2
    previous=$online
  done;
