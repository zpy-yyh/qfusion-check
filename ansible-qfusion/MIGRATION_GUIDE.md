# QFusion Ansible 迁移指南

## 概述

本文档说明如何从原Bash脚本 `qfusion_package/qfusion.sh` 迁移到Ansible版本。

## 功能对比

| 功能 | Bash脚本 | Ansible | 说明 |
|------|---------|---------|------|
| 操作系统检测 | ✅ | ✅ | 支持RedHat 7.8/7.9, CentOS 7.x, 麒麟V10 SP3 |
| 内核版本检查 | ✅ | ✅ | 要求 > 4.19 |
| YUM源配置 | ✅ | ✅ | 自动检测并配置 |
| 硬件时间同步 | ✅ | ✅ | 检查hwclock |
| 网卡速率检查 | ✅ | ✅ | 最低1000 Mbps |
| DNS配置 | ✅ | ✅ | 支持自定义DNS服务器 |
| NetworkManager | ✅ | ✅ | 检查服务状态 |
| Swap分区 | ✅ | ✅ | 检查并可选禁用 |
| SELinux | ✅ | ✅ | 检查并配置 |
| I/O调度算法 | ✅ | ✅ | 检查deadline调度 |
| Auditd | ✅ | ✅ | 检查服务状态 |
| 主机名格式 | ✅ | ✅ | 验证FQDN格式 |
| 必需软件包 | ✅ | ✅ | 检查并安装 |
| 容器软件冲突 | ✅ | ✅ | 检测docker等 |
| /tmp目录权限 | ✅ | ✅ | 检查1777权限 |
| virbr0网卡 | ✅ | ✅ | 检查并可选禁用 |
| CPU AVX指令集 | ✅ | ✅ | 检查AVX支持 |
| 用户资源限制 | ✅ | ✅ | 检查ulimit配置 |
| lsblk与fstab | ✅ | ✅ | 验证设备匹配 |
| IPv6状态 | ✅ | ✅ | 检查并可选禁用 |
| iptables | ✅ | ✅ | 检查服务状态 |
| kdump参数 | ✅ | ✅ | 检查配置 |
| crashkernel | ✅ | ✅ | 检查内存保留 |
| 裸盘LVM挂载 | ✅ | ✅ | 检查挂载方式 |
| 麒麟ARM bpf_jit | ✅ | ✅ | 麒麟ARM特有 |
| 远程批量部署 | ✅ | ✅ | 支持多节点 |
| SSH免密配置 | ✅ | ❌ | 需手动配置 |
| RAID配置 | ✅ | ⚠️ | 需手动配置或扩展 |
| 交互式菜单 | ✅ | ✅ | 通过包装脚本 |
| 彩色输出 | ✅ | ⚠️ | 支持但不完全相同 |

## 命令对比

### 原Bash脚本命令

```bash
# 只检查
bash qfusion_package/qfusion.sh --check

# 远程初始化
bash qfusion_package/qfusion.sh --remote-init

# 交互式菜单
bash qfusion_package/qfusion.sh
```

### Ansible命令

```bash
# 方式1: 使用包装脚本（推荐）
cd /opt/qfusion-check/ansible-qfusion
./ansible-playbook-wrapper.sh              # 交互式菜单
./ansible-playbook-wrapper.sh --check     # 只检查
./ansible-playbook-wrapper.sh --fix       # 检查并修复
./ansible-playbook-wrapper.sh --init      # 远程初始化

# 方式2: 直接使用ansible-playbook
cd /opt/qfusion-check/ansible-qfusion
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml
ansible-playbook -i inventory/hosts.yml playbooks/fix_and_check.yml
ansible-playbook -i inventory/hosts.yml playbooks/remote_init.yml
```

## 节点配置迁移

### 原Bash脚本配置格式

原脚本使用 `/opt/qfusion-check/qfusion_package/nodes.conf`，格式：
```
IP地址 主机名 角色 用户名 认证信息
```

示例：
```conf
192.168.1.97 rds001 master root your_password
192.168.1.98 rds002 master root your_password
192.168.1.87 rds004 worker root your_password
```

### Ansible配置格式

Ansible使用YAML格式的inventory文件 `inventory/hosts.yml`：

```yaml
qfusion_masters:
  hosts:
    master1:
      ansible_host: 192.168.1.97
      ansible_user: root
      # 密码认证（不推荐）
      # ansible_ssh_pass: "your_password"
      # SSH密钥认证（推荐）
      ansible_ssh_private_key_file: /root/.ssh/id_rsa
    master2:
      ansible_host: 192.168.1.98
      ansible_user: root

qfusion_workers:
  hosts:
    worker1:
      ansible_host: 192.168.1.87
      ansible_user: root
```

### 自动转换脚本

可以使用以下脚本自动转换：

```bash
#!/bin/bash

# nodes_conf_to_ansible_inventory.sh
# 转换 nodes.conf 到 Ansible inventory

INPUT_FILE="/opt/qfusion-check/qfusion_package/nodes.conf"
OUTPUT_FILE="/opt/qfusion-check/ansible-qfusion/inventory/hosts.yml"

echo "qfusion_masters:" > "$OUTPUT_FILE"
echo "  hosts:" >> "$OUTPUT_FILE"

while read -r line; do
    # 跳过空行和注释
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # 解析字段
    ip=$(echo "$line" | awk '{print $1}')
    hostname=$(echo "$line" | awk '{print $2}')
    role=$(echo "$line" | awk '{print $3}')
    user=$(echo "$line" | awk '{print $4}')
    auth=$(echo "$line" | awk '{print $5}')

    # 生成主机配置
    cat >> "$OUTPUT_FILE" << EOF
    ${hostname}:
      ansible_host: $ip
      ansible_user: $user
EOF

done < "$INPUT_FILE"

echo "转换完成: $OUTPUT_FILE"
```

