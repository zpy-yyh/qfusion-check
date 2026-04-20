# ================== 新增的核心检查项函数 ==================

# 定义全局变量存储操作系统信息
OS_TYPE=""
OS_VERSION=""
OS_DISTRO=""

# 检测操作系统类型和版本
detect_os() {
    # 读取操作系统信息
    if [ -f /etc/redhat-release ]; then
        local release_file=$(cat /etc/redhat-release)
        if [[ "$release_file" =~ Red\ Hat\ Enterprise\ Linux\ Server\ release\ 7\. ]]; then
            OS_TYPE="redhat"
            OS_VERSION=$(echo "$release_file" | grep -oP 'release \K[0-9.]+')
        elif [[ "$release_file" =~ CentOS\ Linux\ release\ 7\. ]]; then
            OS_TYPE="centos"
            OS_VERSION=$(echo "$release_file" | grep -oP 'release \K[0-9.]+')
        else
            OS_TYPE="unknown"
            OS_VERSION=$(echo "$release_file" | grep -oP 'release \K[0-9.]+')
        fi
        OS_DISTRO="$release_file"
    elif [ -f /etc/kylin-release ]; then
        OS_TYPE="kylin"
        OS_VERSION=$(cat /etc/kylin-release)
        OS_DISTRO="$OS_VERSION"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_TYPE="$ID"
        OS_VERSION="$VERSION"
        OS_DISTRO="$PRETTY_NAME"
    else
        OS_TYPE="unknown"
        OS_VERSION="unknown"
        OS_DISTRO="Unknown OS"
    fi

    export OS_TYPE OS_VERSION OS_DISTRO
}

# 检查lsblk与/etc/fstab匹配
check_lsblk_fstab() {
    echo_blue "检查lsblk与/etc/fstab匹配..."

    if [ ! -f /etc/fstab ]; then
        echo_error "/etc/fstab文件不存在"
        return 1
    fi

    # 提取fstab中的设备信息
    local fstab_devices=$(grep -vE '^#|^$' /etc/fstab | awk '{print $1}' | grep -v 'swap')
    local mismatch_count=0

    for device in $fstab_devices; do
        # 跳过特殊文件系统
        if [[ "$device" =~ ^(swap|proc|sys|dev|tmp|none)$ ]]; then
            continue
        fi

        # 检查设备是否存在
        if [[ "$device" =~ ^/dev/ ]]; then
            local dev_name=$(basename "$device")
            if ! lsblk -o NAME -n | grep -q "^${dev_name}$"; then
                echo_warn "fstab中的设备 $device 不存在"
                ((mismatch_count++))
            fi
        elif [[ "$device" =~ ^UUID= ]]; then
            local uuid=$(echo "$device" | sed 's/UUID=//')
            if ! blkid | grep -q "$uuid"; then
                echo_warn "fstab中的UUID $uuid 不存在"
                ((mismatch_count++))
            fi
        elif [[ "$device" =~ ^/dev/mapper/ ]]; then
            # LVM设备
            local mapper_name=$(basename "$device")
            if ! lsblk -o NAME -n | grep -q "$mapper_name"; then
                echo_warn "fstab中的LVM设备 $device 不存在"
                ((mismatch_count++))
            fi
        fi
    done

    if [ $mismatch_count -eq 0 ]; then
        echo_info "lsblk与fstab匹配正常"
        return 0
    else
        echo_error "发现 $mismatch_count 个不匹配的设备"
        return 1
    fi
}

# 检查内核版本
check_kernel_version() {
    echo_blue "检查内核版本..."

    detect_os

    local current_kernel=$(uname -r)
    local major_version=$(echo "$current_kernel" | cut -d'.' -f1,2)

    echo_info "当前内核版本: $current_kernel"
    echo_info "操作系统: $OS_DISTRO"

    case "$OS_TYPE" in
        redhat|centos)
            # 红帽系统需要升级内核到4.19以上
            if [[ "$major_version" < "4.19" ]]; then
                echo_error "红帽系统内核版本过低 ($current_kernel < 4.19)"
                echo_info "需要升级内核到 4.19 或更高版本"
                return 1
            else
                echo_info "内核版本符合要求"
                return 0
            fi
            ;;
        kylin)
            # 麒麟系统不需要升级内核
            echo_info "麒麟系统无需升级内核"
            return 0
            ;;
        *)
            echo_warn "未知操作系统类型: $OS_TYPE"
            echo_info "建议手动确认内核版本要求"
            return 2
            ;;
    esac
}

