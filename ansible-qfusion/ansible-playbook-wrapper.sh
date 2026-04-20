#!/bin/bash

# QFusion Ansible Playbook 包装脚本
# 提供友好的交互式菜单，类似原bash脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 节点清单文件
INVENTORY_FILE="inventory/hosts.yml"

# 报告目录
REPORT_DIR="/tmp/qfusion_ansible_reports"

# 输出函数
echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo_blue() {
    echo -e "${BLUE}[*]${NC} $1"
}

show_separator() {
    echo "=========================================="
}

# 检查依赖
check_dependencies() {
    echo_blue "检查依赖..."
    if ! command -v ansible &>/dev/null; then
        echo_error "未安装Ansible，请先安装"
        echo_info "安装命令: yum install -y ansible"
        exit 1
    fi
    echo_info "✓ Ansible已安装"
    echo ""
}

# 检查节点清单
check_inventory() {
    if [ ! -f "$INVENTORY_FILE" ]; then
        echo_warn "节点清单不存在，将使用默认配置"
        return 1
    fi

    echo_blue "检查节点清单..."
    local node_count=$(grep -E 'ansible_host:' "$INVENTORY_FILE" | wc -l)
    echo_info "发现 $node_count 个节点"
    echo ""
    return 0
}

# 编辑节点清单
edit_inventory() {
    echo_blue "编辑节点清单..."
    if [ ! -f "$INVENTORY_FILE" ]; then
        echo_warn "节点清单不存在，将创建默认配置"
        cp "$INVENTORY_FILE.example" "$INVENTORY_FILE" 2>/dev/null || {
            echo_error "无法创建节点清单"
            return 1
        }
    fi

    local editor="${EDITOR:-vi}"
    echo_info "将使用 $editor 编辑器打开节点清单"
    read -p "按回车键继续..."
    $editor "$INVENTORY_FILE"
}

# 显示节点列表
show_nodes() {
    echo ""
    echo_blue "当前节点列表:"
    show_separator
    grep -A 20 'qfusion_masters:' "$INVENTORY_FILE" | grep -E '^\s+.*:' | grep -v 'vars' | \
        awk '{printf "  %-20s %-15s\n", $1, $2}' || echo "  (未配置节点)"
    show_separator
    echo ""
}

# 测试连接
test_connection() {
    echo_blue "测试节点连接..."
    show_separator

    if ! check_inventory; then
        echo_error "无法测试连接，请先配置节点清单"
        return 1
    fi

    ansible -i "$INVENTORY_FILE" qfusion_cluster -m ping || {
        echo_error "连接测试失败"
        echo_info "请检查:"
        echo "  1. IP地址是否正确"
        echo "  2. SSH端口是否开放"
        echo "  3. SSH密钥或密码是否正确"
        echo "  4. 防火墙规则"
        return 1
    }

    show_separator
    echo_info "✓ 所有节点连接正常"
    echo ""
}

# 只检查模式
run_check_only() {
    echo_blue "执行只检查模式..."
    show_separator
    echo "此模式只执行检查，不修改任何配置"
    echo ""

    if ! check_inventory; then
        echo_error "请先配置节点清单"
        return 1
    fi

    ansible-playbook -i "$INVENTORY_FILE" playbooks/check_only.yml

    echo ""
    show_separator
    echo_info "✓ 检查完成"
    echo_info "报告目录: $REPORT_DIR"
    show_separator
    echo ""
}

# 检查并修复模式
run_fix_and_check() {
    echo_blue "执行检查并修复模式..."
    show_separator
    echo_warn "⚠️  此模式会修改系统配置"
    echo "修改包括但不限于:"
    echo "  - SELinux状态"
    echo "  - Swap分区"
    echo "  - DNS配置"
    echo "  - 系统参数(sysctl)"
    echo "  - 用户资源限制"
    echo ""

    if ! check_inventory; then
        echo_error "请先配置节点清单"
        return 1
    fi

    read -p "确认继续? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo_info "已取消"
        return 0
    fi

    ansible-playbook -i "$INVENTORY_FILE" playbooks/fix_and_check.yml

    echo ""
    show_separator
    echo_info "✓ 修复完成"
    echo_info "报告目录: $REPORT_DIR"
    echo_warn "如修改了SELinux或grub，请重启系统"
    show_separator
    echo ""
}

