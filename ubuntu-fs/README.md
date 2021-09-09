# 如何在qemu虚拟机中导入ubuntu文件系统

### 快速开始
 
  1. 制作ubuntu-server文件系统
     执行制作脚本，此脚本将自动下载ubuntu-16.04-server软件包，并将其制作成为可供qemu使用的文件系统
     ```bash
     cd gdbLinuxEnv/ubuntu-fs
     ./gen_img.sh
     ```

  2. 基于ubuntu-server文件系统运行内核
     上一步中得到的ubuntu-server文件系统镜像默认名称为rootfs_ubuntu.img
     ```bash
     cd gdbLinuxEnv/
     ./qemu.sh -u ubuntu-fs/rootfs_ubuntu.img
     ```
     若上一步启动成功，会提示输入账号与密码。虚拟机中默认只有root账户，密码也为root
     ```bash
     Ubuntu 16.04.6 LTS localhost.localdomain ttyS0

     localhost login: root
     Password:(输入“root”)
     ```

  3. 常见问题

     1. 虚拟机中如何连接网络？

        为了轻便与灵活，使用gen_img.sh脚本制作的文件系统中未安装NetworkManager，因此，无论虚拟机使用的是默认主机网络（使用qemu.sh脚本时不加-t参数），还是桥接网络（见gdbLinuxEnv/bridges)，都需要在开启虚拟机后手动连接网络。
        ```bash
        # 开启虚拟机后
        ifconfig eth0 up
        udhcpc -i eth0
        ```
        如果嫌麻烦，可以将上述命令加入开机脚本中，或者安装NetworkManager

     2. 自定义ubuntu-server文件系统
        
        如果对默认制作的ubuntu-server不太满意，可以在虚拟机中安装自己想要的各类环境，安装方式与普通ubuntu-server一致，使用apt-get安装与管理软件包。
        如果要做更多改动，例如更换ubuntu-server的版本，也可以通过修改gen_img.sh脚本来修改默认文件系统的制作方法。gen_img.sh脚本中有足够的注释，按照提示进行定制化即可
        
  
     3. 如何在虚拟机和实体机器之间传输文件？

        此方法适用前提：虚拟机通过bridge连接网络

        简易方法：在虚拟机中通过apt-get安装openssh-server，然后通过scp进行文件传输

        例：

        ```bash
        # 虚拟机ip为192.168.122.22
        scp route.c root@192.168.122.22:/root/route.c
        ```
