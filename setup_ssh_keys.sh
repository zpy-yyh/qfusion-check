#!/bin/bash

# SSH密钥快速配置脚本
# 用于配置到所有节点的SSH免密登录

NODES_FILE="/root/zpy/qfusion_package/nodes.conf"

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

echo ""
echo_blue "=========================================="
echo "     SSH密钥快速配置工具"
echo_blue "=========================================="
echo ""

# 检查节点配置文件
if [ ! -f "$NODES_FILE" ]; then
    echo_error "节点配置文件不存在: $NODES_FILE"
    echo_info "请先创建节点配置文件"
    exit 1
fi

# 步骤1: 生成SSH密钥
echo_blue "步骤1: 生成SSH密钥"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f ~/.ssh/id_rsa ]; then
    echo_warn "SSH密钥已存在"
    read -p "是否重新生成? (yes/no): " regenerate
    if [ "$regenerate" != "yes" ]; then
        echo_info "使用现有SSH密钥"
    else
        echo_info "重新生成SSH密钥..."
        rm -f ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
        ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa
        echo_info "SSH密钥生成完成"
    fi
else
    echo_info "生成SSH密钥..."
    ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa
    echo_info "SSH密钥生成完成"
fi

echo ""

# 步骤2: 读取节点列表
echo_blue "步骤2: 读取节点列表"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

nodes=()
while IFS=' ' read -r ip hostname role user auth; do
    [[ "$ip" =~ ^# ]] && continue
    [ -z "$ip" ] && continue
    nodes+=("$ip|$hostname|$user|$auth")
done < "$NODES_FILE"

if [ ${#nodes[@]} -eq 0 ]; then
    echo_error "未找到有效的节点配置"
    exit 1
fi

echo_info "发现 ${#nodes[@]} 个节点"
for node in "${nodes[@]}"; do
    IFS='|' read -r ip hostname user auth <<< "$node"
    echo "  - $hostname ($ip)"
done
echo ""

# 步骤3: 配置免密登录
echo_blue "步骤3: 配置免密登录到各节点"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

success_count=0
fail_count=0

for node in "${nodes[@]}"; do
    IFS='|' read -r ip hostname user auth <<< "$node"
    
    echo_info "配置 $hostname ($ip)..."
    
    # 使用密码配置（如果配置文件中有密码）
    if [ -n "$auth" ] && [[ ! "$auth" =~ ^/ ]]; then
        # 使用expect脚本
        /usr/bin/expect << EXPECTEOF 2>/dev/null
set timeout 10
spawn ssh-copy-id -o StrictHostKeyChecking=no $user@$ip
expect {
    "password:" {
        send "$auth\r"
        expect eof
        exit 0
    }
    "already exist" {
        expect eof
        exit 0
    }
    eof {
        exit 0
    }
    timeout {
        exit 1
    }
}
EXPECTEOF
        
        if [ $? -eq 0 ]; then
            echo_info "  ✓ 配置成功"
            ((success_count++))
        else
            echo_warn "  ⚠ expect未安装，尝试使用sshpass"
            
            # 尝试使用sshpass
            if command -v sshpass &>/dev/null; then
                sshpass -p "$auth" ssh-copy-id -o StrictHostKeyChecking=no "$user@$ip" &>/dev/null
                if [ $? -eq 0 ]; then
                    echo_info "  ✓ 配置成功"
                    ((success_count++))
                else
                    echo_error "  ✗ 配置失败"
                    ((fail_count++))
                fi
            else
                echo_error "  ✗ 配置失败（需要expect或sshpass）"
                ((fail_count++))
            fi
        fi
    else
        # 手动配置提示
        echo_warn "  需要手动配置"
        echo_info "  请执行: ssh-copy-id $user@$ip"
        echo_info "  然后输入密码: $auth"
        ((fail_count++))
    fi
    
    echo ""
done

# 步骤4: 验证配置
echo_blue "步骤4: 验证免密登录"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

verified_count=0

for node in "${nodes[@]}"; do
    IFS='|' read -r ip hostname user auth <<< "$node"
    
    echo -n "测试 $hostname ($ip)... "
    
    if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes "$user@$ip" "hostname" &>/dev/null; then
        echo -e "${GREEN}✓ 成功${NC}"
        ((verified_count++))
    else
        echo -e "${RED}✗ 失败${NC}"
    fi
done

echo ""

# 汇总
echo_blue "=========================================="
echo "        配置汇总"
echo_blue "=========================================="
echo ""
echo "总节点数: ${#nodes[@]}"
echo -e "${GREEN}配置成功: $success_count${NC}"
echo -e "${YELLOW}需要手动: $fail_count${NC}"
echo -e "${GREEN}验证通过: $verified_count${NC}"
echo ""

if [ $verified_count -eq ${#nodes[@]} ]; then
    echo_info "🎉 所有节点配置完成！"
    echo ""
    echo_info "下一步："
    echo_info "  1. 更新节点配置文件，使用密钥认证"
    echo_info "  2. 运行批量检查: bash /root/zpy/batch_check_only.sh"
    echo ""
    echo_info "配置文件格式："
    echo "  10.10.156.97 rds001 master root /root/.ssh/id_rsa"
else
    echo_warn "部分节点配置失败，请手动配置"
    echo ""
    echo_info "手动配置方法："
    for node in "${nodes[@]}"; do
        IFS='|' read -r ip hostname user auth <<< "$node"
        echo "  ssh-copy-id $user@$ip"
    done
fi
