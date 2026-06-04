#!/bin/bash
#
# QFusion Ansible 离线包下载脚本
# 用法: bash download.sh [centos7|rhel7|kylin|all]
#
# CentOS 7 / RHEL 7:
#   - EPEL: https://mirrors.aliyun.com/epel/7/x86_64/Packages/{首字母}/
#   - Base: https://vault.centos.org/centos/7.9.2009/os/x86_64/Packages/
#
# 麒麟 V10:
#   - pip wheel 包（需在 Linux 环境运行以获取 manylinux wheel）
#
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-all}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

EPEL="https://mirrors.aliyun.com/epel/7/x86_64/Packages"
VAULT="https://vault.centos.org/centos/7.9.2009/os/x86_64/Packages"

# ============ CentOS 7 / RHEL 7 ============
download_centos7() {
    local dest="$SCRIPT_DIR/centos7"
    mkdir -p "$dest"
    cd "$dest"

    echo "=========================================="
    echo "  下载 CentOS 7 / RHEL 7 离线包"
    echo "=========================================="
    echo "EPEL 源: $EPEL"
    echo "Base 源: $VAULT"
    echo ""

    # ---- EPEL 包（按首字母子目录） ----
    echo "--- EPEL 包 ---"
    EPEL_PKGS=(
        "ansible-2.9.27-1.el7.noarch.rpm"
        "sshpass-1.06-1.el7.x86_64.rpm"
        "python-paramiko-2.1.1-0.10.el7.noarch.rpm"
        "python2-httplib2-0.18.1-3.el7.noarch.rpm"
        "python2-jmespath-0.9.4-2.el7.noarch.rpm"
        "python2-idna-2.4-0.el7.noarch.rpm"
        "python2-enum34-1.0.4-0.el7.noarch.rpm"
        "python2-six-1.9.0-0.el7.noarch.rpm"
        "python2-crypto-2.6.1-16.el7.x86_64.rpm"
        "libtomcrypt-1.17-25.el7.x86_64.rpm"
        "libtommath-0.42.0-6.el7.x86_64.rpm"
    )

    for rpm in "${EPEL_PKGS[@]}"; do
        printf "  %-50s " "$rpm"
        first_char="${rpm:0:1}"
        curl -sL --connect-timeout 10 --max-time 120 "${EPEL}/${first_char}/${rpm}" -o "$rpm" 2>/dev/null
        if [ -f "$rpm" ] && [ "$(wc -c < "$rpm")" -gt 1000 ]; then
            echo "✓"
        else
            rm -f "$rpm"
            echo "✗"
        fi
    done

    # ---- CentOS 7 Base 包（无子目录） ----
    echo ""
    echo "--- CentOS 7 Base 包 ---"
    BASE_PKGS=(
        "python-jinja2-2.7.2-4.el7.noarch.rpm"
        "python2-cryptography-1.7.2-2.el7.x86_64.rpm"
        "python-cffi-1.6.0-5.el7.x86_64.rpm"
        "python-pycparser-2.14-1.el7.noarch.rpm"
        "python-idna-2.4-1.el7.noarch.rpm"
        "python2-pyasn1-0.1.9-7.el7.noarch.rpm"
        "python-enum34-1.0.4-1.el7.noarch.rpm"
        "python-ipaddress-1.0.16-2.el7.noarch.rpm"
        "PyYAML-3.10-11.el7.x86_64.rpm"
        "python-markupsafe-0.11-10.el7.x86_64.rpm"
        "python-babel-0.9.6-8.el7.noarch.rpm"
        "pytz-2016.10-2.el7.noarch.rpm"
        "python-six-1.9.0-2.el7.noarch.rpm"
        "python-backports-1.0-8.el7.x86_64.rpm"
        "python-backports-ssl_match_hostname-3.5.0.1-1.el7.noarch.rpm"
    )

    for rpm in "${BASE_PKGS[@]}"; do
        printf "  %-50s " "$rpm"
        curl -sL --connect-timeout 10 --max-time 120 "${VAULT}/${rpm}" -o "$rpm" 2>/dev/null
        if [ -f "$rpm" ] && [ "$(wc -c < "$rpm")" -gt 1000 ]; then
            echo "✓"
        else
            rm -f "$rpm"
            echo "✗"
        fi
    done

    local count=$(ls -1 *.rpm 2>/dev/null | wc -l)
    local size=$(du -sh . 2>/dev/null | cut -f1)
    echo ""
    echo_info "✓ CentOS 7 / RHEL 7: $count 个 RPM ($size)"
}

