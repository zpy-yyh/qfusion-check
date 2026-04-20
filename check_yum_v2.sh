#!/bin/bash

NODES_FILE="/root/zpy/nodes_temp.conf"

check_yum_v2() {
    local ip=$1
    local hostname=$2
    local password=$3

    echo "=========================================="
    echo "节点: $ip ($hostname) - 详细YUM源检查"
    echo "=========================================="

    /usr/bin/expect << EOF
set timeout 20
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$ip
expect "password:"
send "$password\r"
expect -re {#|\$}

    # 1. 检查外网连通性（用baidu.com）
    send "echo '=== 外网连通性检查 (ping baidu.com) ==='\r"
    expect -re {#|\$}
    send "ping -c 1 -W 2 baidu.com 2>&1 && echo '外网: 通' || echo '外网: 不通'\r"
    expect -re {#|\$}

    # 2. 测试YUM源可用性（下载一个小软件包）
    send "echo '=== YUM源可用性测试 (下载expect) ==='\r"
    expect -re {#|\$}
    send "yum clean all 2>&1 | head -5\r"
    expect -re {#|\$}
    send "yum makecache 2>&1 | tail -5\r"
    expect -re {#|\$}
    send "yum list installed expect 2>&1 || echo 'expect未安装'\r"
    expect -re {#|\$}
    send "yum install -y expect 2>&1 && echo 'expect安装成功' || echo 'expect安装失败'\r"
    expect {
        timeout {
            send "\r"
            expect -re {#|\$}
        }
        -re {#|\$}
    }

    # 3. 查看YUM源URL
    send "echo '=== YUM源URL ==='\r"
    expect -re {#|\$}
    send "grep '^baseurl' /etc/yum.repos.d/*.repo 2>&1\r"
    expect -re {#|\$}

    send "exit\r"
    expect eof
EOF

    echo ""
}

while read -r ip hostname role user password; do
    if [[ -z "$ip" ]] || [[ "$ip" =~ ^# ]]; then
        continue
    fi
    check_yum_v2 "$ip" "$hostname" "$password"
done < "$NODES_FILE"
