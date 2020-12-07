#!/bin/bash

sudo brctl delif br0 tap0
sudo brctl delif br0 tap1

sudo tunctl -d tap0
sudo tunctl -d tap1

sudo brctl delif br0 $1

sudo ifconfig br0 down
sudo brctl delbr br0

sudo ifconfig eth0 up
sudo dhclient -v $1
