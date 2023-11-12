#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "0" == `ifconfig | grep tun0 | wc -l` ]; 
then 
    echo `date` No VPN!! Reconnecting
    sudo -b openvpn $SCRIPT_DIR/es-mad-surfshark.ovpn
else
    echo `date` VPN still up 
fi
