# 如何在qemu虚拟机中导入ubuntu文件系统

### 快速开始

  1. 下载制作好的ubuntu文件系统

  文件900+MB，放不下，且windows下保存此格式文件会出问题，直接从我的电脑上ftp下载吧。

  ```bash
  # 假设处于gdbLinuxEnv/ubuntu-fs目录下
  wget ftp://10.108.110.27/rootfs-ubuntu.img
  ```

  2. 运行

  * 读取的内核来源于newip中自编译的内核

  * 此文件系统具有记忆性。如果想往虚拟机中加入文件，直接从虚拟机中联网下载即可。 

  * 假设下载的ubuntu文件系统路径为：ubuntu-fs/rootfs-ubuntu.img 

  ```bash
  ./qemu.sh -u ubuntu-fs/rootfs-ubuntu.img (-t tap0  推荐使用tap，提供更好的联网支持。详情见bridge/README.md)
  ```
  3. 常见问题

     1. 虚拟机如何登录北邮校园网？

       文件系统中，/root/bupt_log_in.sh脚本可帮助你进行登录

       使用方式：

       ```bash
       /root/bupt_log_in.sh 2020111XXX(学号) 123456(校园网登录密码)
       ```

     2. 如何在虚拟机和实体机器之间传输文件？

       此方法适用前提：虚拟机通过bridge连接网络

       ubuntu文件系统中安装了ssh以及ssh-server，因此可以通过scp进行文件传输

       例：

       ```bash
       # 虚拟机ip为10.108.110.152
       scp route.c root@10.108.110.152:/root/route.c
       ```
