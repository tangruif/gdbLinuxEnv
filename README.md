# gdbLinuxEnv

### 依赖

#### 运行环境要求

* 需在linux环境中运行
* 推荐环境
  * ubuntu 14 ~ ubuntu 18
  * qemu 2.0.0
  * gdb 7.7.1

#### 在ubuntu系统中安装环境

* 安装此脚本

  * git clone --depth 1 git@github.com:tangruif/gdbLinuxEnv.git

* 安装依赖

  * sudo apt-get install qemu gdb

* 内核编译选项

  * 在编译配置文件：.config文件中，确保以下两项的值都为y，否则内核在qemu虚拟机中将无法联网

  ``` bash
  CONFIG_E1000=y
  CONFIG_PCI=y
  ```

* 快速开始

  * 确保内核已按照所要求的配置编译成功
    * 内核的x86_64架构编译结果位于Kernel/arch/x86_64/boot/bzImage，是一个可在裸机中执行的二进制文件
  * 制作内核启动所必须的根文件系统
    * 参考此代码库中ubuntu-fs/README.md，制作得到镜像文件rootfs_ubuntu.img
  * 在虚拟机中直接启动内核，并开启调试

  ``` bash
  # -k后面的参数为内核代码所在的目录
  ./qemu.sh -k /path/to/your/kernel -u ubuntu-fs/rootfs_ubuntu.img

  # 前一项中的虚拟机若成功打开，在另一个终端中执行以下脚本，对内核进行调试
  ./kernel-gdb.sh -k /path/to/your/kernel
  ```

### 内核调试介绍

#### 基本原理

##### qemu中内核的启动与调试示意图

