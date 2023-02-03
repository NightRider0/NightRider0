#!/bin/bash
# Writen by Tyler Wallenstein 02/02/2023
# Setup for script for WingWatch.sh
clear
ddir=`pwd`

echo "Hello `whoami`"
echo " "
echo "This script assumes this wing has ssh access to Control.t2w.wtf, we will use this abbility do pull down some keys we need"
echo " "
echo "To get started can i get the FQDN of the node?"
read fqdn
echo "what port is the wings deamon on, this is not the scp port"
read port
echo ""
echo "You entered: $fqdn:$port"
echo is this correct?
read -p "Press enter to continue or ctrl+c to quit"
clear
echo "Great! lets get going"

sleep 1
echo "Adding an entry to the /etc/host file..."
echo '# The following entry was added for WingWatch' >> /etc/host
echo "127.0.0.1 $fqdn" >> /etc/hosts
echo "Done!"
sleep 1

echo "Let me grab some some keys..."
scp certs@control.t2w.wtf:~/WingWatchFunctions.sh /sbin/WingWatchFunctions.sh
echo "Let me grab the script..."
curl -s https://raw.githubusercontent.com/NightRider0/NightRider0/main/WingWatch.sh | sudo tee /sbin/WingWatch.sh
chmod +x /sbin/WingWatch.sh
echo "Making a settings file..."
echo "#settings that where set by the install script!
host=$fqdn
port=$port
logFILE=/var/log/pterodactyl/wings.log
linesEXPORTED=100" > /etc/WingWatch.conf
echo Done!
sleep 1
echo "Creating the service..." 
echo "
[Unit]
Description=A Watch Dog for the wings service!

[Service]
User=root
WorkingDirectory=/root
ExecStart=/sbin/WingWatch.sh
Restart=always

[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/wingwatch.service
echo "starting and enabling the service!"
systemctl enable --now wingwatch
rm -Rf $ddir/WWatchSetup.sh
sleep 2
echo "That is all i got!"
echo "Goodbye!"
sleep 5 
clear
