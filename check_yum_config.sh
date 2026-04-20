#!/bin/bash

NODES_FILE="/root/zpy/nodes_temp.conf"

check_yum_config() {
    local ip=$1
    local hostname=$2
    local password=$3

    echo "=========================================="
    echo "节点: $ip ($hostname) - YUM源配置详情"
    echo "=========================================="

    /usr/bin/expect << EOF
set timeout 10
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$ip
expect "password:"
send "$password\r"
expect -re {#|\$}
    send "cat /etc/yum.repos.d/kylin_x86_64.repo\r"
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
    check_yum_config "$ip" "$hostname" "$password"
done < "$NODES_FILE"
