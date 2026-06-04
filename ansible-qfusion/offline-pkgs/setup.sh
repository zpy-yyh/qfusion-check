#!/bin/bash
#
# QFusion Ansible 离线安装脚本
# 自动检测 OS 并从离线包安装 Ansible
#
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ---- OS 检测 ----
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        local id=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
        local ver=$(echo "$VERSION_ID" | cut -d. -f1)
        echo "${id}${ver}"
    elif [ -f /etc/redhat-release ]; then
        local ver=$(grep -oE '[0-9]+' /etc/redhat-release | head -1)
        echo "centos${ver}"
    elif [ -f /etc/kylin-release ]; then
        echo "kylin10"
    else
        echo "unknown"
    fi
}

# ==================== CentOS 7 / RHEL 7 安装 ====================
install_centos7() {
    local pkg_dir="$SCRIPT_DIR/centos7"
    echo_info "检测到 CentOS 7 / RHEL 7，使用 RPM 离线安装..."

    if [ ! -d "$pkg_dir" ] || [ -z "$(ls -1 "$pkg_dir"/*.rpm 2>/dev/null)" ]; then
        echo_warn "离线 RPM 包不存在，尝试使用 yum 在线安装..."
        yum install -y epel-release 2>/dev/null || true
        yum install -y ansible sshpass 2>/dev/null || {
            echo_error "yum 安装失败，请手动执行: bash offline-pkgs/download.sh centos7"
            return 1
        }
        echo_info "✓ Ansible 已通过 yum 安装"
        return 0
    fi

    echo_info "从本地 RPM 安装 ($(ls -1 "$pkg_dir"/*.rpm 2>/dev/null | wc -l) 个包)..."

    # 先单独安装 epel-release
    if ls "$pkg_dir"/epel-release-*.rpm 2>/dev/null; then
        rpm -ivh --replacepkgs "$pkg_dir"/epel-release-*.rpm 2>/dev/null || true
    fi

    # 批量安装
    rpm -ivh --replacepkgs --nodeps "$pkg_dir"/*.rpm 2>/dev/null
    # 用 yum 修复依赖关系
    yum localinstall -y "$pkg_dir"/*.rpm 2>/dev/null || {
        # 如果 yum localinstall 失败，尝试用 rpm --nodeps 逐个装
        echo_warn "yum localinstall 失败，尝试逐个安装..."
        for rpm in "$pkg_dir"/*.rpm; do
            rpm -ivh --replacepkgs --nodeps "$rpm" 2>/dev/null || true
        done
    }

    echo_info "✓ Ansible 安装完成"
}

# ==================== Kylin V10 安装 ====================
install_kylin() {
    local pkg_dir="$SCRIPT_DIR/kylin"
    echo_info "检测到麒麟 V10，使用 pip wheel 离线安装..."

    # 确保 python3 和 pip3 可用
    if ! command -v python3 &>/dev/null; then
        echo_info "安装 python3..."
        yum install -y python3 2>/dev/null || apt-get install -y python3 2>/dev/null || {
            echo_error "无法安装 python3，请手动安装后重试"
            return 1
        }
    fi

    if ! command -v pip3 &>/dev/null; then
        echo_info "安装 python3-pip..."
        yum install -y python3-pip 2>/dev/null || apt-get install -y python3-pip 2>/dev/null || {
            # 通过 get-pip.py 安装
            echo_warn "使用 get-pip.py 安装 pip..."
            python3 -m ensurepip --upgrade 2>/dev/null || true
        }
    fi

    # 如果有离线 wheel，从离线装
    if [ -d "$pkg_dir" ] && ls "$pkg_dir"/*.whl 2>/dev/null; then
        echo_info "从本地 wheel 安装 ($(ls -1 "$pkg_dir"/*.whl 2>/dev/null | wc -l) 个包)..."
        pip3 install --no-index --find-links="$pkg_dir" ansible 2>/dev/null || {
            # --no-index 失败则允许从网络回退
            pip3 install --find-links="$pkg_dir" ansible 2>/dev/null || {
                echo_error "pip 安装失败"
                return 1
            }
        }
    else
        echo_warn "离线 wheel 不存在，尝试在线安装..."
        pip3 install ansible 2>/dev/null || {
            echo_error "pip 在线安装失败，请手动执行: bash offline-pkgs/download.sh kylin"
            return 1
        }
    fi

    echo_info "✓ Ansible 安装完成"
}

# ==================== 通用安装（fallback） ====================
install_generic() {
    echo_info "尝试通用 pip 安装..."
    if command -v pip3 &>/dev/null; then
        pip3 install ansible 2>/dev/null && {
            echo_info "✓ Ansible 通过 pip3 安装完成"
            return 0
        }
    fi
    if command -v pip &>/dev/null; then
        pip install ansible 2>/dev/null && {
            echo_info "✓ Ansible 通过 pip 安装完成"
            return 0
        }
    fi
    echo_error "无法自动安装 Ansible，请手动安装"
    return 1
}

# ==================== 主流程 ====================
main() {
    echo "=========================================="
    echo "  QFusion Ansible 环境部署"
    echo "=========================================="

    # 已安装则跳过
    if command -v ansible &>/dev/null; then
        echo_info "Ansible 已安装: $(ansible --version 2>/dev/null | head -1)"
        return 0
    fi

    local os_type=$(detect_os)
    echo_info "检测到操作系统: $os_type"

    case "$os_type" in
        centos7|rhel7|redhat7)
            install_centos7
            ;;
        kylin10|kylin*)
            install_kylin
            ;;
        centos8|rhel8|redhat8|centos9|rhel9|redhat9)
            echo_info "检测到 RHEL 8/9 系列，尝试 RPM 安装..."
            # RHEL 8+ 使用 ansible-core 或 ansible from appstream
            yum install -y ansible 2>/dev/null || dnf install -y ansible 2>/dev/null || install_generic
            ;;
        *)
            echo_warn "未知系统 ($os_type)，尝试通用安装..."
            install_generic
            ;;
    esac

    # 验证
    if command -v ansible &>/dev/null; then
        echo ""
        echo_info "=========================================="
        echo_info "  ✓ 环境部署成功"
        echo_info "  $(ansible --version | head -1)"
        echo_info "=========================================="
        return 0
    else
        echo ""
        echo_error "=========================================="
        echo_error "  ✗ Ansible 安装失败"
        echo_error "=========================================="
        echo_warn "请手动安装 Ansible:"
        echo "  CentOS 7: yum install -y epel-release && yum install -y ansible"
        echo "  Kylin V10: pip3 install ansible"
        echo "  或下载离线包: bash offline-pkgs/download.sh all"
        echo_error "=========================================="
        return 1
    fi
}

main "$@"
