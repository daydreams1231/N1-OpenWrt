# 项目简介
自用固件, 适配斐讯 N1, 以极致的轻量为目标, 专注于旁路由/透明代理 + 内网穿透/异地组网 <br>
## 特点
  - 无PPPoE拨号功能
  - WLAN支持
  - 使用默认Bootstrap主题
  - 完整 IPv6 支持
  - lan区域默认为DHCP客户端模式

## 预装软件包
### [luci-app-amlogic](https://github.com/ophub/luci-app-amlogic) 晶晨宝盒
用于系统更新、固件刷写、CPU 调频等 <br>
### [luci-app-easytier](https://github.com/EasyTier/luci-app-easytier) Easytier组网工具
用于异地组网 <br>
### luci-app-openclash / luci-app-homeproxy / 手搓旁路由
前面两者占用大差不差, N1有2G内存, 对一个旁路由而言肯定是够的. 但考虑到现在sing-box已经支持clash-api了, 而mihomo却还不支持prefer ipv4的dns解析策略, 可以逐渐转向homeproxy <br>
如果都不喜欢, 可以手搓旁路由, 相较于在普通Linux上手搓, Openwrt肯定还是方便些的. <br>
> luci-app-openclash: 由于openclash依赖iptables, 可能会导致 状态 -> 防火墙 页面提示 "检测到旧版规则", 酌情取用 <br>
### luci-proto-wireguard
启用Wireguard支持
## 未安装软件包
### [luci-app-dockerman](https://github.com/lisaac/luci-app-dockerman)
原因: 我不需要 <br>
用于docker 管理, 如果docker bridge网络的容器无法上网，检查网络 -> 防火墙，检查docker区域是否被允许转发流量至上网区域(对于N1, 一般是LAN区域)，或者直接将接口docker0的防火墙区域设置为lan <br>

# 安装后的注意事项
在/root目录下有安装到eMMC的脚本, 不要更改其内容 <br>
/lib/firmware下是一堆用不到的驱动, 貌似是在打包的过程中进来的, 以后有时间再把能删的列出来 <br>

# 换源
由于是基于大版本(v25.12)的snatshot版本构建的, 换源时为了兼容性考虑不建议换用小版本(v25.12.x)的源 <br>
由于内核不是官方内核, 换源时不建议添加kmod源 <br>
当然, 如果内核版本和官方版本相差不大, 可酌情换用 <br>
```text
# kmod源酌情取用
# src/gz immortalwrt_core https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/targets/armsr/armv8/kmods/6.12.66-1-a0026a4d4ab31711433cd3614cd1ad46 

src/gz immortalwrt_core https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/targets/armsr/armv8/packages
src/gz immortalwrt_base https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/packages/aarch64_generic/base
src/gz immortalwrt_luci https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/packages/aarch64_generic/luci
src/gz immortalwrt_packages https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/packages/aarch64_generic/packages
src/gz immortalwrt_routing https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/packages/aarch64_generic/routing
src/gz immortalwrt_telephony https://mirrors.pku.edu.cn/immortalwrt/releases/25.12-SNAPSHOT/packages/aarch64_generic/telephony
```

# 致谢
本项目基于 [ImmortalWrt-25.12](https://github.com/immortalwrt/immortalwrt/tree/openwrt-25.12) 源码编译，使用 flippy 的[脚本](https://github.com/unifreq/openwrt_packit)和 ophub 维护的[内核](https://github.com/ophub/kernel/releases/tag/kernel_stable)打包成完整固件，感谢开发者们的无私分享。<br>
flippy 固件的更多细节参考[恩山论坛帖子](https://www.right.com.cn/forum/thread-4076037-1-1.html)。
