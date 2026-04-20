#!/bin/bash

NODES_FILE="/root/zpy/nodes_temp.conf"
LOG_DIR="/root/zpy/yum_check_logs"
mkdir -p "$LOG_DIR"

check_yum_status() {
    local ip=$1
    local hostname=$2
    local password=$3

    echo "=========================================="
    echo "节点: $ip ($hostname)"
    echo "=========================================="

    # 使用expect执行远程命令
    /usr/bin/expect << EOF 2>&1 | tee "$LOG_DIR/${ip}_yum_check.log"
set timeout 20
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$ip

expect {
    "password:" {
        send "$password\r"
        expect {
            -re {#|\$} {
                # 1. 检查网络连通性
                send "echo '=== 网络连通性检查 ==='\r"
                expect -re {#|\$}
                send "ping -c 1 -W 2 114.114.114.114 2>&1 || echo '外网不通'\r"
                expect -re {#|\$}

                # 2. 检查YUM源配置文件
                send "echo '=== YUM源配置文件 ==='\r"
                expect -re {#|\$}
                send "ls -lh /etc/yum.repos.d/ 2>&1\r"
                expect -re {#|\$}

                # 3. 检查本地ISO挂载
                send "echo '=== 本地ISO挂载状态 ==='\r"
                expect -re {#|\$}
                send "mount | grep -E 'cdrom|iso' || echo '未挂载ISO'\r"
                expect -re {#|\$}

                # 4. 测试YUM makecache
                send "echo '=== YUM缓存测试 (15秒超时) ==='\r"
                expect -re {#|\$}
                send "timeout 15 yum makecache 2>&1 || echo 'YUM makecache失败'\r"
                expect {
                    timeout {
                        send "\r"
                        expect -re {#|\$}
                    }
                    -re {#|\$}
                }

                # 5. 显示YUM仓库列表
                send "echo '=== YUM仓库列表 ==='\r"
                expect -re {#|\$}
                send "yum repolist 2>&1\r"
                expect -re {#|\$}

                send "exit\r"
                expect eof
            }
        }
    }
    timeout {
        puts "\n连接超时"
        exit 1
    }
    eof {
        puts "\n连接结束"
    }
}
EOF

    echo ""
}

# 读取节点配置并检查
while read -r ip hostname role user password; do
    if [[ -z "$ip" ]] || [[ "$ip" =~ ^# ]]; then
        continue
    fi
    check_yum_status "$ip" "$hostname" "$password"
done < "$NODES_FILE"

echo ""
echo "=========================================="
echo "检查完成，日志保存在: $LOG_DIR"
echo "=========================================="
