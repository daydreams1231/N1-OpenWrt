# 2026.02 Update
6.12系列内核(无论flippy还是ophub)疑似转发性能有问题, 旁路由模式下, N1只能跑30M左右 <br>
类似问题在OES设备(ophub固件, 6.12内核)上也出现了, 但OES能跑50M左右 <br>
6.6.y : 正常, 全有线连接, 可跑到840M - 850M <br>
6.1.y : 正常, 结果同上 <br>

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
### [luci-app-amlogic](https://github.com/ophub/luci-app-amlogic) 晶晨宝盒
用于系统更新、固件刷写、CPU 调频等 <br>
系统刷写其实就是调用 /usr/sbin/openwrt-install-amlogic, 这个脚本和 /root/install-to-emmc.sh 是完全一样的, 都会在emmc里搞4个完全没必要的分区 <br>
末尾有安装/刷写/更新教程 <br>

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

# 安装后的注意事项
在/root目录下有安装到eMMC的脚本, 不要更改其内容 <br>

## 安装后应做的事
1: 前往 `网络` -> `接口` <br>
将lan6的防火墙区域调整为lan <br>
<br>

2: 还是在 `接口` 页面 <br>
关闭lan区域的dhcp服务器, 并将IPv6 DHCP相关项全部禁用 <br>
> 并不是说旁路由和IPv6天生八字不和, 只是大部分设备自己改不了IPv6网关, 导致若DNS解析到ipv6, 一定绕过旁路由走直连

# 换源
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

# 从USB全新安装到eMMC操作 (N1盒子没有主线uboot)
### 手动删除emmc所有分区
这一步没有教程, 自行备份数据!
### 写Bootloader
在Release页面发布的固件是刷写到USB设备里面的, 并不包含uboot <br>
在emmc install脚本里, 先写了android uboot, 后再把u-boot-n1.bin命名成u-boot.emmc, 即uboot重载 (板载uboot -> 重载uboot)
真正写到emmc里的是安卓用的那个uboot: u-boot-2015-phicomm-n1.bin <br>
See [Ref](https://github.com/ophub/amlogic-s9xxx-armbian/issues/491) & [Ref2](https://7ji.github.io/embedded/2022/11/11/amlogic-booting.html)<br>
可知, K510 变量代表内核版本是否大于5.10, 如果大于(K510=1), 则必须采用uboot重载的方式加载内核
这是社区为了应对5.10以后的主线内核强制要求主线uboot的应对措施, 若该值为1, 如果是从usb启动, 则把用于overload的uboot复制成uboot.ext, 如果从eMMC启动, 则是uboot.emmc
但flippy增加了一个patch, 让用在盒子上的内核即使版本高于5.10, 也能用旧uboot(厂商uboot)启动, 也就不需要上面这些应对措施了
原版内核和flippy-patch内核的不同在于内核TEXT_OFFSET字段的不同, 前者是0000, 代表需要启用uboot overload, 后者是0108, 由于patch过了, 自然不需要重载了
```shell
[[ "$(hexdump -n 15 -x "/boot/zImage" 2>/dev/null | head -n 1 | awk '{print $7}')" == "0108" ]] && echo "内核版本小于5.10"
```
对于各个分区的位置, 不知道为什么要留blank区域， maybe env信息?
install脚本里面在每个分区的起始位置写了1M的0, 这里就不这样做了
```shell
dd if=u-boot-2015-phicomm-n1.bin  of=/dev/mmcblk2 conv=fsync,notrunc bs=1 count=444
dd if=u-boot-2015-phicomm-n1.bin  of=/dev/mmcblk2 conv=fsync,notrunc bs=512 skip=1 seek=1
# 第一个扇区 = 文件u-boot-2015-phicomm-n1.bin前面444字节 + 68字节(存储MBR分区表)
# 之后的扇区 = 从文件u-boot-2015-phicomm-n1.bin的512 byte开始的内容
```
### 在eMMC上创建新的boot分区和rootfs分区并格式化
```shell
fdisk /dev/mmcblk2

mkfs.fat -F32 /dev/mmcblk2p1
mkfs.btrfs /dev/mmcblk2p2
```
### 把USB上的boot分区和rootfs分区复制过去

### 执行blkid命令, 获取各分区的UUID (主要是eMMC设备两个分区的UUID)

### 挂载eMMC的第一个分区到/mnt下
```shell
mount /dev/mmcblk2p1 /mnt
```
### 修改rootfs fstab
修改 [eMMC]/etc/fstab, 写入两行: <br>
```
UUID=<EMMC_ROOTFS_UUID> /     btrfs compress=zstd:6 0 1
UUID=<EMMC_BOOT_UUID>   /boot vfat  defaults        0 2
```
修改 [eMMC]/etc/config/fstab <br>
```text
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
        option uuid '<EMMC_BOOT_UUID>' # 注意两端引号别掉了
        option enabled '1'
        option enabled_fsck '1'
        option fstype 'vfat'
```
### 移动部分文件
```
mv <eMMC>/etc/config/balance_irq <eMMC>/etc/balance_irq
cp /boot/zImage <eMMC>/boot/zImage 
cp /boot/uInitrd <eMMC>/boot/uInitrd
```
emmc不需要 s905 aml开头的autoscript
rm -f s905_autoscript* aml_autoscript*
复制原boot分区下的 u-boot-n1.bin 到新的boot分区中, 一共三份: u-boot-n1.bin u-boot.ext u-boot.emmc, 都是一个文件

写/boot/uEnv.txt
```
LINUX=/zImage
INITRD=/uInitrd
FDT=/dtb/amlogic/meson-gxl-s905d-phicomm-n1.dtb

APPEND=root=UUID=<EMMC_ROOTFS_UUID> rootfstype=btrfs rootflags=compress=zstd:6 console=ttyAML0,115200n8 console=tty0 no_console_suspend consoleblank=0 fsck.fix=yes fsck.repair=yes net.ifnames=0 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1
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

# 致谢
本项目基于 [ImmortalWrt-25.12](https://github.com/immortalwrt/immortalwrt/tree/openwrt-25.12) 源码编译，使用 flippy 的[脚本](https://github.com/unifreq/openwrt_packit)和 ophub 维护的[内核](https://github.com/ophub/kernel/releases/tag/kernel_stable)打包成完整固件，感谢开发者们的无私分享。<br>
flippy 固件的更多细节参考[恩山论坛帖子](https://www.right.com.cn/forum/thread-4076037-1-1.html)。