# ============ Kylin V10 ============
download_kylin() {
    local dest="$SCRIPT_DIR/kylin"
    mkdir -p "$dest"
    cd "$dest"

    echo "=========================================="
    echo "  下载麒麟 V10 离线包"
    echo "=========================================="
    echo ""

    if ! command -v pip3 &>/dev/null && ! command -v pip &>/dev/null; then
        echo_warn "未检测到 pip，尝试安装..."
        yum install -y python3-pip 2>/dev/null || apt-get install -y python3-pip 2>/dev/null || true
    fi

    PIP=$(command -v pip3 2>/dev/null || command -v pip 2>/dev/null || echo "pip3")

    # 下载 manylinux2014 兼容 wheel（兼容 CentOS 7 + Kylin V10）
    echo "下载 ansible 及依赖 (manylinux2014_x86_64)..."
    $PIP download \
        --only-binary=:all: \
        --platform manylinux2014_x86_64 \
        --python-version 39 \
        --abi cp39 \
        -d "$dest" \
        ansible 2>&1 || echo_warn "manylinux 下载部分失败，尝试源码包..."

    # 兜底：下载源码包
    echo ""
    echo "下载源码包作为编译兜底..."
    $PIP download --no-binary=:all: -d "$dest" ansible 2>&1 || true

    local whl_count=$(ls -1 *.whl 2>/dev/null | wc -l)
    local tar_count=$(ls -1 *.tar.gz 2>/dev/null | wc -l)
    local size=$(du -sh . 2>/dev/null | cut -f1)
    echo ""
    echo_info "✓ 麒麟 V10: $whl_count 个 wheel + $tar_count 个源码包 ($size)"
}

# ============ 打包 ============
make_tarball() {
    echo ""
    echo_info "打包离线包..."
    cd "$SCRIPT_DIR/.."
    local ts=$(date +%Y%m%d_%H%M%S)
    local tarball="ansible-qfusion-offline-pkgs-${ts}.tar.gz"
    tar -czf "$tarball" offline-pkgs/centos7/*.rpm offline-pkgs/kylin/*.whl offline-pkgs/kylin/*.tar.gz 2>/dev/null || true
    echo_info "✓ $tarball ($(du -sh "$tarball" 2>/dev/null | cut -f1))"
    echo "  拷贝到目标机器: tar -xzf $tarball -C /path/to/ansible-qfusion/"
}

# ============ 主流程 ============
case "$TARGET" in
    centos7|rhel7)
        download_centos7
        ;;
    kylin)
        download_kylin
        ;;
    all)
        download_centos7
        echo ""
        download_kylin
        make_tarball
        ;;
    *)
        echo "用法: bash download.sh [centos7|rhel7|kylin|all]"
        echo ""
        echo "  centos7 - 下载 CentOS 7 / RHEL 7 所需的 RPM 包"
        echo "  kylin   - 下载麒麟 V10 所需的 pip wheel 包（需在 Linux 上运行）"
        echo "  all     - 全部下载并打包为 tar.gz"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "  下载完成"
echo "=========================================="
echo "离线包位置: $SCRIPT_DIR/"
echo ""
echo "目标机器使用方法:"
echo "  1. 拷贝整个 ansible-qfusion 目录到目标机器"
echo "  2. 运行 ./ansible-playbook-wrapper.sh（自动部署环境）"
echo "  或手动: bash offline-pkgs/setup.sh"
echo "=========================================="
