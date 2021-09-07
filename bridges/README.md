# qemu虚拟机使用桥接网络

### 快速开始

* 安装依赖
  ```bash
  sudo apt-get install uml-utilities bridge-utils
  ```

* 建立网桥，并创建四个虚拟网口tap0、tap1、tap2、tap3，通过网桥连接
 
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

* 此方法仅为简易用法，通过这种方式创建桥接网络，虚拟机将无法连接外部网络
  * 若想要连接外部网络，可将qemu.sh中tap_name变量改为空字符串，此时使用主机网络
* 若想要更好的体验，通过virt-manager等工具创建一个带有NAT、DHCP等功能等完整网桥，并将虚拟机连接到这样的网桥上
