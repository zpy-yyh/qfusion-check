#!/bin/bash

NODES_FILE="/root/zpy/nodes_temp.conf"
SCRIPT="/root/zpy/qfusion_package/qfusion.sh"
LOG_DIR="/root/zpy/yum_test_logs"
mkdir -p "$LOG_DIR"

echo "=========================================="
echo "测试修改后的YUM源检查功能"
echo "=========================================="

while read -r ip hostname role user password; do
    if [[ -z "$ip" ]] || [[ "$ip" =~ ^# ]]; then
        continue
    fi

    echo ""
    echo "=========================================="
    echo "节点: $ip ($hostname)"
    echo "=========================================="

    /usr/bin/expect << EOF
set timeout 60
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$ip
expect "password:"
send "$password\r"
expect -re {#|\$}

    send "echo '测试1: 网络检测 (ping baidu.com)'\r"
    expect -re {#|\$}
    send "ping -c 1 -W 2 baidu.com 2>&1 && echo '✓ 通外网' || echo '✗ 不通外网'\r"
    expect -re {#|\$}

    send "echo ''\r"
    expect -re {#|\$}
    send "echo '测试2: YUM makecache (30秒超时)'\r"
    expect -re {#|\$}
    send "timeout 30 yum makecache 2>&1 | tail -10\r"
    expect {
        timeout {
            send "\r"
            expect -re {#|\$}
        }
        -re {#|\$}
    }

    send "echo ''\r"
    expect -re {#|\$}
    send "echo '测试3: 运行修改后的YUM源检查函数'\r"
    expect -re {#|\$}
    send "bash $SCRIPT --check 2>&1 | grep -A 10 '检查YUM源配置'\r"
    expect {
        timeout {
            send "\r"
            expect -re {#|\$}
        }
        -re {#|\$}
    }

    send "exit\r"
    expect eof
EOF

done < "$NODES_FILE"

echo ""
echo "=========================================="
echo "测试完成！"
echo "=========================================="
