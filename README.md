# 红米AC2100 OpenWrt 定制固件项目

[![Build OpenWrt](https://github.com/YOUR_USERNAME/diy_openwrt/workflows/Build%20OpenWrt%20for%20Redmi%20AC2100/badge.svg)](https://github.com/YOUR_USERNAME/diy_openwrt/actions)
[![GitHub release](https://img.shields.io/github/release/YOUR_USERNAME/diy_openwrt.svg)](https://github.com/YOUR_USERNAME/diy_openwrt/releases)
[![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/diy_openwrt.svg?style=social)](https://github.com/YOUR_USERNAME/diy_openwrt)

## 项目概述

本项目为红米AC2100路由器提供定制化的OpenWrt固件编译方案，集成了丰富的网络功能和管理特性。

### 设备信息

| 项目 | 参数 |
|------|------|
| 设备型号 | 红米AC2100 (Redmi Router AC2100) |
| OpenWrt代码名 | xiaomi_redmi-router-ac2100 |
| CPU | MediaTek MT7621A (MIPS, 880MHz双核) |
| RAM | 128MB DDR3 |
| Flash | 128MB NAND |
| 无线 | 2.4GHz (MT7603EN) + 5GHz (MT7615N) |
| 端口 | 3x LAN + 1x WAN (千兆) |

---

## 快速开始

### 方式一：下载预编译固件

1. 前往 [Releases](../../releases) 页面
2. 下载最新版本固件
3. 按照 [刷机指南](docs/flash-guide.md) 进行刷机

### 方式二：本地编译

```bash
# 1. 克隆项目
git clone https://github.com/YOUR_USERNAME/diy_openwrt.git
cd diy_openwrt

# 2. 准备编译环境 (Ubuntu/Debian)
./scripts/setup-env.sh

# 3. 克隆OpenWrt源码
./scripts/clone-source.sh

# 4. 编译固件
./scripts/build.sh
```

### 方式三：GitHub Actions 云编译

1. Fork 本项目
2. 进入 Actions 页面
3. 点击 "Build OpenWrt for Redmi AC2100"
4. 点击 "Run workflow"
5. 等待编译完成后在 Releases 下载

---

## 固件特性

### 内置功能

| 功能模块 | 说明 |
|---------|------|
| **PassWall** | 科学上网，支持SS/SSR/V2Ray/Xray/Trojan |
| **AdGuard Home** | DNS级广告屏蔽 |
| **SmartDNS** | 智能DNS加速和分流 |
| **Aria2** | 多协议下载工具 |
| **frpc** | 内网穿透客户端 |
| **ZeroTier** | P2P虚拟组网 |
| **DDNS** | 动态域名（支持阿里云/腾讯云/Cloudflare） |
| **SQM QoS** | 智能流量控制 |
| **vnStat** | 流量统计 |
| **nlbwmon** | 带宽监控 |
| **Samba4** | 文件共享 |
| **TTYD** | 网页终端 |
| **Argon主题** | 现代化Web界面 |

### 默认配置

- **管理地址**: `192.168.31.1`
- **用户名**: `root`
- **密码**: 无（首次登录请设置）
- **WiFi名称**: `RedmiAC2100_2.4G` / `RedmiAC2100_5G`
- **WiFi密码**: `12345678`

---

## 项目结构

```
diy_openwrt/
├── .github/
│   └── workflows/
│       └── build-openwrt.yml    # GitHub Actions 工作流
├── config/
│   ├── feeds.conf               # 软件源配置
│   └── redmi-ac2100.config      # 固件配置文件
├── docs/
│   ├── flash-guide.md           # 刷机指南
│   └── usage-guide.md           # 使用指南
├── files/                       # 自定义文件（会复制到固件）
├── patches/                     # 补丁文件
├── scripts/
│   ├── setup-env.sh             # 环境准备脚本
│   ├── clone-source.sh          # 源码克隆脚本
│   ├── build.sh                 # 编译脚本
│   ├── diy-part1.sh             # DIY脚本（feeds前）
│   └── diy-part2.sh             # DIY脚本（feeds后）
├── README.md                    # 项目说明
└── packages-list.md             # 软件包清单
```

---

## 编译说明

### 系统要求

- **操作系统**: Ubuntu 20.04/22.04 LTS 或 Debian 11/12
- **磁盘空间**: 至少 50GB（建议 100GB）
- **内存**: 至少 4GB（建议 8GB）

### 本地编译步骤

```bash
# 安装编译依赖
./scripts/setup-env.sh

# 克隆源码（默认使用 Lean's LEDE）
./scripts/clone-source.sh

# 开始编译
./scripts/build.sh

# 或者自定义配置后编译
./scripts/build.sh --menuconfig
```

### 编译选项

```bash
./scripts/build.sh              # 完整编译
./scripts/build.sh --menuconfig # 打开配置菜单
./scripts/build.sh --download   # 仅下载软件包
./scripts/build.sh --compile    # 仅编译（跳过下载）
./scripts/build.sh --single     # 单线程编译（调试）
./scripts/build.sh --clean      # 清理编译文件
./scripts/build.sh --clean-all  # 完全清理
```

---

## 文档

- [刷机指南](docs/flash-guide.md) - 详细的刷机步骤和救砖方法
- [使用指南](docs/usage-guide.md) - 固件配置和功能使用说明
- [软件包清单](packages-list.md) - 完整的软件包列表

---

## 自定义配置

### 修改软件包

编辑 `config/redmi-ac2100.config` 文件，或使用：

```bash
./scripts/build.sh --menuconfig
```

### 添加自定义文件

将文件放入 `files/` 目录，编译时会自动复制到固件对应位置。

例如：
- `files/etc/config/` - 配置文件
- `files/etc/uci-defaults/` - 初始化脚本

### 修改默认设置

编辑 `scripts/diy-part2.sh` 文件，可修改：
- 默认IP地址
- 默认主机名
- 默认时区
- WiFi名称和密码
- 等等...

---

## 常见问题

### Q: 编译失败怎么办？

A:
1. 使用单线程编译查看详细错误: `./scripts/build.sh --single`
2. 清理后重新编译: `./scripts/build.sh --clean && ./scripts/build.sh`
3. 检查磁盘空间和网络连接

### Q: 如何减小固件体积？

A:
1. 编辑 `.config` 移除不需要的软件包
2. 只选择一个科学上网方案
3. 移除大型软件包如 Netdata、Docker

### Q: WiFi信号弱？

A:
1. 检查无线设置中的发射功率
2. 确认 Factory 分区数据完整
3. 尝试更换信道

更多问题请查看 [使用指南](docs/usage-guide.md) 或提交 [Issue](../../issues)。

---

## 致谢

- [OpenWrt](https://openwrt.org/) - 开源路由器操作系统
- [Lean's LEDE](https://github.com/coolsnowwolf/lede) - LEDE 源码
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) - GitHub Actions 编译方案
- [PassWall](https://github.com/xiaorouji/openwrt-passwall) - 科学上网插件
- [luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon) - Argon 主题

---

## 许可证

本项目基于 [MIT License](LICENSE) 开源。

---

## 免责声明

- 刷机有风险，请自行承担责任
- 本固件仅供学习交流使用
- 请遵守当地法律法规

---

**Star** 本项目支持一下 :star:
