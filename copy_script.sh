#!/bin/bash

NODES_FILE="/root/zpy/nodes_temp.conf"
SCRIPT="/root/zpy/qfusion_package/qfusion.sh"

echo "=========================================="
echo "复制修改后的脚本到集群节点"
echo "=========================================="

while read -r ip hostname role user password; do
    if [[ -z "$ip" ]] || [[ "$ip" =~ ^# ]]; then
        continue
    fi

    echo ""
    echo "复制到: $ip ($hostname)"

    /usr/bin/expect << EOF
set timeout 30
spawn scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SCRIPT root@$ip:/tmp/qfusion.sh
expect {
    "password:" {
        send "$password\r"
        expect eof
    }
    eof
}
EOF

    # 使用expect远程执行命令移动文件并测试
    /usr/bin/expect << EOF
set timeout 30
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$ip
expect "password:"
send "$password\r"
expect -re {#|\$}

    send "mkdir -p /root/zpy/qfusion_package\r"
    expect -re {#|\$}
    send "mv /tmp/qfusion.sh /root/zpy/qfusion_package/qfusion.sh\r"
    expect -re {#|\$}
    send "chmod +x /root/zpy/qfusion_package/qfusion.sh\r"
    expect -re {#|\$}

    send "echo '运行YUM源检查...' && bash /root/zpy/qfusion_package/qfusion.sh --check 2>&1 | head -40\r"
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
echo "复制和测试完成！"
echo "=========================================="
