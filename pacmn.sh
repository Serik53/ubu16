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
version="8ae297c-legacy"
old_version="v0.14.0.0"
base_url="https://github.com/Serik53/ubu16/releases/download/${version}"
if [ "${arch}" == "x86_64" ]; then
	tarball_name="PACGlobal-${version}-lin64.tar.gz"
	binary_url="${base_url}/${tarball_name}"
else
	echo "PAC Global binary distribution not available for the architecture: ${arch}"
	exit -1
fi

echo "################################################"
echo "#   Welcome to PAC Masternode's server setup   #"		
echo "################################################"
echo "" 

read -p 'IP: ' ipaddr
read -p 'bls (secret): ' bls

while [[ $ipaddr = '' ]] || [[ $ipaddr = ' ' ]]; do
	read -p 'You did not provided an external IP, please provide one: ' ipaddr
	sleep 2
done

while [[ $bls = '' ]] || [[ $bls = ' ' ]]; do
	read -p 'bls (secret): ' bls
	sleep 2
done

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
	cd PACGlobal-${version}-lin64
	chmod +x pacglobald
	chmod +x pacglobal-cli
	cp $PWD/pacglobald /root/      
        cp $PWD/pacglobal-cli /root/ 
        cp $PWD/pacglobal-tx /root/
	echo "Binaries were saved to: $PWD/$tarball_name"
	cd ..
	rm -r $tarball_name
else
	echo "There was a problem downloading the binaries, please try running again the script."
	exit -1
fi

echo "###############################"
echo "#     Configure the wallet    #"		
echo "###############################"
echo ""
echo "The .PACGlobal folder will be created, if folder already exists, it will be replaced"
if [ -d ~/.PACGlobal ]; then
	if [ -e ~/.PACGlobal/pacglobal.conf ]; then
		read -p "The file pacglobal.conf already exists and will be replaced. do you agree [y/n]:" cont
		if [ $cont = 'y' ] || [ $cont = 'yes' ] || [ $cont = 'Y' ] || [ $cont = 'Yes' ]; then
			sudo rm ~/.PACGlobal/pacglobal.conf
			touch ~/.PACGlobal/pacglobal.conf
			cd ~/.PACGlobal/
		fi
	fi
else
	echo "Creating .PACGlobal dir"
	mkdir -p ~/.PACGlobal
	cd ~/.PACGlobal
	touch pacglobal.conf
fi

echo "Configuring the pacglobal.conf"
echo "rpcuser=$(pwgen -s 16 1)" > pacglobal.conf
echo "rpcpassword=$(pwgen -s 64 1)" >> pacglobal.conf
echo "rpcallowip=127.0.0.1" >> pacglobal.conf
echo "rpcbind=127.0.0.1" >> pacglobal.conf
echo "server=1" >> pacglobal.conf
echo "daemon=1" >> pacglobal.conf
echo "listen=1" >> pacglobal.conf
echo "testnet=$is_testnet" >> pacglobal.conf
echo "masternode=1" >> pacglobal.conf
echo "externalip=$ipaddr:$pac_port" >> pacglobal.conf
echo "masternodeblsprivkey=$bls" >> pacglobal.conf


echo "###############################"
echo "#      Running the wallet     #"		
echo "###############################"
echo ""
cd ~/

./pacglobald
sleep 45

is_pac_running=`ps ax | grep -v grep | grep pacglobald | wc -l`
if [ $is_pac_running -eq 0 ]; then
	echo "The daemon is not running or there is an issue, please restart the daemon!"
	exit
fi

./pacglobald -version
./pacglobal-cli getinfo



