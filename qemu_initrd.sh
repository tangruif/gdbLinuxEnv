#!/bin/bash

usage() {
    echo "Usage:" echo "  qemu.sh [-k KERNEL_PATH]  [-f MINI_FS_PATH] [-t NAME] [-p PORT]"
    echo "Description:"
    echo "  KERNEL_PATH , 内核代码所在的路径。默认路径为../newip/Kernel"
    echo "  MINI_FS_PATH , 使用最小文件系统的路径。默认为./rootfs.cpio.gz。"
    echo "  NAME , 虚拟机网卡连接到的tap名称。若省略此项则不使用tap进行网络连接"
    echo "  PORT , 虚拟机监听端口，gdb将通过这一端口连接虚拟机调试内核。若省略此项则使用端口1234"
    exit 1
}

cur_dir=$(cd "$(dirname "$0")"; pwd)

cmd="qemu-system-x86_64 "

kernel_dir_path="${cur_dir}/../newip/Kernel"
kernel_path="/arch/x86_64/boot/bzImage"
rootfs_cpio_path="${cur_dir}/rootfs-sender.cpio.gz"
tap_name="tap0"
port=1234
        
while getopts k:f:t:p:h option
do
    case "${option}" in
            k) kernel_dir_path=${OPTARG};;
            f) rootfs_cpio_path=${OPTARG};;
            t) tap_name=${OPTARG};;
            p) port=${OPTARG};;
            h) usage;;
            ?) usage;;
    esac
done

# select kernel
cmd=${cmd}"-kernel ${kernel_dir_path}${kernel_path} "

# select file system
cmd=${cmd}"-initrd ${rootfs_cpio_path}
           -append \"console=ttyS0 rdinit=/linuxrc nokaslr\"  
           -smp 4
           -m 2048M 
           -nographic "

# select tap
if [ $tap_name ]
then
    macaddr="52:54:00:"`openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/.$//'`" "
    #cmd=${cmd}"-netdev user,id=u2 "
    #cmd=${cmd}"-device e1000,netdev=u2,mac=52:54:00:12:34:56 "
    cmd=${cmd}"-netdev tap,id=u1,ifname=${tap_name},script=no,downscript=no "
    cmd=${cmd}"-device e1000,netdev=u1,mac=${macaddr} "
    #cmd=${cmd}"-netdev user,id=u2 "
    #cmd=${cmd}"-device e1000,netdev=u2,mac=52:54:00:12:34:56 "
    #cmd=${cmd}"-netdev tap,id=u2,ifname=tap1,script=no,downscript=no "
    #cmd=${cmd}"-device e1000,netdev=u2,mac=52:54:00:11:15:38 "
else
    echo "未使用tap，多个qemu虚拟机无法直接通过ip地址互相访问"
fi

# open port for gdb
cmd=${cmd}"-gdb tcp::${port}"

# echo config
echo "kernel_path      : ${kernel_path}"
echo "rootfs_cpio_path : ${rootfs_cpio_path}"
echo "ubuntu_img_path  : ${ubuntu_img_path}"
echo "tap_name         : ${tap_name}"
echo "listen_port      : ${port}"

# star qemu
eval $cmd
