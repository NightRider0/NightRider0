#!/bin/bash
#Writen by Tyler Wallenstein 10/11/2022
echo "Hello `whoami`"
echo "to get started can i get the FQDN of the node?"
read fqdn
echo You entered $fqdn
echo is this correct?
read -p "Press enter to continue or ctrl+c to quit"
clear
echo $fqdn
sleep 1
echo Making some needed folders ...
sleep .5
sudo mkdir -p /etc/letsencrypt/live/$fqdn
sudo mkdir /root/.certs
echo Done!
echo Linking some files ...
sleep .5
sudo ln -s /root/.certs/games.fullchain /etc/letsencrypt/live/$fqdn/fullchain.pem
sudo ln -s /root/.certs/games.key /etc/letsencrypt/live/$fqdn/privkey.pem
echo Done!
sleep 1
clear
echo Cutting some keys ... 
sleep .5
sudo ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -q
echo Cleaning the keys ... 
sleep .5
clear
echo Please login to Control.t2w.wtf and the following line, sudo nano /home/certs/.ssh/authorized_keys
echo " "
sudo cat /root/.ssh/id_ed25519.pub
echo " "
read -p "Press enter to continue when you have completed this"
echo please type yes if pormpted below ...
sleep .5
sudo ssh certs@control.t2w.wtf 'echo hi'
sleep .5
echo Thank you
sleep 2
clear
echo Making some cron jobs ...
sudo crontab -l > /tmp/cron_bkp
echo "Please enter a hour 5 >> 24"
read hour
echo "Please enter a min 0 >> 60" 
read min
echo Thank you!
sleep 1
sudo echo "$min $hour * * * rm -f /root/.certs/games.* && scp certs@control.t2w.wtf:~/games.key /root/.certs/ && scp certs@control.t2w.wtf:~/games.fullchain /root/.certs/" >> /tmp/cron_bkp
sudo crontab /tmp/cron_bkp
echo Cleaning up a mess ...
sleep .5
sudo rm /tmp/cron_bkp
echo Mess is cleaned up ...
sleep .25
clear
echo Okay let me grab thos certs real quick for you ...
sleep .5
sudo scp certs@control.t2w.wtf:~/games.key /root/.certs/ && sudo scp certs@control.t2w.wtf:~/games.fullchain /root/.certs/

