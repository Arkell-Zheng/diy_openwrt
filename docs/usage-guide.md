# OpenWrt 使用指南

## 目录
1. [登录管理](#登录管理)
2. [基础配置](#基础配置)
3. [科学上网配置](#科学上网配置)
4. [广告屏蔽配置](#广告屏蔽配置)
5. [内网穿透配置](#内网穿透配置)
6. [USB存储配置](#usb存储配置)
7. [系统维护](#系统维护)
8. [性能优化](#性能优化)

---

## 登录管理

### Web管理界面

1. **访问地址**: `http://192.168.31.1`
2. **用户名**: `root`
3. **密码**: 首次登录无密码，请立即设置

### SSH登录

```bash
ssh root@192.168.31.1
```

### 网页终端 (TTYD)

- 访问: `http://192.168.31.1/cgi-bin/luci/admin/system/ttyd`

---

## 基础配置

### 修改管理密码

**路径**: 系统 → 管理权

1. 输入新密码
2. 确认密码
3. 点击"保存"

### 配置网络接口

**路径**: 网络 → 接口

#### PPPoE拨号
1. 编辑 WAN 接口
2. 协议选择 "PPPoE"
3. 输入宽带账号和密码
4. 保存并应用

#### DHCP客户端
1. 编辑 WAN 接口
2. 协议选择 "DHCP客户端"
3. 保存并应用

#### 静态IP
1. 编辑 WAN 接口
2. 协议选择 "静态地址"
3. 配置IP、网关、DNS
4. 保存并应用

### 配置无线网络

**路径**: 网络 → 无线

1. 点击对应频段的"编辑"
2. **基本设置**:
   - ESSID: 设置WiFi名称
   - 信道: 选择合适信道（自动或手动）
   - 频宽: 2.4G建议40MHz，5G建议80MHz
3. **无线安全**:
   - 加密: WPA2-PSK
   - 密码: 设置WiFi密码
4. 保存并应用

### 配置DDNS

**路径**: 服务 → 动态DNS

1. 点击"添加"
2. 选择DDNS服务商
3. 填写域名和API密钥
4. 启用并保存

---

## 科学上网配置

### PassWall 配置

**路径**: 服务 → PassWall

#### 添加节点

1. 点击"节点列表"
2. 点击"添加"
3. 选择协议类型（如 Xray/V2Ray）
4. 填写服务器信息:
   - 地址
   - 端口
   - UUID/密码
   - 传输协议
   - 其他设置
5. 保存

#### 导入订阅

1. 点击"订阅管理"
2. 添加订阅链接
3. 点击"更新订阅"

#### 配置分流规则

1. 点击"基本设置"
2. 启用主开关
3. 选择TCP/UDP节点
4. 配置分流模式:
   - GFW模式: 仅代理被墙网站
   - 全局模式: 所有流量走代理
   - 直连模式: 不使用代理
5. 保存并应用

#### DNS设置

1. 点击"DNS设置"
2. 建议配置:
   - 远程DNS: 8.8.8.8 或 1.1.1.1
   - 使用TCP查询
   - 启用DNS缓存

### SSR Plus+ 配置（替代方案）

**路径**: 服务 → ShadowSocksR Plus+

配置方法与PassWall类似，根据界面提示操作即可。

---

## 广告屏蔽配置

### AdGuard Home 配置

**路径**: 服务 → AdGuard Home

#### 首次设置

1. 启用 AdGuard Home
2. 访问 `http://192.168.31.1:3000` 完成初始化
3. 设置管理员账号密码

#### 配置过滤规则

1. 进入 AdGuard Home 管理界面
2. 点击"过滤器" → "DNS黑名单"
3. 添加过滤规则:
   ```
   # 推荐规则列表
   https://anti-ad.net/easylist.txt
   https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-easylist.txt
   ```

#### 配置上游DNS

1. 点击"设置" → "DNS设置"
2. 配置上游DNS:
   ```
   # 国内DNS
   119.29.29.29
   223.5.5.5

   # 国外DNS (如果有代理)
   tls://8.8.8.8
   tls://1.1.1.1
   ```

#### 与PassWall配合

1. 在PassWall的DNS设置中
2. 将本地DNS设为 `127.0.0.1#5335`（AdGuard Home端口）
3. 或在AdGuard Home中配置DNS分流

---

## 内网穿透配置

### frpc 配置

**路径**: 服务 → frp客户端

#### 配置连接

1. 启用frpc
2. 配置服务器:
   - 服务器地址: 你的frps服务器IP
   - 服务器端口: 7000（默认）
   - Token: 认证密码

#### 添加隧道

1. 点击"添加"
2. 配置隧道:
   - 类型: tcp/udp/http/https
   - 本地IP: 127.0.0.1
   - 本地端口: 如80
   - 远程端口: 如8080

### ZeroTier 配置

**路径**: VPN → ZeroTier

1. 启用ZeroTier
2. 填写Network ID
3. 保存并应用
4. 在ZeroTier管理后台授权设备

---

## USB存储配置

### 自动挂载

**路径**: 系统 → 挂载点

1. 插入USB存储设备
2. 刷新页面查看设备
3. 点击"挂载点"配置:
   - 已启用: 勾选
   - 挂载点: `/mnt/usb`
4. 保存并应用

### Samba文件共享

**路径**: 服务 → 网络共享

1. 启用服务
2. 配置共享目录:
   - 名称: 如 `share`
   - 路径: `/mnt/usb`
   - 允许用户: 设置权限
3. 保存并应用

Windows访问: `\\192.168.31.1\share`

### USB扩展Overlay

用USB存储扩展系统空间：

```bash
# 安装必要工具
opkg update
opkg install block-mount kmod-fs-ext4 e2fsprogs

# 查看USB设备
block info

# 格式化USB（会清除数据！）
mkfs.ext4 /dev/sda1

# 复制当前overlay数据
mkdir -p /mnt/usb
mount /dev/sda1 /mnt/usb
cp -a /overlay/* /mnt/usb/

# 配置挂载点
block detect > /etc/config/fstab
# 编辑 /etc/config/fstab，将USB设备挂载到 /overlay

# 重启
reboot
```

---

## 系统维护

### 软件包管理

```bash
# 更新软件源
opkg update

# 搜索软件包
opkg list | grep <name>

# 安装软件包
opkg install <package>

# 卸载软件包
opkg remove <package>

# 查看已安装
opkg list-installed
```

### 备份与恢复

**路径**: 系统 → 备份/升级

1. **生成备份**:
   - 点击"生成备份"
   - 下载 .tar.gz 文件

2. **恢复备份**:
   - 选择备份文件
   - 点击"恢复备份"

3. **保留配置升级**:
   - 上传新固件
   - 勾选"保留配置"
   - 点击"继续"

### 查看日志

**路径**: 状态 → 系统日志

或通过SSH：
```bash
# 系统日志
logread

# 内核日志
dmesg
```

### 定时重启

**路径**: 系统 → 计划任务

添加定时任务：
```bash
# 每天凌晨4点重启
0 4 * * * /sbin/reboot
```

---

## 性能优化

### 网络优化

1. **启用BBR**
   ```bash
   echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
   echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
   sysctl -p
   ```

2. **启用SQM QoS**
   - 路径: 网络 → SQM QoS
   - 配置上下行带宽（建议设为实际带宽的85-90%）
   - 选择队列算法: cake

3. **优化DNS**
   - 使用SmartDNS分流
   - 国内DNS: 119.29.29.29
   - 国外DNS: 配合代理

### 无线优化

1. **选择合适信道**
   - 使用WiFi分析工具查看周围信道占用
   - 选择干扰少的信道

2. **调整发射功率**
   - 路径: 网络 → 无线 → 高级设置
   - 根据实际情况调整

3. **5G优先**
   - 如果设备支持，优先使用5G频段

### 内存优化

```bash
# 查看内存使用
free -m

# 清理缓存
echo 3 > /proc/sys/vm/drop_caches

# 定时清理（添加到计划任务）
0 */4 * * * echo 3 > /proc/sys/vm/drop_caches
```

### 关闭不需要的服务

```bash
# 查看运行的服务
/etc/init.d/

# 禁用不需要的服务
/etc/init.d/<service> disable
/etc/init.d/<service> stop
```

---

## 常用命令

```bash
# 重启网络
/etc/init.d/network restart

# 重启无线
wifi down && wifi up

# 重启防火墙
/etc/init.d/firewall restart

# 查看连接设备
cat /proc/net/arp

# 查看端口占用
netstat -tlnp

# 查看CPU使用
top

# 查看存储空间
df -h

# 查看系统信息
cat /etc/openwrt_release
```

---

## 更多帮助

- [OpenWrt官方文档](https://openwrt.org/docs/start)
- [OpenWrt论坛](https://forum.openwrt.org/)
- [恩山无线论坛](https://www.right.com.cn/forum/)
- 本项目Issues页面
