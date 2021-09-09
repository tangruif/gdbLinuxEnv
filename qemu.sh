#!/bin/bash

usage() {
    echo "Usage:" echo "  qemu.sh [-k KERNEL_PATH]  [-u ROOTFS_IMG_PATH] [-t NAME] [-p PORT]"
    echo "Description:"
    echo "  KERNEL_PATH , 内核代码所在的路径。默认路径为../newip/Kernel"
    echo "  ROOTFS_IMG_PATH , 使用的文件系统镜像路径，镜像类型为raw"
    echo "  NAME , 虚拟机网卡连接到的tap名称。若省略此项则不使用tap进行网络连接"
    echo "  PORT , 虚拟机监听端口，gdb将通过这一端口连接虚拟机调试内核。若省略此项则使用端口1234"
    exit 1
}

cur_dir=$(cd "$(dirname "$0")"; pwd)

cmd="qemu-system-x86_64 "

# 手动修改以下几个变量，以指定默认内核目录或根文件系统位置
kernel_dir_path="${cur_dir}/../newip/Kernel"
kernel_path="/arch/x86_64/boot/bzImage"
rootfs_img_path="${cur_dir}/ubuntu-fs/rootfs.img"
tap_name=""
port=1234
        
while getopts k:u:t:p:h option
do
    case "${option}" in
            u) rootfs_img_path=${OPTARG};;
            k) kernel_dir_path=${OPTARG};;
            t) tap_name=${OPTARG};;
            p) port=${OPTARG};;
            h) usage;;
            ?) usage;;
    esac
done

# 选择内核文件
cmd=${cmd}"-kernel ${kernel_dir_path}${kernel_path} "

# 选择根文件系统
cmd="sudo "${cmd}"-drive file=${rootfs_img_path},format=raw
                  -append \"console=ttyS0 root=/dev/sda rw nokaslr\" 
		  -nographic
                  -m 2048M 
                  -enable-kvm "

# 网络相关配置
if [ $tap_name ]
then
    # 随机生成机器Mac地址
    macaddr="52:54:00:"`openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/.$//'`" "
    cmd=${cmd}"-netdev tap,id=u1,ifname=${tap_name},script=no,downscript=no "
    cmd=${cmd}"-device e1000,netdev=u1,mac=${macaddr} "
    # 为机器添加更多netdev，并指定mac地址
    #cmd=${cmd}"-netdev user,id=u2 "
    #cmd=${cmd}"-device e1000,netdev=u2,mac=52:54:00:12:34:56 "
    #cmd=${cmd}"-netdev tap,id=u2,ifname=tap1,script=no,downscript=no "
    #cmd=${cmd}"-device e1000,netdev=u2,mac=52:54:00:11:15:38 "
else
    echo "未使用tap，多个qemu虚拟机无法直接通过网桥互相访问"
fi

# open port for gdb
cmd=${cmd}"-gdb tcp::${port}"

# echo config
echo "kernel_path      : ${kernel_path}"
echo "rootfs_cpio_path : ${rootfs_cpio_path}"
echo "rootfs_img_path  : ${rootfs_img_path}"
echo "tap_name         : ${tap_name}"
echo "listen_port      : ${port}"

# star qemu
eval $cmd
