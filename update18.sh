#!/bin/bash

set -e

export LC_ALL="en_US.UTF-8"

binary_url="https://github.com/PACGlobalOfficial/PAC/releases/download/035d4df02/pacglobal-035d4df02-lin64.tgz"
file_name="pacglobal-035d4df02-lin64"
extension=".tgz"

echo ""
echo "#################################################"
echo "#  Remov old binaries  #"
echo "#################################################"

cd PACGlobal
sudo ./pacglobal-cli stop

sleep 5

sudo rm -r pacglobal-cli
sudo rm -r pacglobald
sudo rm -r pacglobal-tx


echo ""
echo "###############################"
echo "#      Get/Setup binaries     #"
echo "###############################"
echo ""
wget $binary_url
if test -e "$file_name$extension"; then
echo "Unpacking PACGlobal distribution"
	tar -xzvf $file_name$extension
	rm -r $file_name$extension
	mv -v $file_name PACGlobal
	cd PACGlobal
	chmod +x pacglobald
	chmod +x pacglobal-cli
	echo "Binaries were saved to: /root/PACGlobal"
else
	echo "There was a problem downloading the binaries, please try running the script again."
	exit -1
fi


sleep 60

is_pac_running=`ps ax | grep -v grep | grep pacglobald | wc -l`
if [ $is_pac_running -eq 0 ]; then
	echo "The daemon is not running or there is an issue, please restart the daemon!"
	exit
fi

cd ~/PACGlobal
./pacglobal-cli getinfo

echo ""
echo "Your masternode server is ready!"