#!/bin/bash
#===============================================================================
# DIY 定制脚本 Part 2 - Feeds 更新后执行
# 设备目标: 红米AC2100 (xiaomi_redmi-router-ac2100)
#===============================================================================

# 此脚本在 feeds 更新和安装之后执行
# 用于修改软件包、定制系统默认设置等

set -e

echo "=========================================="
echo " DIY Part 2 - Feeds 更新后定制"
echo "=========================================="

# 获取 OpenWrt 源码目录
OPENWRT_DIR="${OPENWRT_DIR:-$(pwd)}"
cd "$OPENWRT_DIR"

echo "[INFO] 当前目录: $(pwd)"

#===============================================================================
# 修改默认 IP 地址
#===============================================================================
DEFAULT_IP="192.168.31.1"

if [ -f "package/base-files/files/bin/config_generate" ]; then
    sed -i "s/192.168.1.1/${DEFAULT_IP}/g" package/base-files/files/bin/config_generate
    echo "[INFO] 默认 IP 已修改为: ${DEFAULT_IP}"
fi

#===============================================================================
# 修改默认主机名
#===============================================================================
DEFAULT_HOSTNAME="RedmiAC2100"

if [ -f "package/base-files/files/bin/config_generate" ]; then
    sed -i "s/OpenWrt/${DEFAULT_HOSTNAME}/g" package/base-files/files/bin/config_generate
    echo "[INFO] 默认主机名已修改为: ${DEFAULT_HOSTNAME}"
fi

#===============================================================================
# 修改默认时区为上海
#===============================================================================
if [ -f "package/base-files/files/bin/config_generate" ]; then
    sed -i "s/timezone='UTC'/timezone='CST-8'/g" package/base-files/files/bin/config_generate
    sed -i "/timezone/a\\                set system.@system[-1].zonename='Asia/Shanghai'" package/base-files/files/bin/config_generate 2>/dev/null || true
    echo "[INFO] 默认时区已修改为: Asia/Shanghai"
fi

#===============================================================================
# 修改 LuCI 默认语言为中文
#===============================================================================
if [ -f "feeds/luci/modules/luci-base/root/etc/config/luci" ]; then
    sed -i "s/option lang auto/option lang zh_cn/g" feeds/luci/modules/luci-base/root/etc/config/luci
    echo "[INFO] LuCI 默认语言已修改为: 中文"
fi

#===============================================================================
# 修改默认主题为 Argon
#===============================================================================
if [ -f "feeds/luci/collections/luci/Makefile" ]; then
    sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
    echo "[INFO] 默认主题已修改为: Argon"
fi

#===============================================================================
# 修改固件版本信息
#===============================================================================
BUILD_DATE=$(date +"%Y.%m.%d")
VERSION_INFO="R${BUILD_DATE} by DIY-OpenWrt"

# 修改版本号显示
if [ -f "package/lean/default-settings/files/zzz-default-settings" ]; then
    sed -i "s/DISTRIB_REVISION='.*'/DISTRIB_REVISION='${VERSION_INFO}'/g" package/lean/default-settings/files/zzz-default-settings
    echo "[INFO] 固件版本信息已修改: ${VERSION_INFO}"
elif [ -f "package/base-files/files/etc/openwrt_release" ]; then
    # 如果是官方源
    sed -i "s/DISTRIB_REVISION='.*'/DISTRIB_REVISION='${VERSION_INFO}'/g" package/base-files/files/etc/openwrt_release
fi

#===============================================================================
# 移除不需要的软件包 (节省空间)
#===============================================================================
# 移除一些 LEDE 默认但我们不需要的软件包

# 移除网易云音乐解锁 (不需要)
# rm -rf feeds/luci/applications/luci-app-unblockmusic 2>/dev/null || true
# rm -rf feeds/packages/multimedia/UnblockNeteaseMusic 2>/dev/null || true

# 移除京东签到 (不需要)
# rm -rf feeds/luci/applications/luci-app-jd-dailybonus 2>/dev/null || true

#===============================================================================
# 添加自定义配置文件
#===============================================================================
# 创建 files 目录用于自定义文件
mkdir -p files/etc/config
mkdir -p files/etc/uci-defaults

# 创建初始化脚本
cat > files/etc/uci-defaults/99-custom-settings << 'EOF'
#!/bin/sh

# 设置 root 密码为空（首次登录强制修改）
# passwd -d root

# 开启 WiFi
uci set wireless.radio0.disabled='0'
uci set wireless.radio1.disabled='0'

# 设置 WiFi 名称
uci set wireless.default_radio0.ssid='RedmiAC2100_2.4G'
uci set wireless.default_radio1.ssid='RedmiAC2100_5G'

# 设置 WiFi 加密方式
uci set wireless.default_radio0.encryption='psk2'
uci set wireless.default_radio1.encryption='psk2'

# 设置默认 WiFi 密码（建议首次登录后修改）
uci set wireless.default_radio0.key='12345678'
uci set wireless.default_radio1.key='12345678'

# 设置 5G 频宽为 80MHz
uci set wireless.radio1.htmode='VHT80'

# 设置 2.4G 频宽为 40MHz
uci set wireless.radio0.htmode='HT40'

# 提交更改
uci commit wireless

# 启用一些服务
# /etc/init.d/adguardhome enable 2>/dev/null || true
# /etc/init.d/passwall enable 2>/dev/null || true

exit 0
EOF

chmod +x files/etc/uci-defaults/99-custom-settings
echo "[INFO] 已创建自定义初始化脚本"

#===============================================================================
# 创建自定义 banner
#===============================================================================
cat > files/etc/banner << 'EOF'
  _____          _           _    _    ____ ___  _  ___   ___
 |  __ \        | |         (_)  / \  / ___|__ \/ |/ _ \ / _ \
 | |__) |___  __| |_ __ ___  _  / _ \| |     ) | | | | | | | |
 |  _  // _ \/ _` | '_ ` _ \| |/ ___ \ |___ / /| | |_| | |_| |
 |_| \_\  __/ (_| | | | | | | /_/   \_\____|___|_|\___/ \___/

 OpenWrt DIY Custom Firmware
 Device: Xiaomi Redmi Router AC2100
 -------------------------------------------------
 GitHub: https://github.com/YOUR_USERNAME/diy_openwrt
 -------------------------------------------------
EOF

echo "[INFO] 已创建自定义 Banner"

#===============================================================================
# 优化编译选项
#===============================================================================
# 启用 O2 优化
# sed -i 's/Os/O2/g' include/target.mk

# 启用 MIPS16 指令集（减小固件体积）
# echo "CONFIG_MIPS16=y" >> .config

#===============================================================================
# 修复一些已知问题
#===============================================================================

# 修复 hostapd 依赖问题
# sed -i 's/+hostapd-common/+hostapd-common +libubus/g' package/network/services/hostapd/Makefile 2>/dev/null || true

# 修复 feeds 中的一些依赖问题
# ./scripts/feeds update -a
# ./scripts/feeds install -a -f

echo ""
echo "[INFO] DIY Part 2 执行完成"
echo "=========================================="
echo ""
echo "定制内容摘要:"
echo "  - 默认 IP: ${DEFAULT_IP}"
echo "  - 默认主机名: ${DEFAULT_HOSTNAME}"
echo "  - 默认时区: Asia/Shanghai"
echo "  - 默认语言: 中文"
echo "  - 默认主题: Argon"
echo "  - WiFi 名称: RedmiAC2100_2.4G / RedmiAC2100_5G"
echo "  - WiFi 密码: 12345678 (请首次登录后修改)"
echo "=========================================="
