#!/bin/bash

if [ "0" == `ifconfig | grep tun0 | wc -l` ]; 
then 
    echo `date` No VPN!! Reconnecting
    sudo -b openvpn /home/pi/vpn/es-mad-surfshark.ovpn
else
    echo `date` VPN still up 
fi
