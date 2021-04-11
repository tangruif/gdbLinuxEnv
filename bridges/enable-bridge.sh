#!/bin/bash

if [ -z $1  ]
then
    echo "请输入网卡名称"
    exit 1
fi

if [ -z "`ifconfig | grep $1`" ]
then
    echo "网卡${1}不存在"
    exit 1
fi

sudo brctl addbr br0
sudo ip addr flush dev $1
sudo brctl addif br0 $1
sudo tunctl -t tap0 -u `whoami`
sudo tunctl -t tap1 -u `whoami`
sudo tunctl -t tap2 -u `whoami`
sudo tunctl -t tap3 -u `whoami`
sudo brctl addif br0 tap0
sudo brctl addif br0 tap1
sudo brctl addif br0 tap2
sudo brctl addif br0 tap3

sudo ifconfig $1 up
sudo ifconfig tap0 up
sudo ifconfig tap1 up
sudo ifconfig tap2 up
sudo ifconfig tap3 up
sudo ifconfig br0 up

sudo dhclient -v br0
