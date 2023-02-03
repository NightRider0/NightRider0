#!/bin/bash
###########################################################################
#                                                                         #
# Written 02/01/2023 by Tyler Wallenstein                                 #
# Moniters the Wings service for our pterodactyl cluster and will attempt #
# to recover them, if fails it notifys the humans                         #
#                                                                         #
###########################################################################
#setting some stuff we need
source /etc/WingWatch.conf
hostname=`hostname`
RefMessage='fb1d3c7de23551e06c1675c346e7b990'
PasteURL='null'
restart=0
posted=0

#checking if we have a status file, if missing it will be created
FILE='/var/WingWatch.status'
if test -f "$FILE"; then
    echo "$FILE exists."

else
    echo "$FILE not found!"
    echo "I will create it!"
    echo 0 > $FILE
    
fi
OSrestart=`cat $FILE`

source WingWatchFunctions.sh

#sending a statup message to discord
discord "WingWatch on $hostname is starting! Starting watch in 30 seconds"
#sleeping for a momment
sleep 30

#starting watch loop
while [ true ]
do
#getting status and comparing to online status
status=`curl -m 10 https://$host:$port | md5sum`
echo "|$RefMessage| vs |${status::-3}|" ##Debug use
if [ "$RefMessage" == "${status::-3}" ]
 then
  alive=1
  restart=0
  OSrestart='0'
  echo 0 > $FILE
  while [ $posted -eq 1 ]
   do 
    discord "$hostname is onlince again!"
    echo "$hostname is onlince again!"
    posted=0
   done
 else
  alive=0
fi

# deciding our corse of action
## wings is dead with no previous acion, will restart wings
if [ $alive -eq 0 ] && [ $restart -eq 0 ] && [ $OSrestart -eq 0 ]
 then
  PastebinLog
  discord "$hostname has restarted wings $PasteURL"
  echo "$hostname has restarted wings $PasteURL"
  /usr/bin/systemctl restart wings
  restart=1
## wings is dead and has been restarted, will restart OS  
 elif [ $alive -eq 0 ] && [ $restart -eq 1 ] && [ $OSrestart -eq 0 ]
  then
   PastebinLog
   discord "$hostname has failed to restart wings restarting the OS $PasteURL"
   echo "$hostname has failed to restart wings restarting the OS $PasteURL"
   echo 1 > $FILE
   OSrestart=1
   init 6
## wings is online and happy 
 elif [ $alive -eq 1 ] && [ $restart -eq 0 ] && [ $OSrestart -eq 0 ]
  then
   echo "wing is online"

## We have nothing else to do notifing the humans!   
 else 
  PastebinLog
  while [ $posted -eq 0 ]
   do 
    discord "<@&267554033311416320> I am not able to re-alive $hostname please correct the issue! $PasteURL"
    echo "<@&267554033311416320> I am not able to re-alive $hostname please correct the issue $PasteURL"
    posted=1
   done
fi

sleep 600
done
