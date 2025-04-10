# 项目简介
本固件适配斐讯 N1 旁路由模式，追求轻量（请注意：不具备 PPPoE、WiFi 相关功能）。<br>
固件包含默认皮肤、完整 IPv6 支持，以及下列 luci-app：<br>
[luci-app-amlogic](https://github.com/ophub/luci-app-amlogic)：系统更新、文件传输、CPU 调频等<br>
luci-app-dockerman：docker 管理<br>

## 可选项
luci-app-openclash: 由于openclash依赖iptables, 可能会导致 状态 -> 防火墙 页面提示 "检测到旧版规则", 酌情取用 <br>

luci-app-homeproxy<br>

luci-app-dockerman<br>
该docker管理软件包依赖于dockerd, 其又依赖于iptables而不是nftables, 会造成与上面的Openclash同样的问题<br>
如果docker bridge网络的容器无法上网，并且你同时使用了Openclash，请尝试更新luci-app-openclash，如果仍未解决，检查网络 -> 防火墙，检查docker区域是否被允许转发流量至lan区域，或者直接将接口docker0的防火墙区域设置为lan<br>

luci-app-cifs<br>
用于挂载SMB分享

luci-app-diskman<br>
用于管理磁盘 (N1就8G emmc, 应该没人用usb2口外接硬盘吧)

## To do
更改.config，删去不必要的驱动
/lib/firmware<br>
这下面的驱动貌似是在打包的过程中进来的
***
# 致谢
本项目基于 [ImmortalWrt-24.10](https://github.com/immortalwrt/immortalwrt/tree/openwrt-24.10) 源码编译，使用 flippy 的[脚本](https://github.com/unifreq/openwrt_packit)和 breakingbadboy 维护的[内核](https://github.com/breakingbadboy/OpenWrt/releases/tag/kernel_stable)打包成完整固件，感谢开发者们的无私分享。<br>
flippy 固件的更多细节参考[恩山论坛帖子](https://www.right.com.cn/forum/thread-4076037-1-1.html)。
