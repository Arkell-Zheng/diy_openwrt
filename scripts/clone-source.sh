#!/bin/bash
#===============================================================================
# OpenWrt 源码克隆和更新脚本
# 设备目标: 红米AC2100 (xiaomi_redmi-router-ac2100)
#===============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OPENWRT_DIR="$PROJECT_DIR/openwrt"

# OpenWrt 源码仓库（可选择不同源）
# 官方源
OPENWRT_REPO_OFFICIAL="https://github.com/openwrt/openwrt.git"
# Lean's LEDE (包含更多中国用户常用软件包)
OPENWRT_REPO_LEDE="https://github.com/coolsnowwolf/lede.git"
# ImmortalWrt (中国优化版)
OPENWRT_REPO_IMMORTALWRT="https://github.com/immortalwrt/immortalwrt.git"

# 默认使用 Lean's LEDE 源（软件包更丰富）
OPENWRT_REPO="$OPENWRT_REPO_LEDE"
OPENWRT_BRANCH="master"

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# 选择源码仓库
select_repo() {
    echo "========================================"
    echo " 请选择 OpenWrt 源码仓库"
    echo "========================================"
    echo ""
    echo "1) Lean's LEDE (推荐，软件包丰富，适合国内用户)"
    echo "2) ImmortalWrt (中国优化版，稳定性好)"
    echo "3) OpenWrt 官方 (最新特性，软件包较少)"
    echo ""
    read -p "请选择 [1-3，默认1]: " choice
    choice=${choice:-1}

    case $choice in
        1)
            OPENWRT_REPO="$OPENWRT_REPO_LEDE"
            OPENWRT_BRANCH="master"
            log_info "已选择: Lean's LEDE"
            ;;
        2)
            OPENWRT_REPO="$OPENWRT_REPO_IMMORTALWRT"
            OPENWRT_BRANCH="master"
            log_info "已选择: ImmortalWrt"
            ;;
        3)
            OPENWRT_REPO="$OPENWRT_REPO_OFFICIAL"
            OPENWRT_BRANCH="main"
            log_info "已选择: OpenWrt 官方"
            ;;
        *)
            log_warn "无效选择，使用默认: Lean's LEDE"
            OPENWRT_REPO="$OPENWRT_REPO_LEDE"
            OPENWRT_BRANCH="master"
            ;;
    esac
}

# 克隆源码
clone_source() {
    log_step "克隆 OpenWrt 源码..."

    if [ -d "$OPENWRT_DIR" ]; then
        log_warn "源码目录已存在: $OPENWRT_DIR"
        read -p "是否删除并重新克隆？[y/N] " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            rm -rf "$OPENWRT_DIR"
        else
            log_info "跳过克隆，使用现有源码"
            return
        fi
    fi

    log_info "正在克隆 $OPENWRT_REPO ..."
    log_info "这可能需要较长时间，请耐心等待..."

    git clone --depth=1 -b "$OPENWRT_BRANCH" "$OPENWRT_REPO" "$OPENWRT_DIR"

    log_info "源码克隆完成"
}

# 添加第三方软件源
add_custom_feeds() {
    log_step "添加第三方软件源..."

    cd "$OPENWRT_DIR"

    # 备份原始 feeds.conf.default
    cp feeds.conf.default feeds.conf.default.bak

    # 根据选择的源添加额外的软件包源
    # 检查是否已经有 passwall 等源
    if ! grep -q "passwall" feeds.conf.default 2>/dev/null; then
        # 添加 PassWall 软件源
        echo "" >> feeds.conf.default
        echo "# PassWall packages" >> feeds.conf.default
        echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" >> feeds.conf.default
        echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default
        log_info "已添加 PassWall 软件源"
    fi

    # 添加 OpenClash 软件源
    if ! grep -q "openclash" feeds.conf.default 2>/dev/null; then
        echo "" >> feeds.conf.default
        echo "# OpenClash" >> feeds.conf.default
        echo "src-git openclash https://github.com/vernesong/OpenClash.git;master" >> feeds.conf.default
        log_info "已添加 OpenClash 软件源"
    fi

    # 添加其他常用软件源
    if ! grep -q "helloworld" feeds.conf.default 2>/dev/null; then
        echo "" >> feeds.conf.default
        echo "# SSR Plus+" >> feeds.conf.default
        echo "src-git helloworld https://github.com/fw876/helloworld.git;master" >> feeds.conf.default
        log_info "已添加 SSR Plus+ 软件源"
    fi

    log_info "第三方软件源添加完成"
    log_info "当前 feeds.conf.default 内容:"
    echo "----------------------------------------"
    cat feeds.conf.default
    echo "----------------------------------------"
}

