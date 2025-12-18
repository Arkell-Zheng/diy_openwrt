# 红米AC2100 OpenWrt 刷机指南

## 目录
1. [准备工作](#准备工作)
2. [获取SSH权限](#获取ssh权限)
3. [备份原厂固件](#备份原厂固件)
4. [刷入Breed](#刷入breed)
5. [刷入OpenWrt](#刷入openwrt)
6. [首次配置](#首次配置)
7. [常见问题](#常见问题)
8. [救砖方法](#救砖方法)

---

## 准备工作

### 所需工具
- 红米AC2100路由器一台
- 网线一根
- 电脑一台（Windows/Mac/Linux均可）
- 下载好的固件文件

### 所需文件
1. **breed-mt7621-xiaomi-r3g.bin** - Breed bootloader
2. **openwrt-ramips-mt7621-xiaomi_redmi-router-ac2100-squashfs-sysupgrade.bin** - OpenWrt固件

### 下载地址
- Breed: [https://breed.hackpascal.net/](https://breed.hackpascal.net/)
- OpenWrt固件: 本项目 Releases 页面

---

## 获取SSH权限

红米AC2100需要先开启SSH才能刷入第三方固件。

### 方法一：利用漏洞开启（推荐）

1. **连接路由器**
   - 将电脑通过网线连接到路由器LAN口
   - 或连接路由器的WiFi

2. **登录管理页面**
   - 浏览器访问 `192.168.31.1`
   - 完成初始化设置（如果是新路由器）

3. **获取STOK值**
   - 登录后，查看浏览器地址栏
   - 复制 `stok=` 后面的值（一串字母数字）
   - 例如: `stok=abcd1234efgh5678`

4. **执行漏洞命令**

   在浏览器地址栏依次访问以下URL（替换YOUR_STOK为你的stok值）：

   **步骤1：开启Telnet**
   ```
   http://192.168.31.1/cgi-bin/luci/;stok=YOUR_STOK/api/misystem/set_config_iotdev?bssid=Xiaomi&user_id=longdike&ssid=%0telenad_en%3D1%0telenad_port%3D23%0
   ```

   **步骤2：设置密码**
   ```
   http://192.168.31.1/cgi-bin/luci/;stok=YOUR_STOK/api/misystem/set_config_iotdev?bssid=Xiaomi&user_id=longdike&ssid=%0telenad_en%3D1%0telenad_passwd%3Dadmin%0
   ```

5. **连接Telnet**
   ```bash
   telnet 192.168.31.1
   ```
   - 用户名: `root`
   - 密码: `admin`

6. **开启SSH**
   ```bash
   sed -i 's/channel=.*/channel="debug"/g' /etc/init.d/dropbear
   /etc/init.d/dropbear restart
   ```

7. **测试SSH连接**
   ```bash
   ssh root@192.168.31.1
   ```
   密码: `admin`

### 方法二：降级后利用漏洞

如果方法一不成功，可能需要先将固件降级到有漏洞的版本。

1. 下载 `miwifi_rm2100_firmware_d6234_2.0.7.bin`
2. 在路由器管理页面手动升级到此版本
3. 重新执行方法一

---

## 备份原厂固件

**强烈建议在刷机前备份原厂固件！**

### 通过SSH备份

1. **连接SSH**
   ```bash
   ssh root@192.168.31.1
   ```

2. **查看分区布局**
   ```bash
   cat /proc/mtd
   ```

   输出类似：
   ```
   dev:    size   erasesize  name
   mtd0: 07f80000 00020000 "ALL"
   mtd1: 00080000 00020000 "Bootloader"
   mtd2: 00040000 00020000 "Config"
   mtd3: 00040000 00020000 "Bdata"
   mtd4: 00040000 00020000 "Factory"
   mtd5: 00040000 00020000 "crash"
   mtd6: 00040000 00020000 "crash_syslog"
   mtd7: 00080000 00020000 "cfg_bak"
   mtd8: 00400000 00020000 "kernel0"
   mtd9: 00400000 00020000 "kernel1"
   mtd10: 02000000 00020000 "rootfs0"
   mtd11: 02000000 00020000 "rootfs1"
   mtd12: 01580000 00020000 "overlay"
   ```

3. **备份关键分区**
   ```bash
   # 备份 Bootloader
   dd if=/dev/mtd1 of=/tmp/Bootloader.bin

   # 备份 Factory (包含MAC地址和无线校准数据)
   dd if=/dev/mtd4 of=/tmp/Factory.bin

   # 备份 Bdata
   dd if=/dev/mtd3 of=/tmp/Bdata.bin

   # 备份完整固件（可选，文件较大）
   dd if=/dev/mtd0 of=/tmp/ALL.bin
   ```

4. **下载备份文件到电脑**
   ```bash
   scp root@192.168.31.1:/tmp/*.bin ./backup/
   ```

5. **妥善保管备份文件**
   - 多处备份，防止丢失
   - 特别是 Factory.bin，包含无线校准数据

---

## 刷入Breed

Breed是一个功能强大的bootloader，可以方便地刷入各种固件。

### 上传Breed

1. **上传文件到路由器**
   ```bash
   scp breed-mt7621-xiaomi-r3g.bin root@192.168.31.1:/tmp/
   ```

2. **SSH连接路由器**
   ```bash
   ssh root@192.168.31.1
   ```

3. **刷入Breed**
   ```bash
   mtd -r write /tmp/breed-mt7621-xiaomi-r3g.bin Bootloader
   ```

4. **等待重启**
   - 路由器会自动重启
   - 等待约30秒

### 进入Breed

1. **断电**
   - 拔掉路由器电源

2. **按住Reset按钮**
   - 用牙签或针按住路由器背面的Reset按钮
   - 保持不放

3. **插电**
   - 保持按住Reset的同时插上电源
   - 等待约5-10秒，看到指示灯闪烁

4. **松开Reset**

5. **访问Breed**
   - 电脑设置固定IP: `192.168.1.2`
   - 子网掩码: `255.255.255.0`
   - 浏览器访问: `192.168.1.1`

---

## 刷入OpenWrt

### 通过Breed刷入

1. **进入Breed Web界面**
   - 浏览器访问 `192.168.1.1`

2. **备份编程器固件（可选）**
   - 点击"固件备份"
   - 选择"EEPROM"，下载保存

3. **刷入固件**
   - 点击"固件更新"
   - 选择"固件"
   - 点击"选择文件"，选择OpenWrt的 `.bin` 文件
   - 点击"上传"

4. **等待完成**
   - 等待上传和刷写完成
   - 路由器会自动重启
   - 整个过程约2-3分钟

5. **恢复电脑网络设置**
   - 将电脑改回自动获取IP

### 通过SSH刷入（已有OpenWrt）

如果路由器已经运行OpenWrt，可以通过sysupgrade升级：

```bash
# 上传固件
scp openwrt-*-sysupgrade.bin root@192.168.31.1:/tmp/

# SSH连接
ssh root@192.168.31.1

# 执行升级
sysupgrade -v /tmp/openwrt-*-sysupgrade.bin
```

---

## 首次配置

### 访问管理界面

1. **连接路由器**
   - 通过网线连接LAN口
   - 或连接WiFi: `RedmiAC2100_2.4G` 或 `RedmiAC2100_5G`
   - 默认WiFi密码: `12345678`

2. **访问LuCI**
   - 浏览器访问: `192.168.31.1`
   - 默认用户名: `root`
   - 默认密码: 无（直接登录）

### 必做配置

1. **设置密码**
   - 系统 → 管理权 → 设置 root 密码

2. **修改WiFi密码**
   - 网络 → 无线 → 编辑
   - 修改SSID和密码

3. **配置上网**
   - 网络 → 接口 → WAN
   - 根据你的网络类型配置（PPPoE/DHCP/静态IP）

### 可选配置

1. **更新软件包**
   ```bash
   opkg update
   ```

2. **安装额外软件包**
   ```bash
   opkg install <package-name>
   ```

3. **配置科学上网**
   - 服务 → PassWall
   - 添加节点，配置规则

4. **配置AdGuard Home**
   - 服务 → AdGuard Home
   - 启用并配置过滤规则

---

## 常见问题

### Q: 刷机后无法访问192.168.31.1？

A:
1. 确认电脑IP设置正确
2. 尝试清除浏览器缓存
3. 检查网线连接是否正常
4. 进入Breed重新刷固件

### Q: WiFi信号弱/不稳定？

A:
1. 检查无线设置中的发射功率
2. 尝试更换WiFi信道
3. 确认Factory分区数据正确（无线校准）

### Q: 某些软件包无法安装？

A:
1. 先执行 `opkg update`
2. 检查存储空间 `df -h`
3. 考虑使用USB扩展存储

### Q: 忘记密码？

A:
1. 进入Breed，重新刷入固件
2. 或者通过串口连接重置

---

## 救砖方法

如果路由器变砖（无法正常启动），可以尝试以下方法：

### 方法一：通过Breed恢复

如果已经刷入Breed：
1. 按住Reset按钮上电
2. 进入Breed Web界面
3. 重新刷入固件

### 方法二：通过TTL线刷机

如果Breed也损坏：

1. **准备工具**
   - USB转TTL线（3.3V电平）
   - 十字螺丝刀

2. **拆机并连接TTL**
   - 拆开路由器外壳
   - 找到TTL焊点（GND, TX, RX）
   - 连接USB转TTL线
   - TX接RX，RX接TX，GND接GND

3. **设置串口终端**
   - 波特率: 115200
   - 数据位: 8
   - 停止位: 1
   - 无校验

4. **进入Uboot**
   - 上电时按数字键进入菜单
   - 选择TFTP刷机

5. **通过TFTP恢复**
   - 电脑设置IP: 192.168.1.2
   - 启动TFTP服务器
   - 放入固件文件
   - 执行恢复

---

## 固件下载

最新固件请在本项目的 [Releases](../../releases) 页面下载。

## 问题反馈

如遇到问题，请在 [Issues](../../issues) 页面提交。

---

**免责声明**: 刷机有风险，请自行承担责任。建议在刷机前充分了解相关知识并做好备份。
