#!/bin/bash
#===============================================================================
# OpenWrt 一键编译脚本
# 设备目标: 红米AC2100 (xiaomi_redmi-router-ac2100)
#===============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OPENWRT_DIR="$PROJECT_DIR/openwrt"
CONFIG_FILE="$PROJECT_DIR/config/redmi-ac2100.config"
OUTPUT_DIR="$PROJECT_DIR/output"

# 编译线程数 (默认使用全部CPU核心)
THREADS=$(nproc)

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# 计时函数
timer_start() {
    BUILD_START_TIME=$(date +%s)
}

timer_end() {
    BUILD_END_TIME=$(date +%s)
    BUILD_DURATION=$((BUILD_END_TIME - BUILD_START_TIME))
    HOURS=$((BUILD_DURATION / 3600))
    MINUTES=$(((BUILD_DURATION % 3600) / 60))
    SECONDS=$((BUILD_DURATION % 60))
    echo -e "${CYAN}编译耗时: ${HOURS}小时 ${MINUTES}分钟 ${SECONDS}秒${NC}"
}

# 检查环境
check_environment() {
    log_step "检查编译环境..."

    # 检查源码目录
    if [ ! -d "$OPENWRT_DIR" ]; then
        log_error "源码目录不存在: $OPENWRT_DIR"
        log_info "请先运行: $SCRIPT_DIR/clone-source.sh"
        exit 1
    fi

    # 检查配置文件
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "配置文件不存在: $CONFIG_FILE"
        exit 1
    fi

    # 检查磁盘空间
    available=$(df -BG "$OPENWRT_DIR" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available" -lt 20 ]; then
        log_error "磁盘空间不足，需要至少 20GB，当前可用 ${available}GB"
        exit 1
    fi

    log_info "环境检查通过"
}

# 复制配置文件
copy_config() {
    log_step "复制配置文件..."

    cd "$OPENWRT_DIR"

    # 备份现有配置
    if [ -f ".config" ]; then
        cp .config .config.bak.$(date +%Y%m%d_%H%M%S)
        log_info "已备份现有配置"
    fi

    # 复制新配置
    cp "$CONFIG_FILE" .config
    log_info "已复制配置文件"
}

# 运行 DIY 脚本
run_diy_scripts() {
    log_step "运行 DIY 定制脚本..."

    cd "$OPENWRT_DIR"

    # 运行 diy-part1.sh (feeds 更新前)
    if [ -f "$PROJECT_DIR/scripts/diy-part1.sh" ]; then
        log_info "执行 diy-part1.sh..."
        bash "$PROJECT_DIR/scripts/diy-part1.sh"
    fi

    # 更新并安装 feeds
    log_info "更新 feeds..."
    ./scripts/feeds update -a
    ./scripts/feeds install -a

    # 运行 diy-part2.sh (feeds 更新后)
    if [ -f "$PROJECT_DIR/scripts/diy-part2.sh" ]; then
        log_info "执行 diy-part2.sh..."
        bash "$PROJECT_DIR/scripts/diy-part2.sh"
    fi
}

# 扩展配置
expand_config() {
    log_step "扩展配置文件..."

    cd "$OPENWRT_DIR"

    # 使用 defconfig 扩展配置
    make defconfig

    log_info "配置扩展完成"
}

# 下载依赖
download_packages() {
    log_step "下载软件包..."

    cd "$OPENWRT_DIR"

    # 多线程下载
    make download -j$THREADS V=s

    # 检查下载是否完整
    find dl -size -1024c -exec ls -l {} \;
    find dl -size -1024c -exec rm -f {} \;

    log_info "软件包下载完成"
}

# 编译固件
compile_firmware() {
    log_step "开始编译固件..."
    log_info "使用 $THREADS 线程编译，这可能需要1-3小时..."

    cd "$OPENWRT_DIR"

    timer_start

    # 第一次编译使用单线程以便于排错
    if [ "$1" == "--single" ]; then
        log_info "使用单线程编译（调试模式）..."
        make -j1 V=s 2>&1 | tee build.log
    else
        # 多线程编译
        make -j$THREADS V=s 2>&1 | tee build.log
    fi

    timer_end
}

# 复制输出文件
copy_output() {
    log_step "复制编译产物..."

    # 创建输出目录
    mkdir -p "$OUTPUT_DIR"

    # 复制固件文件
    cd "$OPENWRT_DIR"

    # 查找固件文件
    FIRMWARE_DIR="bin/targets/ramips/mt7621"

    if [ -d "$FIRMWARE_DIR" ]; then
        # 复制所有固件文件
        cp -r "$FIRMWARE_DIR"/* "$OUTPUT_DIR/"

        # 列出固件文件
        echo ""
        log_info "编译产物已复制到: $OUTPUT_DIR"
        echo "========================================"
        ls -lh "$OUTPUT_DIR"/*.bin 2>/dev/null || log_warn "未找到 .bin 固件文件"
        echo "========================================"
    else
        log_error "未找到固件输出目录: $FIRMWARE_DIR"
        exit 1
    fi
}

# 清理编译
clean_build() {
    log_step "清理编译文件..."

    cd "$OPENWRT_DIR"

    case $1 in
        "all")
            make distclean
            log_info "已执行 distclean (完全清理)"
            ;;
        "target")
            make target/linux/clean
            make package/clean
            log_info "已清理目标文件和软件包"
            ;;
        *)
            make clean
            log_info "已执行 clean (基础清理)"
            ;;
    esac
}

# 打开配置菜单
open_menuconfig() {
    log_step "打开配置菜单..."

    cd "$OPENWRT_DIR"

    # 确保配置文件存在
    if [ ! -f ".config" ]; then
        cp "$CONFIG_FILE" .config
    fi

    make menuconfig
}

# 显示帮助
show_help() {
    echo "========================================"
    echo " OpenWrt 编译脚本 - 红米AC2100"
    echo "========================================"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  (无参数)      完整编译流程"
    echo "  --single      单线程编译（调试用）"
    echo "  --download    仅下载软件包"
    echo "  --compile     仅编译（跳过下载）"
    echo "  --menuconfig  打开配置菜单"
    echo "  --clean       清理编译文件"
    echo "  --clean-all   完全清理（包括配置）"
    echo "  --help        显示此帮助"
    echo ""
    echo "示例:"
    echo "  $0              # 完整编译"
    echo "  $0 --menuconfig # 修改配置"
    echo "  $0 --single     # 调试编译"
    echo ""
}

# 显示编译信息
show_build_info() {
    echo "========================================"
    echo " OpenWrt 编译信息"
    echo "========================================"
    echo "项目目录: $PROJECT_DIR"
    echo "源码目录: $OPENWRT_DIR"
    echo "配置文件: $CONFIG_FILE"
    echo "输出目录: $OUTPUT_DIR"
    echo "CPU核心数: $THREADS"
    echo "========================================"
    echo ""
}

# 主函数
main() {
    show_build_info

    case $1 in
        "--help"|"-h")
            show_help
            exit 0
            ;;
        "--menuconfig")
            copy_config
            run_diy_scripts
            open_menuconfig
            # 保存修改后的配置
            if [ -f "$OPENWRT_DIR/.config" ]; then
                log_info "是否保存修改后的配置到项目目录？"
                read -p "[y/N] " save_config
                if [[ $save_config =~ ^[Yy]$ ]]; then
                    cp "$OPENWRT_DIR/.config" "$CONFIG_FILE"
                    log_info "配置已保存到: $CONFIG_FILE"
                fi
            fi
            exit 0
            ;;
        "--download")
            check_environment
            copy_config
            run_diy_scripts
            expand_config
            download_packages
            exit 0
            ;;
        "--compile")
            check_environment
            compile_firmware
            copy_output
            exit 0
            ;;
        "--single")
            check_environment
            copy_config
            run_diy_scripts
            expand_config
            download_packages
            compile_firmware --single
            copy_output
            ;;
        "--clean")
            clean_build
            exit 0
            ;;
        "--clean-all")
            clean_build all
            exit 0
            ;;
        "")
            # 完整编译流程
            check_environment
            copy_config
            run_diy_scripts
            expand_config
            download_packages
            compile_firmware
            copy_output

            echo ""
            echo "========================================"
            echo -e "${GREEN}编译完成！${NC}"
            echo "========================================"
            echo "固件文件位于: $OUTPUT_DIR"
            echo ""
            echo "固件文件说明:"
            echo "  *-sysupgrade.bin  - 系统升级固件"
            echo "  *-factory.bin     - 全新刷机固件"
            echo ""
            echo "下一步: 参考刷机说明进行刷机"
            echo "========================================"
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