![image](https://github.com/tangruif/gdbLinuxEnv/blob/master/images/gdb-linux%20(1).png)

##### 在qemu中启动内核

* 内核的编译结果

  * bzImage：被压缩的内核，可以在qemu中直接启动
  * vmLinux：完整内核，包括符号表等信息

* 内核的启动

  * Linux内核想要成功启动，需要有一个根文件系统
    * 直接使用qemu启动内核bzImage，会显示“ Kernel panic - not syncing : VFS : Unable to mount root fs on unknow block(0,0) "
  * **启动Linux内核必备的两个条件：(1)内核文件；(2)可供内核使用的根文件系统（此代码库中提供了制作与使用方式）**
 
#### 内核启动与调试脚本

qemu虚拟机在易用性上是灾难级别的，因此我们封装了几个脚本，用于启动与调试虚拟机
* qemu.sh
  * 在qemu-system-x86_64的基础上，对其主要配置项进行了封装，用于运行编译得到的内核
  * ./qemu.sh -h 可查看支持的命令行参数
* qemu_initrd.sh
  * 主要功能与qemu.sh脚本类似，不同之处在于此脚本导入的根文件系统将以initramfs的方式供内核使用
* kernel-gdb.sh
  * 在gdb的基础上，加上了一些固定的配置，用于单步调试在qemu中运行的内核
  * ./kernel-gdb.sh -h 可查看支持的命令行参数
* 内核的启动脚本

  -k : 导入内核代码所在目录（内核默认编译结果存储在此目录下的arch/x86_64/boot/bzImage）

  -f（仅qemu_initrd.sh支持） : 导入根文件系统的压缩包，需要为cpio文件，制作方式见下文《制作最小文件系统》
  
  -u (仅qemu.sh支持): 导入根文件系统的压缩包，需要为raw文件，制作方式见下文《制作ubuntu-server文件系统》
  
  -t 使用网桥时使用此参数。网桥启用方式此代码库bridges/README.md
  
  -p qemu在宿主机上监听的TCP端口号，默认为1234，供调试使用

  ``` bash
  # 使用rootfs.cpio.gz文件作为文件系统，不使用网桥，监听端口1234
  ./qemu_initrd.sh \
      -k ../Kernel \
      -f rootfs.cpio.gz
  # 使用rootfs.img文件作为文件系统，通过虚拟网口tap0连接到网桥，监听端口2345
  ./qemu.sh \
      -k ../Kernel \
      -u ubuntu-fs/rootfs_ubuntu.img \
      -t tap0 \
      -p 2345
  ```
* 内核的调试脚本
  * 示例

  * 启动qemu虚拟机，开启端口2345

    ```bash
    ./qemu.sh
    	-k ../Kernel \
    	-u ubuntu-fs/rootfs_ubuntu.img \
    	-p 2345
    ```

  * 启动gdb进行调试，连接端口2345

    ``` bash
    ./kernel-gdb.sh \
    	-k ../Kernel \
    	-p 2345
    ```
* 为何还需要区分qemu_initrd.sh？
  
  一般情况下，将ubuntu-server作为虚拟机的根文件系统，使用qemu.sh脚本开启虚拟机并调试，是最方便的做法。
  然而这种方法并不完美，ubuntu系统本身较大，耗费资源，除此之外，如果内核尚不稳定，经常panic，在ubuntu中体现为直接死机，不方便追踪原因。
  因此，我们基于buildroot构建了最小文件系统，将其放在压缩包rootfs.tar中，参照本文档下方的《制作最小文件系统》，可使用此压缩包制作成可供qemu使用的文件系统。通过qemu_initrd.sh脚本导入此系统使用，有几个特点：
  * 系统很小，耗费资源少，纯软件虚拟机也可轻松运行（如x86上模拟arm）
  * 无记忆性，在虚拟机中进行的文件修改不会影响rootfs.cpio.gz本身
  * 内核日志直接输出到屏幕，可以很方便地查看panic日志
  
  总体来说，这个文件系统使用上虽不方便，但仍有其不可替代性，因此保留了下来。
    
#### 在虚拟机中使用桥接网络

* 桥接网络可解决的问题：
  * 多个虚拟机之间进行网络通信
  * 虚拟机可配置静态IP地址，并通过NAT访问外部网络
* 教程见此代码库中bridges/README.md

### 根文件系统

#### 制作ubuntu-server文件系统

  * 简单的制作与使用方式见此代码库ubuntu-fs/README.md

  * 自行制作ubuntu-server文件系统
    * 见后文【参考资料】1、2、3。参考资料中多为基于ARM64平台构建，我们则一般使用x86_64进行模拟。两个平台的文件系统构建方式基本相同，主要不同点有二：
      * 下载/编译的buildroot软件包或者ubuntu-server需要为x86_64（AMD64）版本
      * ARM64上的串口为ttyAMA0，对应到x86_64上为ttyS0

#### 制作最小文件系统

代码库中直接包含了一个roofs压缩包：

 * rootfs.tar压缩包，其中包含了一个足以支持linux内核运行的根文件目录（包括/dev、/bin等目录）。我们建议保持rootfs.tar压缩包不变，以这个目录为基准制作rootfs。

* 如何制作文件系统

  1. 解压原始文件系统rootfs.tar

  * 产生新目录**rootfs**，可以作为linux的文件系统，与内核一起启动

  ``` bash
  tar -xf rootfs.tar
  ```

  2. 修改**rootfs目录**下的内容，向其中增加或减少文件（可选）

    * 如果要加入可执行文件，可执行文件在编译时需增加 -static 选项，这样编译出来的文件就不会有外部依赖（无动态链接）

    ``` bash
    # 例如：将main.c编译为main
    gcc main.c -static -o main
    # 将可执行文件main放入rootfs目录
    cp main gdbLinuxEnv/rootfs/root
    ```

  3. **压缩rootfs目录**，供虚拟机使用

  * 构建rootfs.cpio.gz文件系统镜像

    ``` bash
    sh gen_rootfs.sh
    ```

  4. 运行qemu_initrd.sh脚本，使用上一步制作得到的rootfs.cpio.gz压缩包作为文件系统
     ```bash
     ./qemu_initrd.sh -f rootfs.cpio.gz
     ```

### 参考资料

1. https://medicineyeh.wordpress.com/2016/03/29/buildup-your-arm-image-for-qemu/
2. http://wiki.t-firefly.com/en/ROC-RK3399-PC/linux_build_ubuntu_rootfs.html
3. https://chasinglulu.github.io/2019/07/27/%E5%88%A9%E7%94%A8Qemu-4-0%E8%99%9A%E6%8B%9FARM64%E5%AE%9E%E9%AA%8C%E5%B9%B3%E5%8F%B0/
4. https://gist.github.com/extremecoders-re/e8fd8a67a515fee0c873dcafc81d811c
