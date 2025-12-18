#!/bin/bash
#===============================================================================
# OpenWrt 编译环境准备脚本
# 适用系统: Ubuntu 20.04/22.04 LTS, Debian 11/12
# 设备目标: 红米AC2100 (xiaomi_redmi-router-ac2100)
#===============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查是否为root用户（不建议使用root编译）
check_user() {
    if [ "$EUID" -eq 0 ]; then
        log_error "请不要使用root用户运行此脚本！"
        log_info "建议创建普通用户进行编译"
        exit 1
    fi
    log_info "当前用户: $(whoami)"
}

# 检查系统版本
check_system() {
    log_step "检查系统版本..."

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
        log_info "检测到系统: $PRETTY_NAME"
    else
        log_error "无法检测系统版本"
        exit 1
    fi

    case $OS in
        ubuntu)
            if [[ "$VER" != "20.04" && "$VER" != "22.04" && "$VER" != "24.04" ]]; then
                log_warn "推荐使用 Ubuntu 20.04/22.04/24.04 LTS"
            fi
            ;;
        debian)
            if [[ "$VER" != "11" && "$VER" != "12" ]]; then
                log_warn "推荐使用 Debian 11/12"
            fi
            ;;
        *)
            log_warn "未经测试的系统: $OS $VER"
            log_warn "建议使用 Ubuntu 或 Debian"
            ;;
    esac
}

# 更新系统
update_system() {
    log_step "更新系统软件包..."
    sudo apt update
    sudo apt upgrade -y
}

# 安装编译依赖
install_dependencies() {
    log_step "安装编译依赖包..."

    # OpenWrt 官方推荐的编译依赖
    sudo apt install -y \
        ack \
        antlr3 \
        asciidoc \
        autoconf \
        automake \
        autopoint \
        binutils \
        bison \
        build-essential \
        bzip2 \
        ccache \
        clang \
        cmake \
        cpio \
        curl \
        device-tree-compiler \
        ecj \
        fastjar \
        flex \
        gawk \
        gettext \
        git \
        g++ \
        g++-multilib \
        gcc-multilib \
        genisoimage \
        gperf \
        haveged \
        help2man \
        intltool \
        jq \
        libc6-dev-i386 \
        libelf-dev \
        libfuse-dev \
        libglib2.0-dev \
        libgmp3-dev \
        libltdl-dev \
        libmpc-dev \
        libmpfr-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libpython3-dev \
        libreadline-dev \
        libssl-dev \
        libtool \
        llvm \
        lrzsz \
        mkisofs \
        msmtp \
        nano \
        ninja-build \
        p7zip \
        p7zip-full \
        patch \
        pkgconf \
        python3 \
        python3-pip \
        python3-ply \
        python3-pyelftools \
        python3-setuptools \
        qemu-utils \
        re2c \
        rsync \
        scons \
        squashfs-tools \
        subversion \
        swig \
        texinfo \
        uglifyjs \
        unzip \
        vim \
        wget \
        xmlto \
        xxd \
        zlib1g-dev \
        zstd

    log_info "编译依赖安装完成"
}

# 安装可选工具
install_optional_tools() {
    log_step "安装可选工具..."

    # 安装 GitHub CLI（可选，用于发布）
    if ! command -v gh &> /dev/null; then
        log_info "安装 GitHub CLI..."
        type -p curl >/dev/null || sudo apt install curl -y
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
    fi

    log_info "可选工具安装完成"
}

# 配置Git
configure_git() {
    log_step "配置 Git..."

    # 检查是否已配置
    if [ -z "$(git config --global user.name)" ]; then
        read -p "请输入 Git 用户名: " git_name
        git config --global user.name "$git_name"
    fi

    if [ -z "$(git config --global user.email)" ]; then
        read -p "请输入 Git 邮箱: " git_email
        git config --global user.email "$git_email"
    fi

    # 优化Git配置
    git config --global http.sslVerify false
    git config --global http.postBuffer 524288000
    git config --global core.compression -1

    log_info "Git 配置完成"
    log_info "  用户名: $(git config --global user.name)"
    log_info "  邮箱: $(git config --global user.email)"
}

# 配置系统优化
optimize_system() {
    log_step "优化系统配置..."

    # 增加文件描述符限制
    if ! grep -q "* soft nofile" /etc/security/limits.conf; then
        echo "* soft nofile 65535" | sudo tee -a /etc/security/limits.conf
        echo "* hard nofile 65535" | sudo tee -a /etc/security/limits.conf
        log_info "已增加文件描述符限制"
    fi

    # 增加inotify监视数量
    if ! grep -q "fs.inotify.max_user_watches" /etc/sysctl.conf; then
        echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        log_info "已增加inotify监视数量"
    fi

    log_info "系统优化完成"
}

# 检查磁盘空间
check_disk_space() {
    log_step "检查磁盘空间..."

    # 获取当前目录所在分区的可用空间（GB）
    available=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')

    if [ "$available" -lt 50 ]; then
        log_error "磁盘空间不足！需要至少 50GB，当前可用 ${available}GB"
        exit 1
    elif [ "$available" -lt 100 ]; then
        log_warn "磁盘空间较少，建议 100GB 以上，当前可用 ${available}GB"
    else
        log_info "磁盘空间充足: ${available}GB 可用"
    fi
}

# 打印环境信息
print_environment() {
    log_step "环境信息汇总"
    echo "========================================"
    echo "系统信息:"
    echo "  操作系统: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "  内核版本: $(uname -r)"
    echo "  CPU核心: $(nproc)"
    echo "  内存大小: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "  磁盘空间: $(df -h . | awk 'NR==2 {print $4}') 可用"
    echo ""
    echo "工具版本:"
    echo "  GCC: $(gcc --version | head -1)"
    echo "  G++: $(g++ --version | head -1)"
    echo "  Make: $(make --version | head -1)"
    echo "  Git: $(git --version)"
    echo "  Python: $(python3 --version)"
    echo "========================================"
}

# 主函数
main() {
    echo "========================================"
    echo " OpenWrt 编译环境准备脚本"
    echo " 目标设备: 红米AC2100"
    echo "========================================"
    echo ""

    check_user
    check_system
    check_disk_space

    read -p "是否继续安装编译依赖？[Y/n] " confirm
    confirm=${confirm:-Y}

    if [[ $confirm =~ ^[Yy]$ ]]; then
        update_system
        install_dependencies
        install_optional_tools
        configure_git
        optimize_system
        print_environment

        echo ""
        log_info "=========================================="
        log_info "编译环境准备完成！"
        log_info "=========================================="
        log_info "下一步: 运行 ./scripts/clone-source.sh 克隆源码"
    else
        log_warn "已取消安装"
    fi
}

# 执行主函数
main "$@"
