#!/bin/bash
#
# RHEL 7 使用与 CentOS 7 完全相同的 RPM 包
# 此脚本转发到 centos7 目录
#
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 如果 rhel7 目录为空，从 centos7 软链过来
if [ -z "$(ls -1 "$SCRIPT_DIR"/*.rpm 2>/dev/null)" ]; then
    if [ -d "$SCRIPT_DIR/../centos7" ] && ls "$SCRIPT_DIR/../centos7"/*.rpm 2>/dev/null; then
        echo "RHEL 7 与 CentOS 7 共享同一套 RPM 离线包"
        echo "请在 download.sh 中使用 centos7 目标下载"
    fi
fi

# 调用公共安装逻辑（setup.sh 会自动识别 rhel7）
bash "$SCRIPT_DIR/../setup.sh" "$@"
