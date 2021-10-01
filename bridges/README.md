# qemu虚拟机使用桥接网络

### 快速开始

* 安装依赖
  ```bash
  sudo apt-get install uml-utilities bridge-utils virt-manager
  ```

* 创建四个虚拟网口tap0、tap1、tap2、tap3，并连接到虚拟网桥virbr0
 
  ``` bash
  ./enable-bridge.sh
  ```

* 开启两个qemu虚拟机，测试连接情况

  * 一号虚拟机
  ```
  ./qemu.sh -t tap0
  ``` 

  * 二号虚拟机
  ```
  ./qemu.sh -t tap1
  ```

  * 手动配置ip地址，测试能否ping通 

### 删除网桥

``` bash
./disable-bridge.sh
 ```

### 更多

* 此方法借用了virt-manager自动创建的带有NAT以及DHCP功能的虚拟网桥virbr0，虚拟网口tap0~3将被连接到此虚拟网桥上
* 可在虚拟机中通过DHCP client获取本机IP地址，或者配置一个192.168.122.0/24网段的静态IP地址，并将192.168.122.1作为默认网关
  * 静态IP地址的配置具体需要参照本机虚拟网桥virbr0的IP地址

* 希望让更多虚拟机连接到网桥？
  * 每个虚拟机需要连接到一个不同的虚拟网口tap，通过虚拟网口访问网桥virbr0
  * 目前默认创建的虚拟网口数量为4个，分别为tap0～tap3，若需要更多，可修改脚本enable_bridge.sh，仿照里面的写法增加tap4、tap5等更多虚拟网口

