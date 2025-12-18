# OpenWrt 软件包配置清单

## 红米AC2100 定制固件软件包列表

本文档列出了编译时需要选择的所有软件包，按功能模块分类。

---

## 一、基础系统组件

### 必选基础包
```
# 基础系统
base-files
busybox
dnsmasq
dropbear
firewall
fstools
libc
libgcc
logd
mtd
netifd
opkg
uci
uclient-fetch

# 内核模块
kmod-gpio-button-hotplug
kmod-leds-gpio
kmod-mt76x2
kmod-mt7603
kmod-mt7615e
kmod-mt7615-firmware

# 网络基础
kmod-nf-nathelper
kmod-ipt-raw
kmod-ipt-offload
kmod-tcp-bbr
```

### LuCI Web界面
```
luci
luci-ssl
luci-base
luci-mod-admin-full
luci-mod-network
luci-mod-status
luci-mod-system
```

### 中文支持
```
luci-i18n-base-zh-cn
luci-i18n-firewall-zh-cn
luci-i18n-opkg-zh-cn
default-settings-chn
```

---

## 二、主题与界面

### Argon主题（推荐）
```
luci-theme-argon
luci-app-argon-config
luci-i18n-argon-config-zh-cn
```

---

## 三、核心功能软件包

### 1. 科学上网（三选一或组合）

#### 方案A: PassWall（推荐，功能全面）
```
luci-app-passwall
luci-i18n-passwall-zh-cn
# 核心依赖
brook
chinadns-ng
dns2socks
dns2tcp
hysteria
ipt2socks
microsocks
naiveproxy
pdnsd-alt
shadowsocks-libev-ss-local
shadowsocks-libev-ss-redir
shadowsocks-rust-sslocal
shadowsocksr-libev-ssr-local
shadowsocksr-libev-ssr-redir
simple-obfs
tcping
trojan-plus
v2ray-core
v2ray-plugin
xray-core
```

#### 方案B: SSR Plus+（轻量级）
```
luci-app-ssr-plus
luci-i18n-ssr-plus-zh-cn
shadowsocks-libev-ss-local
shadowsocks-libev-ss-redir
shadowsocksr-libev-ssr-local
shadowsocksr-libev-ssr-redir
v2ray-core
v2ray-plugin
xray-core
simple-obfs
trojan
dns2socks
pdnsd-alt
```

#### 方案C: OpenClash（功能强大，占用较多）
```
luci-app-openclash
# 核心文件需要手动下载
```

### 2. 广告屏蔽

#### AdGuard Home（推荐）
```
luci-app-adguardhome
luci-i18n-adguardhome-zh-cn
adguardhome
```

#### 备选：AdBlock Plus
```
luci-app-adblock
luci-i18n-adblock-zh-cn
adblock
```

### 3. 内网穿透

#### frp客户端
```
luci-app-frpc
luci-i18n-frpc-zh-cn
frpc
```

#### ZeroTier组网
```
luci-app-zerotier
luci-i18n-zerotier-zh-cn
zerotier
```

#### Tailscale（可选）
```
tailscale
tailscaled
```

### 4. 下载工具

#### Aria2
```
luci-app-aria2
luci-i18n-aria2-zh-cn
aria2
ariang
webui-aria2
```

#### Transmission（可选）
```
luci-app-transmission
luci-i18n-transmission-zh-cn
transmission-daemon
transmission-web
```

---

## 四、网络管理功能

### 5. QoS流量控制
```
luci-app-sqm
luci-i18n-sqm-zh-cn
sqm-scripts
sqm-scripts-extra
```

### 6. 访客网络
```
luci-app-guest-wifi
luci-i18n-guest-wifi-zh-cn
```

### 7. 家长控制
```
luci-app-accesscontrol
luci-app-parentalcontrol
```

### 8. DDNS动态域名
```
luci-app-ddns
luci-i18n-ddns-zh-cn
ddns-scripts
ddns-scripts-cloudflare
ddns-scripts-aliyun
ddns-scripts-dnspod
curl
wget-ssl
```

---

## 五、统计监控功能

### 9. 流量统计

#### vnStat（历史统计）
```
luci-app-vnstat
luci-i18n-vnstat-zh-cn
vnstat
vnstati
```

#### nlbwmon（实时统计）
```
luci-app-nlbwmon
luci-i18n-nlbwmon-zh-cn
nlbwmon
```

#### wrtbwmon（按设备统计）
```
luci-app-wrtbwmon
wrtbwmon
```

### 10. 系统监控图表
```
luci-app-statistics
luci-i18n-statistics-zh-cn
collectd
collectd-mod-cpu
collectd-mod-interface
collectd-mod-iwinfo
collectd-mod-load
collectd-mod-memory
collectd-mod-network
collectd-mod-rrdtool
rrdtool
```

### 11. 实时性能监控（可选，占用资源较多）
```
netdata
```

---

## 六、高级网络工具

### 12. 抓包与网络诊断
```
tcpdump
netcat
nmap
iperf3
mtr
ethtool
```

### 13. 视频下载工具
```
# Python3环境
python3
python3-pip
python3-setuptools

# yt-dlp
yt-dlp

# you-get（可选）
you-get

# ffmpeg（视频处理）
ffmpeg
```

### 14. 智能DNS

