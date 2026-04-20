#!/bin/bash

# QFusion 安装脚本
# 使用说明:
# 1. 解压 tar 包
# 2. 运行: bash install.sh

echo "=========================================="
echo "       QFusion 安装向导"
echo "=========================================="
echo ""

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "错误: 请使用 root 用户运行此脚本"
    exit 1
fi

# 设置安装目录
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="qfusion"

echo "准备安装 $SCRIPT_NAME 到 $INSTALL_DIR"
echo ""

# 复制脚本到安装目录
cp qfusion.sh "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# 检查安装是否成功
if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
    echo "✓ 安装成功!"
    echo ""
    echo "使用方法:"
    echo "  $SCRIPT_NAME                 # 交互式菜单"
    echo "  $SCRIPT_NAME --check        # 只检查不修复"
    echo "  $SCRIPT_NAME --remote-init  # 远程初始化模式"
    echo "  $SCRIPT_NAME --help         # 显示帮助"
    echo ""
    echo "脚本已安装到: $INSTALL_DIR/$SCRIPT_NAME"
    echo ""
    echo "现在您可以直接使用 '$SCRIPT_NAME' 命令"
else
    echo "✗ 安装失败!"
    exit 1
fi

echo "=========================================="