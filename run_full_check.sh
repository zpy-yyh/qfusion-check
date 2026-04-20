#!/bin/bash

NODES_FILE="/root/zpy/nodes_temp.conf"

while read -r ip hostname role user password; do
    if [[ -z "$ip" ]] || [[ "$ip" =~ ^# ]]; then
        continue
    fi

    echo "=========================================="
    echo "节点: $ip ($hostname)"
    echo "=========================================="

    /usr/bin/expect << EOF
set timeout 120
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$ip
expect "password:"
send "$password\r"
expect -re {#|\$}

    send "bash /root/zpy/qfusion_package/qfusion.sh --check 2>&1 | head -50\r"
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

    echo ""

done < "$NODES_FILE"
