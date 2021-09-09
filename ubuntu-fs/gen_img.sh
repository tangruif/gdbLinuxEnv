#!/bin/bash

# 修改四个变量，以此来修改需要创建的文件系统属性
ubuntu_img_url=http://cdimage.ubuntu.com/ubuntu-base/releases/16.04/release/ubuntu-base-16.04.6-base-amd64.tar.gz
ubuntu_server_tar_gz_path=ubuntu-16.04.6-amd64.tar.gz
rootfs_name=rootfs_ubuntu.img
img_size=4096

# 下载ubuntu-server文件系统镜像
if [ ! -e ${ubuntu_server_tar_gz_path} ]
then 
	wget ${ubuntu_img_url} -O ${ubuntu_server_tar_gz_path}
fi

# 创建img文件，并ext3格式化
dd if=/dev/zero of=${rootfs_name} bs=1M count=${img_size}
mkfs.ext3 ${rootfs_name}
 
# 将img文件挂载到目录，修改目录中的内容即修改img镜像内的内容
mkdir -p tmpfs
sudo mount -t ext3 ${rootfs_name} tmpfs/ -o loop

# 解压ubuntu-server到目录中
sudo tar -xzf ${ubuntu_server_tar_gz_path} -C tmpfs/

# 复制系统DNS设置
sudo cp -b /etc/resolv.conf tmpfs/etc/resolv.conf

# 以tmpfs作为根目录进行操作
sudo chroot tmpfs /bin/bash <<"EOT"

# 提前安装常用的一些软件包
apt-get update
apt-get install udhcpc bash-completion -y
apt-get install net-tools iputils-ping -y

# 设置root用户密码为root
echo -e "root\nroot" | passwd root

# 设置串口ttyS0，便于将虚拟机的输入输出重定向到当前宿主机终端中
cp lib/systemd/system/serial-getty\@.service lib/systemd/system/serial-getty\@ttyS0.service
sed -i.bak 's/BindsTo=dev-%i.device/#BindsTo=dev-%i.device/g' lib/systemd/system/serial-getty\@ttyS0.service
sed -i.bak 's/After=dev-%i.device/#After=dev-%i.device/g' lib/systemd/system/serial-getty\@ttyS0.service
systemctl enable serial-getty\@ttyS0.service

exit
EOT

# 操作完成，取消挂载
sudo umount tmpfs
rmdir tmpfs
