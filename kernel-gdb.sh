#!/bin/bash

usage() {
    echo "Usage:"
    echo "  kernel-gdb.sh [-k KERNEL_PATH] [-p PORT]"
    echo "Description:"
    echo "  KERNEL_PATH , 内核代码所在的路径。默认路径为../newip/Kernel"
    echo "  PORT , 连接到指定的qemu虚拟机端口，进行内核调试"
    exit 1
}

cur_dir=$(cd "$(dirname "$0")"; pwd)

port=1234

kernel_dir_path=${cur_dir}"/../newip/Kernel"

while getopts k:p:h option
do
    case "${option}" in
        p)port=${OPTARG};;
        k)kernel_dir_path=${OPTARG};;
        h)usage;;
        ?)usage;;
    esac
done

cmd="cd ${kernel_dir_path} && gdb vmlinux -tui -ex \"set arch i386:x86-64\" "

cmd=${cmd}"-ex \"target remote localhost:${port}\" "

# start gdb
eval $cmd
