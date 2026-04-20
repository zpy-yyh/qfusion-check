#!/bin/bash

# QFusion 批量只检查模式脚本 - SSH密钥认证版本
# 无需expect或其他额外软件，使用系统自带SSH功能

SCRIPT_DIR="/root/zpy"
NODES_FILE="$SCRIPT_DIR/qfusion_package/nodes.conf"
MAIN_SCRIPT="$SCRIPT_DIR/qfusion_package/qfusion.sh"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULT_DIR="$SCRIPT_DIR/check_results_$TIMESTAMP"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_blue() {
    echo -e "${BLUE}[*]${NC} $1"
}

check_prerequisites() {
    echo_blue "检查前置条件..."
    
    if [ ! -f "$NODES_FILE" ]; then
        echo_error "节点配置文件不存在: $NODES_FILE"
        return 1
    fi
    
    if [ ! -f "$MAIN_SCRIPT" ]; then
        echo_error "主脚本不存在: $MAIN_SCRIPT"
        return 1
    fi
    
    echo_info "前置条件检查通过"
    return 0
}

read_nodes() {
    local nodes=()
    while IFS=' ' read -r ip hostname role user auth; do
        [[ "$ip" =~ ^# ]] && continue
        [ -z "$ip" ] && continue
        nodes+=("$ip|$hostname|$role|$user|$auth")
    done < "$NODES_FILE"
    echo "${nodes[@]}"
}

check_ssh_connection() {
    local ip=$1
    local user=$2
    local auth=$3
    
    if [[ "$auth" =~ ^/ ]]; then
        ssh -i "$auth" -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes "$user@$ip" "echo OK" &>/dev/null
        return $?
    else
        return 1
    fi
}

run_check_on_node() {
    local ip=$1
    local hostname=$2
    local role=$3
    local user=$4
    local auth=$5
    local node_result_dir="$ip"
    
    echo ""
    echo_blue "=========================================="
    echo_info "检查节点: $hostname ($ip) [$role]"
    echo_blue "=========================================="
    
    mkdir -p "$RESULT_DIR/$node_result_dir"
    
    echo_info "检查SSH连接..."
    if ! check_ssh_connection "$ip" "$user" "$auth"; then
        echo_error "SSH连接失败: $ip"
        echo_error "请确认已配置SSH密钥认证"
        echo "SSH连接失败" > "$RESULT_DIR/$node_result_dir/status.txt"
        return 1
    fi
    echo_info "SSH连接成功"
    
    local ssh_params="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    if [[ "$auth" =~ ^/ ]]; then
        ssh_params="$ssh_params -i $auth"
    fi
    
    echo_info "复制检查脚本..."
    scp $ssh_params "$MAIN_SCRIPT" "$user@$ip:/tmp/qfusion.sh" &>/dev/null
    
    if [ $? -ne 0 ]; then
        echo_error "脚本复制失败"
        return 1
    fi
    echo_info "脚本复制成功"
    
    echo_info "开始执行检查（只读模式）..."
    ssh $ssh_params "$user@$ip" "bash /tmp/qfusion.sh --check" > "$RESULT_DIR/$node_result_dir/check_result.log" 2>&1
    
    echo ""
    echo_info "检查结果摘要:"
    if [ -f "$RESULT_DIR/$node_result_dir/check_result.log" ]; then
        tail -15 "$RESULT_DIR/$node_result_dir/check_result.log"
    fi
    
    echo_info "节点检查完成"
    ssh $ssh_params "$user@$ip" "rm -f /tmp/qfusion.sh" &>/dev/null
}

generate_summary_report() {
    echo ""
    echo_blue "=========================================="
    echo "        生成汇总报告"
    echo_blue "=========================================="
    
    local summary_file="$RESULT_DIR/summary_report.txt"
    
    echo "# QFusion集群检查报告" > "$summary_file"
    echo "" >> "$summary_file"
    echo "检查时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$summary_file"
    echo "集群规模: $(cat $NODES_FILE | wc -l) 个节点" >> "$summary_file"
    echo "认证方式: SSH密钥认证" >> "$summary_file"
    echo "" >> "$summary_file"
    echo "## 节点列表" >> "$summary_file"
    cat "$NODES_FILE" >> "$summary_file"
    echo "" >> "$summary_file"
    echo "## 详细日志目录: $RESULT_DIR" >> "$summary_file"
    
    echo_info "汇总报告: $summary_file"
    echo_info "详细日志: $RESULT_DIR"
    
    local total_nodes=$(ls -d "$RESULT_DIR"/*/ 2>/dev/null | wc -l)
    echo ""
    echo_blue "总节点数: $total_nodes"
}

main() {
    echo ""
    echo_blue "=========================================="
    echo "  QFusion 批量只检查模式"
    echo "  认证方式: SSH密钥"
    echo_blue "=========================================="
    echo ""
    echo_info "模式: 只读检查（不修改配置）"
    echo_info "节点配置: $NODES_FILE"
    echo ""
    echo_info "✅ 无需expect或其他额外软件"
    echo_info "✅ 使用系统自带SSH功能"
    echo ""
    
    if ! check_prerequisites; then
        exit 1
    fi
    
    echo_info "读取节点配置..."
    local nodes=($(read_nodes))
    
    if [ ${#nodes[@]} -eq 0 ]; then
        echo_error "未找到有效的节点配置"
        exit 1
    fi
    
    echo_info "发现 ${#nodes[@]} 个节点"
    echo ""
    
    echo_blue "节点列表:"
    for node in "${nodes[@]}"; do
        IFS='|' read -r ip hostname role user auth <<< "$node"
        printf "  %-20s %-15s %-8s" "$hostname" "$ip" "$role"
        
        if [[ "$auth" =~ ^/ ]]; then
            echo " [SSH密钥]"
        else
            echo " [密码 - 不支持]"
        fi
    done
    echo ""
    
    read -p "是否开始检查? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo_info "已取消"
        exit 0
    fi
    
    mkdir -p "$RESULT_DIR"
    
    for node in "${nodes[@]}"; do
        IFS='|' read -r ip hostname role user auth <<< "$node"
        run_check_on_node "$ip" "$hostname" "$role" "$user" "$auth"
    done
    
    generate_summary_report
    
    echo ""
    echo_info "所有节点检查完成！"
}

main "$@"
