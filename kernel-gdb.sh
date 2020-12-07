#!/bin/bash

usage() {
    echo "Usage:"
    echo "  kernel-gdb.sh [-p PORT]"
    echo "Description:"
    echo "  PORT , 连接到指定的qemu虚拟机端口，进行内核调试"
    exit 1
}

cur_dir=$(cd "$(dirname "$0")"; pwd)

port=1234

cmd="cd ${cur_dir}/../newip && gdb vmlinux -tui -ex \"set arch i386:x86-64\" "

while getopts p:h option
do
    case "${option}" in
        p)port=${OPTARG};;
        h)usage;;
        ?)usage;;
    esac
done

cmd=${cmd}"-ex \"target remote localhost:${port}\" "

# start gdb
eval $cmd
