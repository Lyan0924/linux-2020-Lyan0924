# 无人值守安装iso制作过程

## 实现特性
+ 定制一个普通用户名和默认密码
+ 定制安装OpenSSH Server
+ 安装过程禁止自动联网更新软件包
---
## 软件环境
+ Virtualbox
+ Ubuntu 18.04 Server 64bit 
---
## 实验前配置
+ #### 新增一块网卡，实现NAT+host-only双网卡配置(右下角的搜狗输入法证明一下身份(^ ^))
<img src="image\host-only.png" >

+ #### 配置网卡，编辑/etc/netplan/01-netcfg.yaml,并使网卡配置生效  
    `sudo netplan apply`

+ #### 用ifconfig语句查询第二块网卡IP地址：192.168.203.3
  <img src="image\sec.png">
  
+ #### 开启ssh服务
    ````
    sudo apt-get install openssh-server
    sudo service ssh open
    ````
+ #### 通过putty连接linux机
<img src="image\putty.png">

+ #### 通过psptf向linux机传输ubuntu-16.04.1-server-amd64.iso文件

    `psftp> put C:\Users\dell\AppData\Local\Temp\ubuntu-16.04.1-server-amd64.iso`
<img src="image\psftp.png">
---
## 实验过程
+ #### 在当前用户目录下创建一个用于挂载iso镜像文件的目录  
    `mkdir loopdir`

+ #### 挂载iso镜像文件到该目录   
    `mount -o loop ubuntu-16.04.1-server-amd64.iso loopdir`

+ #### 创建一个工作目录用于克隆光盘内容  
    `mkdir cd`

+  #### 同步光盘内容到目标工作目录  
    `rsync -av loopdir/ cd`

+ #### 卸载iso镜像  
    `umount loopdir`

+ #### 进入目标工作目录  
    `cd cd/`

+  #### 编辑Ubuntu安装引导界面增加一个新菜单项入口  
    `vim isolinux/txt.cfg`  
    添加以下内容到该文件后强制保存退出
    ````
    label autoinstall
        menu label ^Auto Install Ubuntu Server
        kernel /install/vmlinuz
        append  file=/cdrom/preseed/ubuntu-server-autoinstall.seed debian-installer/locale=en_US console-setup/layoutcode=us keyboard-configuration/layoutcode=us console-setup/ask_detect=false localechooser/translation/warn-light=true localechooser/translation/warn-severe=true initrd=/install/initrd.gz root=/dev/ram rw quiet
    ````
    <img src="image\autoinstall.png">

+ #### 提前阅读并编辑定制Ubuntu官方提供的示例preseed.cfg，并将该文件保存到刚才创建的工作目录   
    `psftp> put C:\Users\dell\Desktop\ubuntu-server-autoinstall.seed cd/preseed/ubuntu-server-autoinstall.seed`
 

+ #### 修改isolinux/isolinux.cfg，增加内容timeout 10（可选，否则需要手动按下ENTER启动安装界面）
  
+ #### 重新生成md5sum.txt  
    `cd ~/cd && find . -type f -print0 | xargs -0 md5sum > md5sum.txt`

+ #### 封闭改动后的目录到.iso
    ```
    IMAGE=custom.iso
    BUILD=~/cd/
    mkisofs -r -V "Custom Ubuntu Install CD" \
            -cache-inodes \
            -J -l -b isolinux/isolinux.bin \
            -c isolinux/boot.cat -no-emul-boot \
            -boot-load-size 4 -boot-info-table \
            -o $IMAGE $BUILD
    ```
    <img src='image\iso.png'>
+ #### 将生成的custom.iso文件下载至本机,开始喝咖啡（不是），在虚拟机中进行无人值守安装  
    `psftp get custom.iso`
---
## 实验问题

+ #### 在很多步骤会报错permission denied，例如将ubuntu-server-autoinstall.seed文件传输至虚拟机指定文件时，以及重新生成md5sum.txt文件时

    解决：使用命令chmod命令修改权限


+ #### 最后从虚拟机下载iso文件到本地时报错local: unable to open auto.iso，修改权限后依然不行
    
    解决方法：将本地路径从C盘改成D盘  psftp> lcd D:\    

---
## 参考资料

+ 无人值守Linux安装镜像制作
  <https://blog.csdn.net/qq_31989521/article/details/58600426?utm_source=app>
+ 利用psftp传输文件
    <https://jingyan.baidu.com/article/d169e18658995a436611d8ee.html>