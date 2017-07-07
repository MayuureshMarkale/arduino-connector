#!/bin/bash -e

has() {
	type "$1" > /dev/null 2>&1
	return $?
}

download() {
	if has "wget"; then
		wget -nc $1
	elif has "curl"; then
		curl -SOL $1
	else
		echo "Error: you need curl or wget to proceed" >&2;
		exit 20
	fi
}

# Replicate env variables in uppercase format
export ID=$id
export TOKEN=$token
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export ALL_PROXY=$all_proxy

echo printenv
echo ---------

cd $HOME
echo home folder
echo ---------

echo remove old files
echo ---------
rm -f arduino-connector* certificate*

echo uninstall previous installations of connector
echo ---------
if [ "$password" == "" ]
then
	sudo sysctl stop ArduinoConnector || true
else
	echo $password | sudo -kS sysctl stop ArduinoConnector || true
fi

if [ "$password" == "" ]
then
	sudo rm -f /etc/systemd/system/ArduinoConnector.service
else
	echo $password | sudo -kS rm -f /etc/systemd/system/ArduinoConnector.service
fi

echo download connector
echo ---------
download https://downloads.arduino.cc/tools/arduino-connector-dev
chmod +x arduino-connector-dev

echo install connector
echo ---------
if [ "$password" == "" ]
then
	sudo -E ./arduino-connector-dev -install
else
	echo $password | sudo -kS -E ./arduino-connector-dev -install > arduino-connector.log 2>&1
fi

echo start connector service
echo ---------
if [ "$password" == "" ]
then
	sudo sysctl start ArduinoConnector
else
	echo $password | sudo -kS sysctl start ArduinoConnector
fi