# 远程初始化模式
run_remote_init() {
    echo_blue "执行远程初始化..."
    show_separator
    echo "此模式包含完整初始化流程:"
    echo "  1. 环境检查"
    echo "  2. 系统修复"
    echo "  3. RAID配置(需手动)"
    echo "  4. 安装前准备"
    echo ""

    if ! check_inventory; then
        echo_error "请先配置节点清单"
        return 1
    fi

    echo_warn "⚠️  这是一个深度系统初始化流程"
    read -p "确认继续? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo_info "已取消"
        return 0
    fi

    ansible-playbook -i "$INVENTORY_FILE" playbooks/remote_init.yml

    echo ""
    show_separator
    echo_info "✓ 远程初始化完成"
    echo_info "初始化摘要: 各节点的 /tmp/qfusion_init_summary.txt"
    echo_info "检查报告: $REPORT_DIR"
    show_separator
    echo ""
}

# 查看报告
view_reports() {
    echo_blue "查看检查报告..."
    show_separator

    if [ ! -d "$REPORT_DIR" ]; then
        echo_warn "报告目录不存在"
        echo_info "请先执行检查"
        return 1
    fi

    local report_count=$(ls -1 "$REPORT_DIR"/*_check_report.txt 2>/dev/null | wc -l)
    if [ $report_count -eq 0 ]; then
        echo_warn "未找到检查报告"
        return 1
    fi

    echo_info "发现 $report_count 个检查报告"
    echo ""

    for report in "$REPORT_DIR"/*_check_report.txt; do
        if [ -f "$report" ]; then
            echo_blue "报告: $(basename "$report")"
            cat "$report"
            echo ""
            show_separator
            echo ""
        fi
    done
}

# 主菜单
show_menu() {
    while true; do
        clear
        echo ""
        echo "=========================================="
        echo "      QFusion Ansible 管理脚本"
        echo "=========================================="
        echo ""
        echo "1. 配置节点清单"
        echo "2. 查看节点列表"
        echo "3. 测试节点连接"
        echo "4. 只检查（不修改）"
        echo "5. 检查并修复"
        echo "6. 远程初始化"
        echo "7. 查看检查报告"
        echo "8. 帮助"
        echo "0. 退出"
        echo ""
        show_separator
        read -p "请选择 [0-8]: " choice

        case $choice in
            1)
                edit_inventory
                ;;
            2)
                show_nodes
                read -p "按回车键继续..."
                ;;
            3)
                test_connection
                read -p "按回车键继续..."
                ;;
            4)
                run_check_only
                read -p "按回车键继续..."
                ;;
            5)
                run_fix_and_check
                read -p "按回车键继续..."
                ;;
            6)
                run_remote_init
                read -p "按回车键继续..."
                ;;
            7)
                view_reports
                read -p "按回车键继续..."
                ;;
            8)
                echo ""
                cat README.md
                echo ""
                read -p "按回车键继续..."
                ;;
            0)
                echo ""
                echo_info "退出"
                exit 0
                ;;
            *)
                echo_error "无效选择"
                read -p "按回车键继续..."
                ;;
        esac
    done
}

# 主函数
main() {
    check_dependencies

    # 如果有参数，直接执行
    case "${1:-}" in
        --check)
            run_check_only
            ;;
        --fix)
            run_fix_and_check
            ;;
        --init)
            run_remote_init
            ;;
        --test)
            test_connection
            ;;
        --edit)
            edit_inventory
            ;;
        --report)
            view_reports
            ;;
        --help|-h)
            cat README.md
            ;;
        *)
            # 否则显示菜单
            show_menu
            ;;
    esac
}

# 运行主函数
main "$@"