# 更新和安装 feeds
update_feeds() {
    log_step "更新软件包源 (feeds)..."

    cd "$OPENWRT_DIR"

    # 更新 feeds
    ./scripts/feeds update -a

    log_info "Feeds 更新完成"
}

# 安装 feeds
install_feeds() {
    log_step "安装软件包源..."

    cd "$OPENWRT_DIR"

    # 安装所有 feeds
    ./scripts/feeds install -a

    log_info "Feeds 安装完成"
}

# 复制自定义配置
copy_custom_files() {
    log_step "复制自定义配置文件..."

    # 复制自定义 feeds 配置（如果存在）
    if [ -f "$PROJECT_DIR/config/feeds.conf" ]; then
        cp "$PROJECT_DIR/config/feeds.conf" "$OPENWRT_DIR/feeds.conf.default"
        log_info "已复制自定义 feeds 配置"
    fi

    # 复制自定义文件（如果存在）
    if [ -d "$PROJECT_DIR/files" ] && [ "$(ls -A $PROJECT_DIR/files)" ]; then
        cp -r "$PROJECT_DIR/files"/* "$OPENWRT_DIR/files/" 2>/dev/null || mkdir -p "$OPENWRT_DIR/files"
        log_info "已复制自定义文件"
    fi

    # 复制补丁文件（如果存在）
    if [ -d "$PROJECT_DIR/patches" ] && [ "$(ls -A $PROJECT_DIR/patches)" ]; then
        for patch in "$PROJECT_DIR/patches"/*.patch; do
            if [ -f "$patch" ]; then
                log_info "应用补丁: $(basename $patch)"
                cd "$OPENWRT_DIR"
                git apply "$patch" || log_warn "补丁应用失败: $(basename $patch)"
            fi
        done
    fi
}

# 显示设备信息
show_device_info() {
    log_step "红米AC2100 设备信息"
    echo "========================================"
    echo "设备名称: Xiaomi Redmi Router AC2100"
    echo "OpenWrt名: xiaomi_redmi-router-ac2100"
    echo "目标平台: ramips/mt7621"
    echo "CPU: MediaTek MT7621A (880MHz 双核)"
    echo "RAM: 128MB DDR3"
    echo "Flash: 128MB NAND"
    echo "无线芯片: MT7603EN (2.4G) + MT7615N (5G)"
    echo "========================================"
}

# 验证源码
verify_source() {
    log_step "验证源码完整性..."

    cd "$OPENWRT_DIR"

    # 检查关键目录
    local required_dirs=("target" "package" "scripts" "feeds.conf.default")
    for dir in "${required_dirs[@]}"; do
        if [ ! -e "$dir" ]; then
            log_error "缺少关键文件/目录: $dir"
            exit 1
        fi
    done

    # 检查目标设备支持
    if [ -d "target/linux/ramips" ]; then
        log_info "目标平台 ramips 存在"
    else
        log_warn "未找到 ramips 平台，可能需要检查源码版本"
    fi

    log_info "源码验证通过"
}

# 打印后续步骤
print_next_steps() {
    echo ""
    echo "========================================"
    echo -e "${GREEN}源码准备完成！${NC}"
    echo "========================================"
    echo ""
    echo "源码目录: $OPENWRT_DIR"
    echo ""
    echo "下一步操作:"
    echo "  1. 复制配置文件:"
    echo "     cp $PROJECT_DIR/config/redmi-ac2100.config $OPENWRT_DIR/.config"
    echo ""
    echo "  2. 运行 make menuconfig 进行配置（可选）:"
    echo "     cd $OPENWRT_DIR && make menuconfig"
    echo ""
    echo "  3. 运行编译脚本:"
    echo "     $PROJECT_DIR/scripts/build.sh"
    echo ""
    echo "========================================"
}

# 主函数
main() {
    echo "========================================"
    echo " OpenWrt 源码克隆和更新脚本"
    echo " 目标设备: 红米AC2100"
    echo "========================================"
    echo ""

    show_device_info

    # 检查参数
    if [ "$1" == "--update" ] || [ "$1" == "-u" ]; then
        # 仅更新 feeds
        if [ -d "$OPENWRT_DIR" ]; then
            update_feeds
            install_feeds
            log_info "Feeds 更新完成"
        else
            log_error "源码目录不存在，请先克隆源码"
            exit 1
        fi
        exit 0
    fi

    select_repo
    clone_source
    add_custom_feeds
    update_feeds
    install_feeds
    copy_custom_files
    verify_source
    print_next_steps
}

# 执行主函数
main "$@"
