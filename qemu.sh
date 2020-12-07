#!/bin/bash

usage() {
    echo "Usage:"
    echo "  qemu.sh [-k KERNEL_PATH]  [-f MINI_FS_PATH] [-u UBUNTU_FS_PATH] [-t NAME] [-p PORT]"
    echo "Description:"
    echo "  KERNEL_PATH , 压缩内核:bzImage的路径。默认路径为../newip/Kernel/arch/x86_64/boot/bzImage"
    echo "  MINI_FS_PATH , 使用最小文件系统的路径。默认为./rootfs.cpio.gz。"
    echo "  UBUNTU_FS_PATH , 使用ubuntu文件系统路径，默认无，此项和-f冲突，只能指定其中一种。"
    echo "  NAME , 虚拟机网卡连接到的tap名称。若省略此项则不使用tap进行网络连接"
    echo "  PORT , 虚拟机监听端口，gdb将通过这一端口连接虚拟机调试内核。若省略此项则使用端口1234"
    exit 1
}

cur_dir=$(cd "$(dirname "$0")"; pwd)

cmd="qemu-system-x86_64 "

kernel_path="${cur_dir}/../newip/Kernel/arch/x86_64/boot/bzImage"
rootfs_cpio_path="${cur_dir}/rootfs.cpio.gz"
ubuntu_img_path=""
tap_name=""
port=1234
        
while getopts k:f:u:t:p:h option
do
    case "${option}" in
            u) ubuntu_img_path=${OPTARG};;
            k) kernel_path=${OPTARG};;
            f) rootfs_cpio_path=${OPTARG};;
            t) tap_name=${OPTARG};;
            p) port=${OPTARG};;
            h) usage;;
            ?) usage;;
    esac
done

# select kernel
cmd=${cmd}"-kernel ${kernel_path} "

# select file system
if [ $ubuntu_img_path ]
then
    cmd="sudo "${cmd}"-hda ${ubuntu_img_path} 
                      -append \"console=ttyS0 root=/dev/sda nokaslr\" 
                      -curses 
                      -m 2048M 
                      -enable-kvm "
else
    cmd=${cmd}"-initrd ${rootfs_cpio_path}
               -append \"console=ttyS0 rdinit=/linuxrc nokaslr\"  
               -m 1024M 
               -nographic "
fi

# select tap
if [ $tap_name ]
then
    if [ $tap_name != "tap0"  ]
    then
        cmd=${cmd}"-net nic,macaddr=52:54:00:12:34:57 "
    else
        cmd=${cmd}"-net nic "
    fi
    cmd=${cmd}"-net tap,ifname=${tap_name},script=no,downscript=no "
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