## 配置变量迁移

### 原Bash脚本中的硬编码配置

原脚本中很多配置是硬编码的，例如：
- DNS服务器: 114.114.114.114, 8.8.8.8
- SELinux状态: disabled
- Swap: 禁用
- 等等

### Ansible中的变量配置

在Ansible中，所有配置都集中在 `group_vars/all.yml` 中：

```yaml
# 网络配置
network:
  min_nic_speed: 1000
  dns_servers:
    - "114.114.114.114"
    - "8.8.8.8"
  disable_ipv6: false

# 系统配置
system:
  selinux_state: "disabled"
  tmp_dir_perms: "1777"

# kdump配置
kdump:
  enabled: false
  crashkernel: "4096M,high"
```

可以根据需要修改这些变量。

## SSH认证迁移

### 原Bash脚本

原脚本支持：
1. 密码认证
2. SSH密钥认证
3. 使用expect脚本自动输入密码

### Ansible认证方式

Ansible推荐使用SSH密钥认证：

```bash
# 1. 生成密钥（如果没有）
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa

# 2. 复制公钥到目标节点
ssh-copy-id root@192.168.1.97
ssh-copy-id root@192.168.1.98
ssh-copy-id root@192.168.1.87

# 3. 测试连接
ssh root@192.168.1.97
```

如果必须使用密码，可以在inventory中配置：

```yaml
master1:
  ansible_host: 192.168.1.97
  ansible_user: root
  ansible_ssh_pass: "your_password"
```

**注意**: 密码认证不安全，仅限测试环境使用。

## 报告输出对比

### 原Bash脚本

- 控制台实时输出
- 使用颜色标记（✓/✗/⚠）
- 报告保存在 `/tmp/qfusion_check_results/`

### Ansible报告

- Ansible标准输出（可配置为YAML格式）
- 检查报告保存在 `/tmp/qfusion_ansible_reports/`
- 每个主机一个报告文件

查看报告：
```bash
# 使用包装脚本
./ansible-playbook-wrapper.sh --report

# 或直接查看
cat /tmp/qfusion_ansible_reports/*_check_report.txt
```

## 依赖对比

### 原Bash脚本依赖

- Bash
- 基础命令（ls, grep, awk, sed等）
- 可选: expect（用于密码认证）
- 可选: sshpass（用于密码认证）

### Ansible依赖

- 控制节点: Ansible 2.9+
- 控制节点: Python 3.6+
- 目标节点: Python 2.7+ 或 Python 3.5+
- 目标节点: Bash
- 目标节点: SSH

**重要**: Ansible不需要expect或sshpass！

## 优势对比

### Ansible的优势

1. **幂等性**: 重复执行不会产生副作用
2. **声明式**: 定义目标状态，Ansible负责实现
3. **标准化**: 使用YAML格式，易于阅读和维护
4. **模块化**: 使用roles，易于扩展和重用
5. **并发执行**: 默认并行在多个节点上执行
6. **更好的错误处理**: 失败时提供详细错误信息
7. **版本控制友好**: YAML格式适合Git管理
8. **社区支持**: 丰富的模块和文档

### 原Bash脚本的优势

1. **简单**: 只需要Bash，无需额外依赖
2. **交互式**: 更好的交互式菜单体验
3. **RAID配置**: 内置交互式RAID配置工具
4. **轻量级**: 脚本体积小，执行快

## 推荐迁移策略

### 阶段1: 评估和测试（1-2天）

1. 阅读本迁移指南
2. 在测试环境部署Ansible
3. 运行 `check_only.yml` 验证检查项
4. 对比原脚本和Ansible的输出

### 阶段2: 并行运行（1周）

1. 在测试环境同时运行原脚本和Ansible
2. 验证结果一致性
3. 调整Ansible配置以匹配原脚本行为

### 阶段3: 逐步迁移（2-4周）

1. 先迁移非关键环境的检查
2. 收集反馈，修复问题
3. 逐步扩大使用范围

### 阶段4: 完全迁移（持续）

1. 停止使用原Bash脚本
2. 完全使用Ansible
3. 根据需求扩展Ansible功能

## 已知差异和限制

1. **RAID配置**: Ansible版本暂不支持交互式RAID配置，需要手动配置或扩展
2. **SSH免密配置**: 需要手动配置，不包含在playbook中
3. **彩色输出**: Ansible的输出格式与原脚本不同
4. **expect脚本**: Ansible不需要expect，使用SSH密钥认证

## 回滚计划

如果需要回滚到原Bash脚本：

```bash
# 停止使用Ansible
cd /opt/qfusion-check/qfusion_package
bash qfusion.sh --check
```

## 常见问题

### Q: 是否可以同时使用Bash和Ansible版本？

A: 可以，但建议选择一个版本以避免混淆。Ansible更适合大规模部署。

### Q: Ansible版本缺少某些功能怎么办？

A: 可以扩展Ansible playbook或使用Bash脚本模块。欢迎提交issue或PR。

### Q: 如何处理RAID配置？

A: 目前需要手动配置。计划在后续版本中添加RAID配置支持。

### Q: Ansible需要学习成本吗？

A: 是的，但YAML语法简单，本迁移指南提供了详细的说明。

## 技术支持

如有问题，请联系：
- 原Bash脚本支持团队
- Ansible官方文档: https://docs.ansible.com/
- QFusion团队

## 版本历史

- v1.0 (2026-04-03): 初始版本，支持25个检查项
- v1.1 (计划): 添加RAID配置支持
- v1.2 (计划): 添加更多错误处理和日志