#### SmartDNS
```
luci-app-smartdns
luci-i18n-smartdns-zh-cn
smartdns
```

#### MosDNS（可选）
```
luci-app-mosdns
mosdns
```

### 15. 网络测速
```
speedtest-netperf
iperf3
```

---

## 七、USB扩展功能

### 16. USB存储支持
```
# USB核心驱动
kmod-usb-core
kmod-usb2
kmod-usb3
kmod-usb-storage
kmod-usb-storage-extras
kmod-usb-storage-uas

# 文件系统支持
kmod-fs-ext4
kmod-fs-exfat
kmod-fs-ntfs
kmod-fs-vfat
ntfs-3g
exfat-mkfs

# 自动挂载
block-mount
blockd
```

### 17. 文件共享

#### Samba（Windows共享）
```
luci-app-samba4
luci-i18n-samba4-zh-cn
samba4-server
samba4-client
```

#### NFS（可选）
```
nfs-kernel-server
nfs-kernel-server-utils
```

### 18. 打印服务器
```
luci-app-p910nd
luci-i18n-p910nd-zh-cn
p910nd
```

---

## 八、系统工具

### 19. 网页终端
```
luci-app-ttyd
luci-i18n-ttyd-zh-cn
ttyd
```

### 20. UPnP
```
luci-app-upnp
luci-i18n-upnp-zh-cn
miniupnpd
```

### 21. IPv6支持
```
ipv6helper
odhcp6c
odhcpd-ipv6only
6in4
6rd
6to4
```

### 22. 防火墙增强
```
iptables-mod-extra
iptables-mod-conntrack-extra
iptables-mod-ipopt
```

### 23. 其他实用工具
```
# 编辑器
nano
vim-full

# 网络工具
curl
wget-ssl
openssh-sftp-server

# 系统工具
htop
screen
tmux
rsync

# 压缩工具
unzip
gzip
bzip2
```

---

## 九、可选高级功能

### 24. Docker支持（需要USB扩展存储）
```
luci-app-dockerman
docker
dockerd
docker-compose
```

### 25. KMS激活服务器（可选）
```
luci-app-vlmcsd
vlmcsd
```

### 26. 网络唤醒
```
luci-app-wol
luci-i18n-wol-zh-cn
etherwake
```

### 27. 定时重启
```
luci-app-autoreboot
```

### 28. 文件浏览器
```
luci-app-filebrowser
filebrowser
```

---

## 软件包选择建议

### 精简版配置（推荐）
**Flash占用**: 约60-80MB

**必选模块**:
- 基础系统 + LuCI界面 + Argon主题
- PassWall 或 SSR Plus+（二选一）
- AdGuard Home
- Aria2
- DDNS
- vnStat + nlbwmon
- USB存储 + Samba
- 基础工具（tcpdump, yt-dlp）

**可选模块**（后期通过opkg安装）:
- frp / ZeroTier
- SmartDNS
- 系统监控图表
- 高级网络工具

### 完整版配置
**Flash占用**: 约100-120MB

**包含**: 上述所有软件包（除Docker外）

**风险**: Flash空间紧张，升级受限

### 最小化配置
**Flash占用**: 约40-50MB

**包含**: 仅基础系统 + LuCI + 主题

**策略**: 全部功能通过USB扩展存储 + opkg后期安装

---

## 第三方软件源

某些软件包可能不在官方源中，需要添加第三方源：

### Lean's OpenWrt源（推荐）
```bash
# 包含PassWall、SSR Plus+、AdGuard Home等
src/gz lede https://op.supes.top/packages/aarch64_cortex-a53
```

### Kenzo OpenWrt源
```bash
# 包含OpenClash等
src/gz kenzo https://op.dllkids.xyz/packages/aarch64_cortex-a53
```

**注意**: 添加第三方源前请确认安全性和兼容性

---

## 依赖关系说明

### 科学上网依赖链
```
PassWall/SSR Plus+
  ├─ xray-core / v2ray-core (核心)
  ├─ shadowsocks-libev (SS支持)
  ├─ shadowsocksr-libev (SSR支持)
  ├─ trojan-plus (Trojan支持)
  ├─ chinadns-ng (DNS分流)
  ├─ dns2socks (DNS代理)
  └─ ipset / dnsmasq-full (规则匹配)
```

### 视频下载依赖链
```
yt-dlp
  ├─ python3 (运行环境)
  ├─ python3-pip (包管理)
  ├─ ffmpeg (视频处理)
  └─ ca-certificates (SSL证书)
```

### USB共享依赖链
```
Samba4
  ├─ kmod-usb-storage (USB驱动)
  ├─ kmod-fs-ntfs/exfat (文件系统)
  ├─ block-mount (自动挂载)
  └─ samba4-server (服务端)
```

---

## 空间优化建议

### 减小固件体积
1. 只选择一个科学上网方案
2. 移除不需要的无线驱动
3. 使用dnsmasq替代dnsmasq-full
4. 移除多余的语言包
5. 不安装Netdata等大型监控工具

### 运行时优化
1. 使用USB存储扩展overlay
2. 定期清理日志文件
3. 使用opkg按需安装
4. 禁用不常用的服务

---

## 下一步

查看 `build-guide.md` 了解如何：
1. 准备编译环境
2. 配置和选择这些软件包
3. 编译固件
4. 刷机和测试

---

**更新日期**: 2025-12-18
