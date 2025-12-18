#!/bin/bash
#===============================================================================
# DIY 定制脚本 Part 1 - Feeds 更新前执行
# 设备目标: 红米AC2100 (xiaomi_redmi-router-ac2100)
#===============================================================================

# 此脚本在 feeds 更新之前执行
# 用于修改 feeds.conf.default 或添加自定义软件源

set -e

echo "=========================================="
echo " DIY Part 1 - Feeds 更新前定制"
echo "=========================================="

# 获取 OpenWrt 源码目录
OPENWRT_DIR="${OPENWRT_DIR:-$(pwd)}"
cd "$OPENWRT_DIR"

echo "[INFO] 当前目录: $(pwd)"

#===============================================================================
# 修改 feeds.conf.default
#===============================================================================

# 备份原始文件
if [ ! -f "feeds.conf.default.orig" ]; then
    cp feeds.conf.default feeds.conf.default.orig
    echo "[INFO] 已备份原始 feeds.conf.default"
fi

# 添加 PassWall 软件源
if ! grep -q "passwall" feeds.conf.default; then
    echo "" >> feeds.conf.default
    echo "# PassWall packages" >> feeds.conf.default
    echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" >> feeds.conf.default
    echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default
    echo "[INFO] 已添加 PassWall 软件源"
fi

# 添加 SSR Plus+ 软件源
if ! grep -q "helloworld" feeds.conf.default; then
    echo "" >> feeds.conf.default
    echo "# SSR Plus+" >> feeds.conf.default
    echo "src-git helloworld https://github.com/fw876/helloworld.git;master" >> feeds.conf.default
    echo "[INFO] 已添加 SSR Plus+ 软件源"
fi

# 添加 OpenClash 软件源
if ! grep -q "openclash" feeds.conf.default; then
    echo "" >> feeds.conf.default
    echo "# OpenClash" >> feeds.conf.default
    echo "src-git openclash https://github.com/vernesong/OpenClash.git;master" >> feeds.conf.default
    echo "[INFO] 已添加 OpenClash 软件源"
fi

# 添加 Argon 主题源
if ! grep -q "luci-theme-argon" feeds.conf.default; then
    echo "" >> feeds.conf.default
    echo "# Argon Theme" >> feeds.conf.default
    echo "src-git argon https://github.com/jerrykuku/luci-theme-argon.git;master" >> feeds.conf.default
    echo "src-git argon_config https://github.com/jerrykuku/luci-app-argon-config.git;master" >> feeds.conf.default
    echo "[INFO] 已添加 Argon 主题软件源"
fi

#===============================================================================
# 修改默认设置
#===============================================================================

# 修改默认 IP 地址（可选）
# sed -i 's/192.168.1.1/192.168.31.1/g' package/base-files/files/bin/config_generate

# 修改默认主机名
# sed -i 's/OpenWrt/RedmiAC2100/g' package/base-files/files/bin/config_generate

#===============================================================================
# 克隆额外的软件包仓库（如果需要）
#===============================================================================

# 克隆 AdGuard Home
# if [ ! -d "package/luci-app-adguardhome" ]; then
#     git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome
#     echo "[INFO] 已克隆 luci-app-adguardhome"
# fi

echo ""
echo "[INFO] DIY Part 1 执行完成"
echo "=========================================="
