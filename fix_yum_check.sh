#!/bin/bash

SCRIPT="/root/zpy/qfusion_package/qfusion.sh"

# 备份脚本
cp "$SCRIPT" "${SCRIPT}.bak_$(date +%Y%m%d_%H%M%S)"

# 使用临时文件
TMPFILE=$(mktemp)

# 提取函数前面的部分（1-1556行）
head -1556 "$SCRIPT" > "$TMPFILE"

# 写入新的check_and_fix_yum_source函数
cat >> "$TMPFILE" << 'EOF'
check_and_fix_yum_source() {
    echo_blue "检查YUM源配置..."

    # 检查网络连接性（使用baidu.com）
    local network_ok=0
    if ping -c 1 -W 2 baidu.com &>/dev/null; then
        network_ok=1
    fi

    # 检查现有YUM源
    local yum_status="unknown"
    local has_local_iso=0
    local has_online_repo=0
    local repo_count=0

    # 统计repo文件数量
    if [ -d /etc/yum.repos.d ]; then
        repo_count=$(ls /etc/yum.repos.d/*.repo 2>/dev/null | wc -l)
    fi

    # 检查本地ISO挂载
    if mount | grep -q "/mnt/cdrom"; then
        has_local_iso=1
    fi

    # 测试YUM缓存（带超时）
    if timeout 30 yum makecache &>/dev/null 2>&1; then
        yum_status="working"

        # 检查是否有在线仓库（不依赖网络状态）
        if yum repolist 2>/dev/null | grep -qE "(centos|rhel|kylin|base|updates)"; then
            has_online_repo=1
        fi
    else
        yum_status="failed"
    fi

    # 显示检查结果
    if [ "$yum_status" = "working" ]; then
        CHECK_STATUS["yum_source"]="PASS"
        echo -e "${GREEN}✓${NC} YUM源: 配置正常"

        # 显示网络状态
        if [ $network_ok -eq 1 ]; then
            echo "   ${GREEN}✓${NC} 网络连通: 通外网"
        else
            echo "   ${YELLOW}!${NC} 网络状态: 不通外网"
        fi

        if [ $has_local_iso -eq 1 ]; then
            echo "   ${GREEN}✓${NC} 本地ISO源: $(mount | grep /mnt/cdrom | awk '{print $1}')"
        fi

        if [ $has_online_repo -eq 1 ]; then
            echo "   ${GREEN}✓${NC} 在线仓库: 可用"
        fi

        echo "   仓库配置文件: $repo_count 个"

        # 只在CHECK_ONLY模式下直接返回
        if [[ -n "$CHECK_ONLY" ]]; then
            return
        fi
    else
        CHECK_STATUS["yum_source"]="FAIL"
        echo -e "${RED}✗${NC} YUM源: 配置异常或不可用"

        # 分析失败原因
        if [ $repo_count -eq 0 ]; then
            echo "   ${RED}✗${NC} 未找到任何YUM仓库配置文件"
        fi

        if [ $network_ok -eq 0 ] && [ $has_local_iso -eq 0 ]; then
            echo "   ${YELLOW}!${NC} 网络不可用且无本地ISO源"
        elif [ $network_ok -eq 1 ]; then
            echo "   ${YELLOW}!${NC} 外网通但YUM源不可用，可能是YUM源配置问题"
        fi

        # 只检查模式直接返回
        if [[ -n "$CHECK_ONLY" ]]; then
            return
        fi

        echo ""
        echo "   YUM源配置异常可能导致软件包无法安装"

        # 提供修复选项
        if [ "$AUTO_CONFIRM" = "1" ]; then
            answer="y"
            echo "配置本地ISO YUM源? [Y/n]: [自动确认: Y]"
        else
            echo "请选择修复方式:"
            echo "1. 配置本地ISO YUM源（推荐）"
            echo "2. 尝试恢复在线YUM源"
            echo "3. 跳过YUM源配置"
            read -p "请选择 [1/2/3]: " answer
        fi

        case "$answer" in
            1|y|Y|"")
                if setup_local_yum_source; then
                    CHECK_STATUS["yum_source"]="FIXED"
                fi
                ;;
            2)
                echo_info "尝试恢复在线YUM源..."
                restore_online_yum_repos
                ;;
            3|n|N)
                echo_warn "跳过YUM源配置"
                ;;
            *)
                echo_warn "无效选择，跳过YUM源配置"
                ;;
        esac
    fi
}
EOF

# 提取函数后面的部分（从1667行开始到文件末尾）
tail -n +1667 "$SCRIPT" >> "$TMPFILE"

# 替换原脚本
mv "$TMPFILE" "$SCRIPT"

echo "YUM源检查函数修改完成！"
echo "主要改动："
echo "1. 网络检测改为: ping baidu.com"
echo "2. yum makecache超时从10秒改为30秒"
echo "3. 在线仓库检查不依赖网络状态"
echo "4. YUM源正常时显示网络状态"
echo "5. 失败时区分：不通外网 vs 外网通但YUM源不可用"
