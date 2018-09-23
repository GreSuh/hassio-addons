#/bin/bash

# Inspired by https://github.com/Homegear/Homegear-Docker/blob/master/rpi-stable/start.sh

mkdir -p /config/homegear /share/homegear/lib /share/homegear/log
chown homegear:homegear /config/homegear /share/homegear/lib /share/homegear/log
rm -Rf /etc/homegear /var/lib/homegear /var/log/homegear
ln -nfs /config/homegear     /etc/homegear
ln -nfs /share/homegear/lib /var/lib/homegear
ln -nfs /share/homegear/log /var/log/homegear

if ! [ "$(ls -A /etc/homegear)" ]; then
	cp -R /etc/homegear.config/* /etc/homegear/
fi

if ! [ "$(ls -A /var/lib/homegear)" ]; then
	cp -a /var/lib/homegear.data/* /var/lib/homegear/
else
	rm -Rf /var/lib/homegear/modules/*
	rm -Rf /var/lib/homegear/flows/nodes/*
	cp -a /var/lib/homegear.data/modules/* /var/lib/homegear/modules/
	cp -a /var/lib/homegear.data/flows/nodes/* /var/lib/homegear/flows/nodes/
fi

if ! [ -f /etc/homegear/dh1024.pem ]; then
	openssl genrsa -out /etc/homegear/homegear.key 2048
	openssl req -batch -new -key /etc/homegear/homegear.key -out /etc/homegear/homegear.csr
	openssl x509 -req -in /etc/homegear/homegear.csr -signkey /etc/homegear/homegear.key -out /etc/homegear/homegear.crt
	rm /etc/homegear/homegear.csr
	chown homegear:homegear /etc/homegear/homegear.key
	chmod 400 /etc/homegear/homegear.key
	openssl dhparam -check -text -5 -out /etc/homegear/dh1024.pem 1024
	chown homegear:homegear /etc/homegear/dh1024.pem
	chmod 400 /etc/homegear/dh1024.pem
fi

sudo echo 22 > /sys/class/gpio/export
sudo echo out > /sys/class/gpio/gpio22/direction
sudo echo 1 > /sys/class/gpio/gpio22/value

sleep 2


if test ! -d /sys/class/gpio/gpio22; then echo 22 > /sys/class/gpio/export; fi
echo out > /sys/class/gpio/gpio22/direction
echo 0 > /sys/class/gpio/gpio22/value

if test ! -d /sys/class/gpio/gpio27; then echo 27 > /sys/class/gpio/export; fi
echo out > /sys/class/gpio/gpio27/direction
echo 0 > /sys/class/gpio/gpio27/value

echo 1 > /sys/class/gpio/gpio22/value
sleep 1
echo 1 > /sys/class/gpio/gpio22/value
echo in > /sys/class/gpio/gpio27/direction
echo 27 > /sys/class/gpio/unexport

sleep 5





service homegear start
service homegear-influxdb start
tail -f /var/log/homegear/homegear.log
