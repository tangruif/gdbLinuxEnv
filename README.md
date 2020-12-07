# gdbLinuxEnv
### 依赖
#### 运行环境要求
* 需在linux环境中运行
* 推荐环境
	* ubuntu 14.04
	* qemu 2.0.0
        * gdb 7.7.1
#### 在ubuntu系统中安装环境
* 安装此脚本
  * git clone --depth 1 git@github.com:tangruif/gdbLinuxEnv.git
  * 请将此代码目录与linux代码目录放在同级别文件夹下
  ``` bash
  tangruifeng@tangruifeng-System-Product-Name:~/linux-newip $ tree -L 1
  .(父目录)
  ├── gdbLinuxEnv(git clone下载下来的代码目录)
  ├── net-tools
  └── newip(Linux内核代码目录)
  ```
* 安装依赖
  * sudo apt-get install qemu gdb
* 内核编译选项
  * 在编译配置文件：.config文件中，确保以下两项的值都为y，否则内核在qemu虚拟机中将无法联网
  ``` bash
  CONFIG_E1000=y
  CONFIG_PCI=y
  ```
### 建立虚拟机最小文件系统
```
qemu启动虚拟机时，除了需要导入linux内核，还需要导入一个linux系统的根文件目录(一般简称rootfs)。
一般的使用方法是，把一个linux根文件目录制作成压缩包，交给qemu运行。
```
这里提供了一个roofs压缩包：
 * rootfs.tar压缩包，其中包含了一个足以支持linux内核运行的根文件目录（包括/dev、/bin等目录）。我们建议保持rootfs.tar压缩包不变，以这个目录为基准制作rootfs。

* 如何制作文件系统
  1. 解压原始文件系统rootfs.tar
  
  * 产生新目录**rootfs**，可以作为linux的文件系统，与内核一起启动
  ``` bash
  tar -xf rootfs.tar
  ```
  2. 修改**rootfs目录**下的内容，向其中增加或减少文件
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
  4. 运行虚拟机，此时使用rootfs.cpio.gz压缩包作为文件系统

### 运行
    
1. 在虚拟机中运行linux系统（会自动导入newip目录下自己最新编译得到的内核）
    1. 开启qemu虚拟机，读取自编译内核，导入rootfs.cpio.gz文件系统，开启1234端口监听
    ```
    ./qemu.sh
    ```
    2. 命令行停止时，会提示输入账号密码
    3. 账号和密码都是root
    4. 接下来的操作为基本linux操作（运行在虚拟机中）
2. 使用gdb调试linux系统
    1. 新开一个terminal
    2. 运行gdb，通过tcp的1234端口连接到qemu虚拟机
    ```
    ./kernel-gdb.sh
    ```
    3. 接下来的使用方法和gdb相同
      * gdb主要命令
      ``` bash
      # 断点
      break ninet_ioctl(= b ninet_ioctl)
      # 单步运行
      next(= n)
      # 单步进入
      step(= s)
      # 输出变量值
      print cmd(= p cmd)
      # 退出gdb
      quit(= q)
      # 查看断点信息
      info break
      # 删除断点
      d number(number = info break中查看到的断点编号)
      ```
### 更多功能

1. 相关文档

    * ubuntu-fs/README.md：使用ubuntu文件系统运行虚拟机
    
    * bridge/README.md：建立网桥，给虚拟机提供更好的网络支持。虚拟机之间可以通过ip地址进行通信。

2. 开启/调试多个qemu虚拟机

    1. 避免端口冲突

       由于对qemu虚拟机中内核的调试需要一个tcp端口，如果想同时调试多个虚拟机，需要自定义端口号

       例：

       1. 开启虚拟机与gdb，端口为1234

       ```
       ./qemu.sh
       ```
       ```
       ./kernel-gdb.sh
       ```

       2. 开启另一个虚拟机与gdb，端口为2345
       ```
       ./qemu.sh -p 2345
       ```
       ```
       ./kernel-gdb.sh -p 2345
       ```

    2. 避免两个虚拟机同时读写同一个文件系统

       当启动qemu.sh未加-u选项时，使用的文件系统为rootfs.cpio.gz，此文件系统不会被虚拟机修改。因此多个虚拟机同时使用这个文件系统不会产生冲突。
       
       当使用-u选项，指定一个文件系统来启动qemu虚拟机时，文件系统是具备记忆性的。此时需注意不要同时启动多个虚拟机读取同一个文件系统。

       例：

       1. 开启一个虚拟机，使用ubuntu文件系统(假设保存在ubuntu-fs/rootfs-ubuntu.img)，使用bridge联网，监听端口1234
       
       ```
       ./qemu.sh -u ubuntu-fs/rootfs-ubuntu.img -t tap0 -p 1234
       ```
     
       2. 开启第二号虚拟机，需要使用另一个文件系统

       ```
       # 最简单的方法，可以复制一个文件系统
       cp ubuntu-fs/rootfs-ubuntu.img ubuntu-fs/rootfs-ubuntu.img.2
   
       # 启动第二个虚拟机
       ./qemu.sh -u ubuntu-fs/rootfs-ubuntu.img.2 -t tap1 -p 2345

       ```


### 参考资料
1. https://medicineyeh.wordpress.com/2016/03/29/buildup-your-arm-image-for-qemu/
2. http://wiki.t-firefly.com/en/ROC-RK3399-PC/linux_build_ubuntu_rootfs.html
3. https://gist.github.com/extremecoders-re/e8fd8a67a515fee0c873dcafc81d811c
