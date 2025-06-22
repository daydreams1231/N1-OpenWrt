# 项目简介
自用固件, 仅适配斐讯 N1, 追求极致轻量, 用于OpenClash旁路由 + 组网VPN <br>
不具备 PPPoE、WiFi 相关功能 <br>
固件为默认皮肤、带完整 IPv6 支持

# 预装软件包
## [luci-app-amlogic](https://github.com/ophub/luci-app-amlogic)
用于系统更新、文件传输、CPU 调频等<br>
## [luci-app-dockerman](https://github.com/lisaac/luci-app-dockerman)
docker 管理, 如果docker bridge网络的容器无法上网，检查网络 -> 防火墙，检查docker区域是否被允许转发流量至上网区域(对于N1, 一般是LAN区域)，或者直接将接口docker0的防火墙区域设置为lan <br>
## luci-app-openclash / luci-app-homeproxy
自己改`N1/.config`来选择你想要的
> luci-app-openclash: 由于openclash依赖iptables, 可能会导致 状态 -> 防火墙 页面提示 "检测到旧版规则", 酌情取用 <br>
## luci-proto-wireguard

# 安装后的注意事项
在/root目录下有安装到EMMC的脚本, 不要更改其内容 <br>
/lib/firmware下是一堆用不到的驱动, 貌似是在打包的过程中进来的, 以后有时间再把能删的列出来 <br>
由于内核不是官方内核, 换源时不建议添加kmod源, 如有需要直接在`N1/.config`里加就行
# 换源
```shell
src/gz immortalwrt_core https://mirrors.ustc.edu.cn/immortalwrt/releases/24.10.1/targets/armsr/armv8/packages
src/gz immortalwrt_base https://mirrors.ustc.edu.cn/immortalwrt/releases/24.10.1/packages/aarch64_generic/base
src/gz immortalwrt_luci https://mirrors.ustc.edu.cn/immortalwrt/releases/24.10.1/packages/aarch64_generic/luci
src/gz immortalwrt_packages https://mirrors.ustc.edu.cn/immortalwrt/releases/24.10.1/packages/aarch64_generic/packages
src/gz immortalwrt_routing https://mirrors.ustc.edu.cn/immortalwrt/releases/24.10.1/packages/aarch64_generic/routing
src/gz immortalwrt_telephony https://mirrors.ustc.edu.cn/immortalwrt/releases/24.10.1/packages/aarch64_generic/telephony
```
***
# 致谢
本项目基于 [ImmortalWrt-24.10](https://github.com/immortalwrt/immortalwrt/tree/openwrt-24.10) 源码编译，使用 flippy 的[脚本](https://github.com/unifreq/openwrt_packit)和 breakingbadboy 维护的[内核](https://github.com/breakingbadboy/OpenWrt/releases/tag/kernel_stable)打包成完整固件，感谢开发者们的无私分享。<br>
flippy 固件的更多细节参考[恩山论坛帖子](https://www.right.com.cn/forum/thread-4076037-1-1.html)。
