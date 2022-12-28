#!/bin/bash
#Writen by Tyler Wallenstein 10/11/2022
ddir=`pwd`
clear
echo "Hello `whoami`"
echo " "
echo "To get started can i get the FQDN of the node?"
read fqdn
echo You entered: $fqdn
echo is this correct?
read -p "Press enter to continue or ctrl+c to quit"
clear
echo $fqdn
sleep 1
echo Making some folders we need ...
sleep 1
sudo mkdir -p /etc/letsencrypt/live/$fqdn
sudo mkdir /root/.certs
sudo systemctl disable cloud-init
echo Done!
echo Linking some files ...
sleep 1
sudo ln -s /root/.certs/games.fullchain /etc/letsencrypt/live/$fqdn/fullchain.pem
sudo ln -s /root/.certs/games.key /etc/letsencrypt/live/$fqdn/privkey.pem
echo Done!
sleep 1
clear
echo Cutting some keys ... 
sleep .5
sudo ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -q
echo Cleaning the keys ... 
sleep 2
clear
echo Please login to Control.t2w.wtf and add the line below, sudo nano /home/certs/.ssh/authorized_keys
echo " "
sudo cat /root/.ssh/id_ed25519.pub
echo " "
read -p "Press enter when done."
echo please type yes if pormpted below ...
sleep 2
sudo ssh certs@control.t2w.wtf 'echo It Works!'
sleep 1
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
plus=$(($min + 5)) 
sudo echo "$plus $hour 11-17 * 3 /usr/bin/systemctl restart wings.service" >> /tmp/cron_bkp
sudo crontab /tmp/cron_bkp
echo Cleaning up a mess ...
sleep 1
sudo rm /tmp/cron_bkp
echo Mess is cleaned up ...
sleep .75
clear
echo Okay let me grab thos certs real quick ...
sleep 1
sudo scp certs@control.t2w.wtf:~/games.key /root/.certs/ && sudo scp certs@control.t2w.wtf:~/games.fullchain /root/.certs/
echo Done with certs!
sleep 5
clear
echo "Would you like me to install Wings for you? (yes,no)"
read WingsInstall

case $WingsInstall in

	n | N | no | NO | No)
	sudo rm -Rf $ddir/CertHelp.sh
	echo Good day, and happy gaming!
	exit
	;;
	
	y | Y | yes | YES | Yes)
	echo Lets get wings installed!
	sleep 5
	echo Grabbing docker from the internet ...
	sleep 2 
	sudo curl -sSL https://get.docker.com/ | CHANNEL=stable bash
	clear
	echo Setting docker to start on boot
	sleep 1
	sudo systemctl enable --now docker
	sleep 2
	echo Making folders for wings ...
	sudo mkdir -p /etc/pterodactyl
	sleep .5
	echo Grabing files from the internet ...
	sleep 1
	sudo curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
	clear
	echo Setting perms ...
	sleep 1
	sudo chmod u+x /usr/local/bin/wings
	echo Done ...
	sleep 5
	clear
	echo Please go to the Node your working on and click Generate Token, paste the commmand below.
	read token
	sleep 1
	echo Thank you!
	echo Grabbing token standby ...
	sleep 3
	sudo tmux new "$token"
	echo Done!
	sleep 5
	clear
	echo Okay lets see if the wing is working.
	echo I will start wings in debug mode please ensure it does not crash and is seen in the web portal
	echo ctr+c to exit wings
	read -p "Press enter to continue"
	sudo tmux new "wings --debug"
	echo If it worked great! if not follow normal troulbshootig or seek help
	sleep 5
	echo Setting wings to start on boot ...
	curl -s https://raw.githubusercontent.com/NightRider0/NightRider0/main/WingsSystemD | sudo tee /etc/systemd/system/wings.service
	sudo systemctl enable --now wings
	sudo rm -Rf $ddir/CertHelp.sh
	sleep 5
	echo 'All Done !!!'
	echo 'Good bye!'
	sleep 15
	clear
	exit
	;;
esac
