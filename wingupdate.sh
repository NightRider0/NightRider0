#!/bin/bash
#Written 12/14/2022 by Tyler Wallenstein

ddir=`pwd`
clear
echo 'Hello, let me update wings for you!'
sudo systemctl stop wings
sudo curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
sudo chmod u+x /usr/local/bin/wings
sudo systemctl restart wings
sudo rm -Rf $ddir/wingupdate*
sudo rm -Rf $ddir/WingUpdate*
echo ''
echo "Done, Good bye!"
