# 项目简介
自用固件, 适配斐讯 N1, 以极致的轻量为目标, 专注于旁路由/透明代理 + 内网穿透/异地组网 <br>
## 特点
  - 无PPPoE拨号功能
  - 无WLAN支持
  - 使用默认Bootstrap主题
  - 完整 IPv6 支持
  - lan区域默认为DHCP客户端模式
  - Bandix网络统计

## 预装软件包
### [luci-app-easytier](https://github.com/EasyTier/luci-app-easytier) Easytier组网工具
用于异地组网 <br>
### luci-app-openclash / luci-app-homeproxy / 手搓旁路由
前面两者占用大差不差, N1有2G内存, 对一个旁路由而言肯定是够的. 但考虑到现在sing-box已经支持clash-api了, 而mihomo却还不支持prefer ipv4的dns解析策略, 可以逐渐转向homeproxy <br>
如果都不喜欢, 可以手搓旁路由, 相较于在普通Linux上手搓, Openwrt肯定还是方便些的. <br>
### luci-proto-wireguard
启用Wireguard支持

## 未安装软件包
### [luci-app-dockerman](https://github.com/lisaac/luci-app-dockerman)
原因: 我不需要 <br>
用于docker 管理, 如果docker bridge网络的容器无法上网，检查网络 -> 防火墙，检查docker区域是否被允许转发流量至上网区域(对于N1, 一般是LAN区域)，或者直接将接口docker0的防火墙区域设置为lan <br>
### [luci-app-amlogic](https://github.com/ophub/luci-app-amlogic) 晶晨宝盒
用于系统更新、固件刷写、CPU 调频等 <br>
系统刷写其实就是调用 /usr/sbin/openwrt-install-amlogic, 这个脚本和 /root/install-to-emmc.sh 是完全一样的, 都会在emmc里搞4个完全没必要的分区 <br>
末尾有安装/刷写/更新教程 <br>
# 安装后的注意事项
在/root目录下有安装到eMMC的脚本, 不要更改其内容 <br>

## 安装后应做的事
1: 前往 `网络` -> `接口` <br>
将lan6的防火墙区域调整为lan <br>
<br>

2: 还是在 `接口` 页面 <br>
关闭lan区域的dhcp服务器, 并将IPv6 DHCP相关项全部禁用 <br>
> 并不是说旁路由和IPv6天生八字不和, 只是大部分设备自己改不了IPv6网关, 导致若DNS解析到ipv6, 一定绕过旁路由走直连

3: 前往SSH, 修改/usr/lib/lua/luci/view/easytier/easytier_status.htm <br>
删掉如下这行. 在新版本OpenWRT中会显示异常 <br>
```html
html += "<tr><td style='padding:2px 16px 2px 0;'>当前 / 最新版本</td><td>" + data.ettag + " / " + data.etnewtag + "</td></tr>";
```
## 换源
由于是基于大版本(v25.12)的snatshot版本构建的, 换源时为了兼容性考虑不建议换用小版本(v25.12.x)的源 <br>
由于内核不是官方内核, 换源时不建议添加kmod源 <br>
当然, 如果内核版本和官方版本相差不大, 可酌情换用 <br>
```text
# kmod源酌情取用
#https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/targets/armsr/armv8/kmods/6.12.66-1-a0026a4d4ab31711433cd3614cd1ad46 

https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/targets/armsr/armv8/packages/packages.adb
https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/packages/aarch64_generic/base/packages.adb
https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/packages/aarch64_generic/luci/packages.adb
https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/packages/aarch64_generic/packages/packages.adb
https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/packages/aarch64_generic/routing/packages.adb
https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/packages/aarch64_generic/telephony/packages.adb
```
## Q&A
### N1盒子在作为旁路由时测速跑不满或者很低(100M左右)
在排除软件, 网线质量等外部因素后, 只可能是内核或者硬件的问题了 <br>
但硬件故障的可能性其实非常小, 几乎可以忽略 <br>

