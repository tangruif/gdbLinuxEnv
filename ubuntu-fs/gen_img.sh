#!/bin/bash
#Create ext3 image file
rootfs_name=rootfs.img

dd if=/dev/zero of=${rootfs_name} bs=1M count=4096
mkfs.ext3 ${rootfs_name}
 
#Copy all the files in our rootfs to image
mkdir -p tmpfs
sudo mount -t ext3 ${rootfs_name} tmpfs/ -o loop
sudo cp -r rootfs/* tmpfs/
sudo umount tmpfs
rmdir tmpfs
