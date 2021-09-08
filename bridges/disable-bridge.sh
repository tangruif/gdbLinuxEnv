#!/bin/bash

sudo brctl delif virbr0 tap0
sudo brctl delif virbr0 tap1
sudo brctl delif virbr0 tap2
sudo brctl delif virbr0 tap3

sudo tunctl -d tap0
sudo tunctl -d tap1
sudo tunctl -d tap2
sudo tunctl -d tap3

#sudo brctl delif br0 $1

#sudo ifconfig br0 down
#sudo brctl delbr br0

#sudo ifconfig $1 up
#sudo dhclient -v $1