# 检查IPv6状态
check_ipv6() {
    echo_blue "检查IPv6状态..."

    local ipv6_enabled=0

    # 检查多个可能的IPv6配置位置
    if [ -f /proc/sys/net/ipv6/conf/all/disable_ipv6 ]; then
        if [ $(cat /proc/sys/net/ipv6/conf/all/disable_ipv6) -eq 0 ]; then
            ipv6_enabled=1
        fi
    fi

    # 检查grub配置
    if [ -f /etc/default/grub ]; then
        if ! grep -q 'ipv6.disable=1' /etc/default/grub; then
            ipv6_enabled=1
        fi
    fi

    if [ $ipv6_enabled -eq 1 ]; then
        echo_warn "IPv6已启用"
        echo_info "QFusion安装时需要关闭IPv6"
        echo_info "麒麟系统如果IPv6配置正确可以保留，新版本已修复相关问题"
        return 1
    else
        echo_info "IPv6已关闭"
        return 0
    fi
}

# 检查iptables状态
check_iptables() {
    echo_blue "检查iptables状态..."

    local iptables_running=0

    if systemctl is-active iptables &>/dev/null; then
        iptables_running=1
    fi

    if [ $iptables_running -eq 1 ]; then
        echo_warn "iptables服务正在运行"
        echo_info "检查iptables规则..."

        if iptables-save 2>/dev/null | grep -q "REJECT"; then
            echo_error "iptables存在REJECT规则，可能影响QFusion组件启动"
            echo_info "建议: systemctl stop iptables && systemctl disable iptables"
            return 1
        else
            echo_warn "iptables运行中但无REJECT规则"
            echo_info "建议: 如无特殊需求，建议关闭iptables"
            return 2
        fi
    else
        echo_info "iptables服务未运行"
        return 0
    fi
}

# 检查kdump配置
check_kdump() {
    echo_blue "检查kdump配置..."

    if [ ! -f /etc/sysconfig/kdump ]; then
        echo_warn "kdump配置文件不存在"
        return 2
    fi

    local kdump_status=$(systemctl is-active kdump 2>/dev/null)
    local kdump_required_params="modprobe.blacklist=mlx_compat,bnxt_en,ib_cm,ib_core,ib_ucm,ib_umad,ib_uverbs,iw_cm,rdma_cm,rdma_ucm,mlx4_ib,mlx5_ib,ib_ipoib,mlx4_core,mlx4_en,mlx5_core,mlx5_fpga_tools,mlxfw,oracleacfs,oracleadvm,oracleoks irqpoll nr_cpus=1 reset_devices cgroup_disable=memory mce=off numa=off udev.children-max=2 panic=10 rootflags=nofail acpi_no_memhotplug transparent_hugepage=never nokaslr novmcoredd hest_disable"

    # 检查kdump服务状态
    if [ "$kdump_status" != "active" ] && [ "$kdump_status" != "exited" ]; then
        echo_warn "kdump服务状态: $kdump_status"
        echo_info "建议: systemctl enable kdump && systemctl start kdump"
    fi

    # 检查KDUMP_COMMANDLINE_APPEND参数
    local current_params=$(grep "^KDUMP_COMMANDLINE_APPEND=" /etc/sysconfig/kdump 2>/dev/null | cut -d'"' -f2)
    if [ -z "$current_params" ]; then
        echo_error "kdump参数未配置"
        echo_info "需要在 /etc/sysconfig/kdump 中配置 KDUMP_COMMANDLINE_APPEND"
        echo_info "参考参数: $kdump_required_params"
        return 1
    else
        echo_info "kdump参数已配置"
        return 0
    fi
}

