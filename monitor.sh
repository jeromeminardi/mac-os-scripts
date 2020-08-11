#!/bin/bash
#
# version: 1.0
# on en0


function testConnectivity {
  n=0
  while :
  do
    nc -z -w 5 -G 1 -L 5 8.8.8.8 53 >/dev/null 2>&1
    [[ $? = 0 ]] && break || ((n++))
    (( n >= 5 )) && break
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
          echo "`date "+%Y-%m-%d %H:%M:%S"` - DOWN DURING [$(($TIME-$TIMESTAMP))]" | tee -a log.csv
          say "La connexion internet a été indisponible pendant $(($TIME-$TIMESTAMP)) secondes"
        else
          # connexion is not available
          echo "`date "+%Y-%m-%d %H:%M:%S"` - UP DURING [$(($TIME-$TIMESTAMP))]" | tee -a log.csv
          say "Attention : La connexion internet vient d'être perdue"
        fi
      fi
      TIMESTAMP=`date +%s`
    fi
    sleep 2
    previous=$online
  done;