我遇到过N1测速只有30M或者100M左右的问题, 或者先跑很高, 而后快速下降的速率, 后通过换用不同版本的内核, 发现部分版本可以解决测速慢, 但仍然跑不满, 最多也就400M左右 <br>

这些内核版本是我在彻底解决这个问题前一个一个试出来的, 均使用meson-gxl-s905d-phicomm-n1.dtb
  - 6.12.65-flippy-94+: 有问题, N1跑100M左右
  - 6.6.120-flippy-94+: 400M左右
  - 6.6.123-flippy-94+ from ophub: 400M左右
  - 6.1.160-flippy-94+: 系统无法启动
  - Armbian 6.12.68-ophub: 100M左右 (固件是直接从ophub github下载的, 非自编译)
  - Armbian 6.1.161-ophub: 400M左右 (同上)

一次偶然的机会, 我发现N1盒子有个 dma-thresh 的dtb, 我于是去搜索了以下, 找到了这个帖子 [Ref](https://www.znds.com/tv-1179307-1-1.html) <br>
这个帖子说flow control off时, 测速不正常, 时快时慢, 我对比了以下, 发现和我的情况高度吻合, 偶尔能跑满, 偶尔只有几十M, 但部分内核(比如6.12系列), 稳定跑不满(200M左右) <br>

到这里, 情况就很简单了:
  - 如果使用的是不带 -dma-thresh 的dtb, 进行第二步
  - 执行 dmesg | grep "flow control", 查看网卡流控情况, 如果是off, 进行第三步; 如果是 rx/tx, 你的N1应该是能跑满转发性能的, 不用继续看了
  - 修改 /boot/uEnv.txt, 修改FDT指向的dtb文件, 新的dtb文件名为: meson-gxl-s905d-phicomm-n1-thresh.dtb
  - 重启系统. 在指定新的dtb后, flow control应该总是off了, 因为此时使用软件流控了

不得不说, 网上几乎没有关于这个dtb的介绍, 提及这个的也就几个网站 <br>

# 从USB全新安装到eMMC操作
N1盒子没有主线uboot
### 手动删除emmc所有分区
这一步没有教程, 自行备份数据!
### 写Bootloader
在Release页面发布的固件是刷写到USB设备里面的, 并不包含uboot <br>
一般而言, 是不用写uboot到eMMC里面的, 毕竟你能通过dd写, 就代表你已经启动了Linux, 代表板载uboot是完好的 <br>
如果你不小心通过某些操作误删了uboot, 执行如下命令来恢复原厂uboot <br>
```shell
dd if=u-boot-2015-phicomm-n1.bin  of=/dev/mmcblk2 conv=fsync,notrunc bs=1 count=444
dd if=u-boot-2015-phicomm-n1.bin  of=/dev/mmcblk2 conv=fsync,notrunc bs=512 skip=1 seek=1
# 第一个扇区 = 文件u-boot-2015-phicomm-n1.bin前面444字节 + 68字节(存储MBR分区表)
# 之后的扇区 = 从文件u-boot-2015-phicomm-n1.bin的512 byte开始的内容
# 总共写8000个Sector
```
### 分区信息
我的N1设备之前刷过原厂系统, 后来又在这个仓库编译了自用的openwrt固件
```
ampart /dev/mmcblk2
===================================================================================
ID| name            |          offset|(   human)|            size|(   human)| masks
-----------------------------------------------------------------------------------
 0: bootloader                      0 (   0.00B)           400000 (   4.00M)      0  上一步写原厂uboot就是写的这里
    (GAP)                                                 2000000 (  32.00M)
 1: reserved                  2400000 (  36.00M)          4000000 (  64.00M)      0
    (GAP)                                                  800000 (   8.00M)
 2: cache                     6c00000 ( 108.00M)         20000000 ( 512.00M)      2
    (GAP)                                                  800000 (   8.00M)
 3: env                      27400000 ( 628.00M)           800000 (   8.00M)      0  uboot env信息
    (GAP)                                                  800000 (   8.00M)
 4: logo                     28400000 ( 644.00M)          2000000 (  32.00M)      1
    (GAP)                                                  800000 (   8.00M)
 5: recovery                 2ac00000 ( 684.00M)          2000000 (  32.00M)      1
    (GAP)                                                  800000 (   8.00M)
 6: rsv                      2d400000 ( 724.00M)           800000 (   8.00M)      1
    (GAP)                                                  800000 (   8.00M)
 7: tee                      2e400000 ( 740.00M)           800000 (   8.00M)      1
    (GAP)                                                  800000 (   8.00M)
 8: crypt                    2f400000 ( 756.00M)          2000000 (  32.00M)      1
    (GAP)                                                  800000 (   8.00M)
 9: misc                     31c00000 ( 796.00M)          2000000 (  32.00M)      1
    (GAP)                                                  800000 (   8.00M)
10: boot                     34400000 ( 836.00M)          2000000 (  32.00M)      1
    (GAP)                                                  800000 (   8.00M)
11: system                   36c00000 ( 876.00M)         50000000 (   1.25G)      1
    (GAP)                                                  800000 (   8.00M)
12: data                     87400000 (   2.11G)        14ac00000 (   5.17G)      4
===================================================================================

fdisk -l /dev/mmcblk2
/dev/mmcblk2p1       139264  1187839 1048576  512M  c W95 FAT32 (LBA)
/dev/mmcblk2p2      1638400  3604479 1966080  960M 83 Linux
/dev/mmcblk2p3      3604480  5570559 1966080  960M 83 Linux
/dev/mmcblk2p4      5570560 15269887 9699328  4.6G 83 Linux

eMMC安装脚本内定义的固件分区结构
68 MiB -  Boot分区(512MiB) -- 220 MiB  -- Rootfs1分区 -- Rootfs2分区
Boot分区从reserved分区的一半的位置开始写, 写了512MiB, 刚好写到cache分区末尾, 但却没动到env分区
```
很明显, 这个用不到的cache分区占了512M, 纯浪费, 但由于晶晨规定前四个分区必须是"引导程序, 保留, 缓存, 环境" <br>
所以使用如下命令重新分区: ( **丢失数据警告! 备份! **) <br>
```shell
# 重新划分eMMC分区表 (EPT) (ophub armbian固件便是用的这个)
ampart /dev/mmcblk2 --mode dclone data::-1:4
# 以最简洁的方式划分 EPT
ampart /dev/mmcblk2 --mode ecreate data:::

# 具体区别查看: https://github.com/7Ji/ampart/blob/master/README_cn.md
```
直接执行的话会大概因为dtb文件加密了导致该命令并无效果, 需要遵从[Here](https://7ji.github.io/crack/2023/01/08/decrypt-aml-dtb.html)的教程解密

### 在eMMC上创建新的boot分区和rootfs分区并格式化
```shell
fdisk /dev/mmcblk2
p 打印分区表
n 新建分区, 起始扇区是139264, 结束扇区是1185791, 共计512M的Boot分区
n 新建分区, 起始: 1638400, 结束: 15269887, 共计6.5G的rootfs

mkfs.fat -F32 -L BOOT_EMMC /dev/mmcblk2p1
mkfs.btrfs -m single -L rootfs /dev/mmcblk2p2

# 获取这两个分区的UUID
blkid
```
### 挂载Boot分区, 把USB上的boot分区复制过去
```shell
mount /dev/mmcblk2p1 /mnt
cp -rf /boot/* /mnt
rm /mnt/s905* /mnt/aml*

# 修改 /mnt/boot/uEnv.txt, 改emmc rootfs uuid
APPEND=root=UUID=<EMMC_ROOTFS_UUID> rootfstype=btrfs rootflags=compress=zstd:6 console=ttyAML0,115200n8 console=tty0 no_console_suspend consoleblank=0 fsck.fix=yes fsck.repair=yes net.ifnames=0 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1

# 卸载 BOOT分区
umount /mnt
```
### 挂载rootfs, 复制USB上的文件过去
或者直接`dd if=/dev/sda2 of=/dev/mmcblk2p2 bs=1M status=progress` + `btrfs filesystem resize max /` 也行
```shell
mount -t btrfs -o compress=zstd:6 /dev/mmcblk2p2 /mnt

mkdir -p /mnt/{bin/,boot/,dev/,etc/,lib/,mnt/,overlay/,proc/,rom/,root/,run/,sbin/,sys/,tmp/,usr/,www/}
cd /mnt && ln -s tmp var && ln -s lib lib64

# 在根目录下新建一个sh脚本, 再chmod +x *.sh, 再执行这个脚本 (注意要在根目录执行)
#!/bin/sh
COPY_SRC="bin etc lib root sbin usr www"
for src in ${COPY_SRC}; do
    if [[ -d "${src}" ]]; then
        echo -e "Copying [ ${src} ] ..."
        tar -cf - ${src} | (
            cd /mnt
            tar -xpf -
        )
    fi
done

exit 0
```

```shell
# 修改 /mnt/etc/fstab, 写入两行:
UUID=<EMMC_ROOTFS_UUID> /     btrfs compress=zstd:6 0 1
LABEL=BOOT_EMMC   /boot vfat  defaults        0 2

# 修改 /mnt/etc/config/fstab
config  global
        option anon_swap '0'
        option anon_mount '0'
        option auto_swap '0'
        option auto_mount '0'
        option delay_root '5'
        option check_fs '0'

config  mount
        option target '/rom'
        option uuid '<EMMC_ROOTFS_UUID>' # 注意两端引号别掉了
        option enabled '1'
        option enabled_fsck '1'
        option fstype 'btrfs'
        option options 'compress=zstd:6'

config  mount
        option target '/boot'
        option label 'BOOT_EMMC'
        option enabled '1'
        option enabled_fsck '1'
        option fstype 'vfat'
```
### 移动部分文件
```
mv <eMMC>/etc/config/balance_irq <eMMC>/etc/balance_irq
```
## 完成
总脚本
```shell
#!/bin/sh

cd /mnt && mkdir boot rootfs
mount /dev/mmcblk2p1 /mnt/boot
rm /mnt/boot/s905* /mnt/boot/aml*
mount -t btrfs -o compress=zstd:6 /dev/mmcblk2p2 /mnt/rootfs

cd /
tar -cf - boot | tar -xpf - -C /mnt

COPY_SRC="bin etc lib root sbin usr www"
for src in ${COPY_SRC}; do
    if [[ -d "${src}" ]]; then
        echo -e "Copying [ ${src} ] ..."
        tar -cf - ${src} | (
            cd /mnt/rootfs
            tar -xpf -
        )
    fi
done

cd /mnt/rootfs
mkdir boot dev mnt proc overlay rom run sys tmp

ln -s tmp var && ln -s lib lib64

blkid | grep /dev/mmcblk2

vim /mnt/boot/uEnv.txt
vim /mnt/rootfs/etc/fstab
vim /mnt/rootfs/etc/config/fstab

umount /mnt/*
```

# Amlogic 启动顺序
> Amlogic设备按住reset按键再启动时, 会进入升级模式, 此时会去加载aml autoscript

原厂aml autoscript的内容我们不得而知, 原厂uboot env bootcmd肯定只能启动emmc内的固件, 如果原厂bootcmd能从U盘启动, 原厂系统应该可以直接启动外置USB系统才对的, 但事实并非这样<br>

以N1为例, 在第一次刷入新的系统后, uboot env还是原厂的, 此时的uboot只能启动刷入的安卓TV固件, 但在固件内执行升级指令后, 再在合适的时间插入U盘, 使其能被刚好进入升级模式的SoC读取我们修改过的aml autoscript, 该脚本首先覆写了官方uboot env, 使其能按 mmc(sd卡) -> usb -> eMMC顺序尝试启动, 当然, N1没有SD卡接口, 自然只用看后面两个就行了<br>

无论是从SD还是USB, 其启动env command都是加载s905 autoscript; 若是从eMMC, 则加载emmc_autoscript; 加载完后都使用autoscr命令来运行目标脚本<br>
在覆写完env之后, 再执行:<br>
setenv upgrade_step 2 退出升级模式<br>
saveenv 保存env信息<br>

之后以正常模式启动时, 原厂uboot会按我们修改的命令依次尝试启动<br>
在这之后, aml autoscript就不再有用了, 我们已经可以从USB启动Linux, 但为了固件的通用性考虑, 让别人刚进入升级模式的盒子也能用, 故保留该文件<br>

> s905_autoscript和emmc_autoscript类似, 都负责读取uEnv.txt, 加载kernel dtb之类的东西, 加载完了再booti启动内核

emmc autoscript内容: <br>
若板载eMMC第一个分区内有u-boot.emmc, 则直接跳转到其执行(uboot overload) <br>
加载uEnv.txt kernel initrd dtb, 后booti启动 <br>
# Amlogic原厂Uboot分析
原厂提取出来的uboot: u-boot-2015-phicomm-n1.bin
0x0 - 0x200 : 512 Bytes, 全是0, 这是MBR的一个扇区, 动不了
0x200 - 0xA4400 : 共1313个扇区, 应该是uboot二进制文件
0xA4400 - 0xA8040: 未知, 信息量不多
貌似没有Env信息在这里面
# eMMC安装脚本分析
在emmc install脚本里, 先写了android uboot, 后再把u-boot-n1.bin命名成u-boot.emmc, 即uboot重载 (板载uboot -> 重载uboot) <br>
真正写到emmc里的是安卓用的那个uboot: u-boot-2015-phicomm-n1.bin <br>

See: <br>
  - [uBoot overload](https://github.com/ophub/amlogic-s9xxx-armbian/issues/491) <br>
  - [晶晨Boot流程分析](https://7ji.github.io/embedded/2022/11/11/amlogic-booting.html)<br>
  - [晶晨专有EPT分区表](https://github.com/ophub/amlogic-s9xxx-armbian/issues/1173) <br>
可知, K510 变量代表内核版本是否大于5.10, 如果大于(K510=1), 则必须采用uboot重载的方式加载内核 <br>
这是社区为了应对5.10以后的主线内核强制要求新版本uboot的应对措施, 若该值为1, 如果是从usb启动, 则需要把用于overload的uboot复制成uboot.ext, 如果从eMMC启动, 则是uboot.emmc <br>
但flippy增加了一个patch, 让用在盒子上的内核即使版本高于5.10, 也能用旧uboot(厂商uboot)启动, 也就不需要上面这些应对措施了 <br>
主线内核和flippy-patch内核的不同在于内核TEXT_OFFSET字段的不同, 前者是0000, 代表需要启用uboot overload, 后者是0108, 由于patch过了, 自然不需要重载了 <br>
```shell
[[ "$(hexdump -n 15 -x "/boot/zImage" 2>/dev/null | head -n 1 | awk '{print $7}')" == "0108" ]] && echo "内核版本小于5.10, 或是Patch内核, 无需重载"
```

# 致谢
本项目基于 [ImmortalWrt-25.12](https://github.com/immortalwrt/immortalwrt/tree/openwrt-25.12) 源码编译，使用 flippy 的[脚本](https://github.com/unifreq/openwrt_packit)和 ophub 维护的[内核](https://github.com/ophub/kernel/releases/tag/kernel_stable)打包成完整固件，感谢开发者们的无私分享。<br>
flippy 固件的更多细节参考[恩山论坛帖子](https://www.right.com.cn/forum/thread-4076037-1-1.html)。 <br>

分析晶晨设备eMMC分区时, 推荐使用 [ampart工具](https://github.com/7Ji/ampart) <br>