# 检查crashkernel内存
check_crashkernel() {
    echo_blue "检查crashkernel内存配置..."

    # 检查dmesg中的crashkernel信息
    local crashkernel_info=$(dmesg 2>/dev/null | grep -i "crashkernel=" | head -1)

    if [ -z "$crashkernel_info" ]; then
        echo_error "未找到crashkernel配置"
        echo_info "需要在 /etc/default/grub 中配置 crashkernel=4096M,high"
        echo_info "然后重新生成grub配置并重启"
        return 1
    fi

    # 检查crashkernel大小
    if [[ "$crashkernel_info" =~ crashkernel=([0-9]+M|[0-9]+G) ]]; then
        local crash_size="${BASH_REMATCH[1]}"
        echo_info "crashkernel配置: $crash_size"
        echo_info "完整配置: $crashkernel_info"

        # 使用kdumpctl检查内存
        if command -v kdumpctl &>/dev/null; then
            local reserved_mem=$(kdumpctl showmem 2>/dev/null)
            if [ -n "$reserved_mem" ]; then
                echo_info "保留内存: $reserved_mem"
            fi
        fi
        return 0
    else
        echo_error "crashkernel配置格式不正确"
        return 1
    fi
}

# 检查麒麟ARM系统的bpf_jit参数（麒麟系统特有）
check_kylin_bpf_jit() {
    echo_blue "检查麒麟系统bpf_jit参数..."

    detect_os

    # 只在麒麟系统上检查
    if [ "$OS_TYPE" != "kylin" ]; then
        echo_info "非麒麟系统，跳过bpf_jit检查"
        return 0
    fi

    # 检查是否为ARM架构
    local arch=$(uname -m)
    if [ "$arch" != "aarch64" ]; then
        echo_info "非ARM架构，跳过bpf_jit检查"
        return 0
    fi

    # 检查bpf_jit_enable
    local bpf_jit_enable=0
    if [ -f /proc/sys/net/core/bpf_jit_enable ]; then
        bpf_jit_enable=$(cat /proc/sys/net/core/bpf_jit_enable)
    fi

    # 检查bpf_jit_limit
    local bpf_jit_limit=0
    if [ -f /proc/sys/net/core/bpf_jit_limit ]; then
        bpf_jit_limit=$(cat /proc/sys/net/core/bpf_jit_limit)
    fi

    # 检查已使用的bpf_jit内存
    local bpf_jit_used=0
    if [ -f /proc/vmallocinfo ]; then
        bpf_jit_used=$(cat /proc/vmallocinfo | grep bpf_jit | awk '{s+=$2} END {print s}')
    fi

    echo_info "bpf_jit_enable: $bpf_jit_enable"
    echo_info "bpf_jit_limit: $bpf_jit_limit"
    echo_info "bpf_jit已使用: $bpf_jit_used"

    # 检查是否需要调整
    if [ $bpf_jit_limit -lt 264241152 ]; then
        echo_warn "bpf_jit_limit过小，建议调整为 264241152"
        echo_info "修改 /etc/sysctl.conf: net.core.bpf_jit_limit = 264241152"
        return 1
    else
        echo_info "bpf_jit参数配置正常"
        return 0
    fi
}

# 检查裸盘LVM挂载
check_lvm_mount() {
    echo_blue "检查裸盘LVM挂载配置..."

    # 获取所有磁盘
    local all_disks=$(lsblk -d -o NAME -n | grep -v 'sr')

    local raw_disk_count=0
    local lvm_disk_count=0
    local non_lvm_mounted=0

    for disk in $all_disks; do
        # 检查磁盘是否有分区或直接挂载
        local disk_info=$(lsblk -d -o NAME,TYPE,MOUNTPOINT -n "/dev/$disk")

        if echo "$disk_info" | grep -q 'disk'; then
            # 检查是否有LVM卷
            if lsblk "/dev/$disk" | grep -q 'LVM'; then
                ((lvm_disk_count++))
            elif lsblk "/dev/$disk" | grep -q 'part'; then
                # 有分区
                ((raw_disk_count++))
            else
                # 纯裸盘
                ((raw_disk_count++))
                if echo "$disk_info" | grep -q '/'; then
                    ((non_lvm_mounted++))
                fi
            fi
        fi
    done

    echo_info "使用LVM的磁盘数: $lvm_disk_count"
    echo_info "裸盘数（含分区）: $raw_disk_count"
    echo_info "非LVM挂载的磁盘: $non_lvm_mounted"

    if [ $non_lvm_mounted -gt 0 ]; then
        echo_warn "存在非LVM挂载的磁盘"
        echo_info "LVM挂载优点: 后期扩容方便"
        echo_info "裸盘挂载优点: 单盘故障影响范围小"
        echo_info "请与客户确认挂载方式"
        return 1
    else
        echo_info "磁盘挂载方式已确认"
        return 0
    fi
}
