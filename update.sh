#!/bin/bash

set -e

export LC_ALL="en_US.UTF-8"

if [ "$1" == "--testnet" ]; then
	pac_rpc_port=7111
	pac_port=7112
	is_testnet=1
else
	pac_rpc_port=7111
	pac_port=7112
	is_testnet=0
fi


arch=`uname -m`
version="035d4df02"
old_version="v0.14.0.0"
base_url="https://github.com/Serik53/ubu16/releases/download/${version}"
if [ "${arch}" == "x86_64" ]; then
	tarball_name="PACGlobal-${version}-lin64.tar.gz"
	binary_url="${base_url}/${tarball_name}"
else
	echo "PAC Global binary distribution not available for the architecture: ${arch}"
	exit -1
fi

echo "###############################"
echo "#  Installing Dependencies    #"		
echo "###############################"
echo ""
echo "Running this script on Ubuntu 16.04 LTS "

sudo apt-get -y update
sudo apt-get -y install git python virtualenv ufw pwgen 


echo "###############################"
echo "#   Setting up the Firewall   #"		
echo "###############################"
sudo locale-gen en_US.UTF-8
sudo apt-get install ufw
sudo ufw status
sudo ufw disable
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow $pac_port/tcp
sudo ufw logging on
sudo ufw --force enable
sudo ufw status

sudo iptables -A INPUT -p tcp --dport $pac_port -j ACCEPT

echo ""
echo "###############################"
echo "#      Get/Setup binaries     #"		
echo "###############################"
echo ""

if test -e "${tarball_name}"; then
	rm -r $tarball_name
fi
wget $binary_url
if test -e "${tarball_name}"; then
	echo "Unpacking $PAC Global distribution"
	tar -xvzf $tarball_name
	chmod +x pacglobald
	chmod +x pacglobal-cli
	rm -r $tarball_name
else
	echo "There was a problem downloading the binaries, please try running again the script."
	exit -1
fi


echo "###############################"
echo "#      Running the wallet     #"		
echo "###############################"
echo ""
cd ~/

./pacglobald
sleep 70

is_pac_running=`ps ax | grep -v grep | grep pacglobald | wc -l`
if [ $is_pac_running -eq 0 ]; then
	echo "The daemon is not running or there is an issue, please restart the daemon!"
	exit
fi


./pacglobal-cli getinfo



