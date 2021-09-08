#!/bin/bash

#sudo brctl addbr br0
sudo tunctl -t tap0 -u `whoami`
sudo tunctl -t tap1 -u `whoami`
sudo tunctl -t tap2 -u `whoami`
sudo tunctl -t tap3 -u `whoami`
sudo brctl addif virbr0 tap0
sudo brctl addif virbr0 tap1
sudo brctl addif virbr0 tap2
sudo brctl addif virbr0 tap3

sudo ifconfig tap0 up
sudo ifconfig tap1 up
sudo ifconfig tap2 up
sudo ifconfig tap3 up
#sudo ifconfig br0 up
