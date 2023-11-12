#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "0" == `ifconfig | grep tun0 | wc -l` ]; 
then 
    echo `date` No VPN!! Reconnecting
    sudo -b openvpn $SCRIPT_DIR/es-mad-surfshark.ovpn   # (if the ovpn file contains auth-user-pass)
    # sudo -b openvpn --config $SCRIPT_DIR/es-mad-surfshark.ovpn --auth-user-pass $SCRIPT_DIR/surfshark.pass
else
    echo `date` VPN still up 
fi
