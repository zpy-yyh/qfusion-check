# QFusion Ansible 快速参考

## 项目结构

```
ansible-qfusion/
├── ansible.cfg                      # Ansible配置
├── ansible-playbook-wrapper.sh       # 交互式包装脚本
├── README.md                        # 项目文档
├── MIGRATION_GUIDE.md              # 迁移指南
├── QUICK_REFERENCE.md               # 本文件
├── inventory/
│   └── hosts.yml                    # 节点清单
├── group_vars/
│   └── all.yml                      # 全局变量
├── playbooks/
│   ├── check_only.yml               # 只检查
│   ├── fix_and_check.yml           # 检查并修复
│   └── remote_init.yml              # 远程初始化
└── roles/
    └── qfusion_check/
        ├── tasks/
        │   ├── main.yml            # 检查任务
        │   └── fix.yml             # 修复任务
        ├── handlers/
        │   └── main.yml            # 处理程序
        └── vars/
            └── main.yml            # 角色变量
```

## 快速开始

### 1. 安装Ansible

```bash
# CentOS/RHEL
yum install -y ansible

# 验证安装
ansible --version
```

### 2. 配置节点清单

编辑 `inventory/hosts.yml`：

```yaml
qfusion_masters:
  hosts:
    master1:
      ansible_host: 192.168.1.97
      ansible_user: root
      ansible_ssh_private_key_file: /root/.ssh/id_rsa
```

### 3. 配置SSH免密登录

```bash
# 生成密钥
ssh-keygen -t rsa -b 2048 -N ""

# 复制到目标节点
ssh-copy-id root@192.168.1.97
ssh-copy-id root@192.168.1.98
ssh-copy-id root@192.168.1.87
```

### 4. 测试连接

```bash
ansible -i inventory/hosts.yml qfusion_cluster -m ping
```

### 5. 运行检查

```bash
# 使用包装脚本（推荐）
./ansible-playbook-wrapper.sh --check

# 或直接使用ansible-playbook
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml
```

## 命令参考

### 包装脚本命令

```bash
# 交互式菜单
./ansible-playbook-wrapper.sh

# 只检查（不修改）
./ansible-playbook-wrapper.sh --check

# 检查并修复
./ansible-playbook-wrapper.sh --fix

# 远程初始化
./ansible-playbook-wrapper.sh --init

# 测试连接
./ansible-playbook-wrapper.sh --test

# 编辑节点清单
./ansible-playbook-wrapper.sh --edit

# 查看报告
./ansible-playbook-wrapper.sh --report

# 显示帮助
./ansible-playbook-wrapper.sh --help
```

### 直接使用Ansible

```bash
# 查看节点信息
ansible -i inventory/hosts.yml all -m setup | less

# 在节点上执行命令
ansible -i inventory/hosts.yml all -m shell -a "uptime"

# 只在master节点执行
ansible -i inventory/hosts.yml qfusion_masters -m shell -a "free -h"

# 使用详细输出
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml -vvv

# 指定节点
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml --limit master1

# 使用tag
ansible-playbook -i inventory/hosts.yml playbooks/fix_and_check.yml --tags fix
```

## Playbook功能对比

| Playbook | 功能 | 修改系统 | 适用场景 |
|----------|------|---------|---------|
| check_only.yml | 只检查 | ❌ 否 | 日常巡检、预检查 |
| fix_and_check.yml | 检查并修复 | ✅ 是 | 系统准备、自动化配置 |
| remote_init.yml | 完整初始化 | ✅ 是 | 新节点部署、批量初始化 |

## 检查项列表

### 系统环境
1. ✅ 操作系统检测
2. ✅ 内核版本检查
3. ✅ 主机名格式

### 网络配置
4. ✅ 网卡速率检查
5. ✅ DNS配置
6. ✅ NetworkManager
7. ✅ IPv6状态
8. ✅ iptables状态

### 存储配置
9. ✅ Swap分区
10. ✅ I/O调度算法
11. ✅ lsblk与fstab匹配
12. ✅ 裸盘LVM挂载

### 系统服务
13. ✅ SELinux
14. ✅ Auditd
15. ✅ kdump
16. ✅ crashkernel
17. ✅ virbr0网卡

### 软件包
18. ✅ YUM源配置
19. ✅ 必需软件包
20. ✅ 容器软件冲突

### 系统资源
21. ✅ 硬件时间同步
22. ✅ /tmp目录权限
23. ✅ 用户资源限制
24. ✅ CPU AVX指令集

### 麒麟系统特有
25. ✅ bpf_jit（麒麟ARM）

## 变量配置

### 关键变量位置

`group_vars/all.yml` 中的主要变量：

```yaml
# 网络配置
network:
  min_nic_speed: 1000
  dns_servers: ["114.114.114.114", "8.8.8.8"]
  disable_ipv6: false

# 系统配置
system:
  selinux_state: "disabled"
  auditd_enabled: false
  tmp_dir_perms: "1777"

# 硬件配置
hardware:
  sync_hwclock: true
  swap_enabled: false
  io_scheduler: "deadline"

# kdump配置
kdump:
  enabled: false
  crashkernel: "4096M,high"

# 麒麟系统
kylin:
  bpf_jit_limit: 264241152
```

### 节点特定变量

在 `inventory/hosts.yml` 中：

```yaml
[qfusion_masters:vars]
node_role: master
some_specific_var: value

[qfusion_workers:vars]
node_role: worker
```

## 报告查看

### 报告位置

- 控制台输出：实时显示
- 文件报告：`/tmp/qfusion_ansible_reports/主机名_check_report.txt`
- 初始化摘要：各节点的 `/tmp/qfusion_init_summary.txt`

### 查看报告

```bash
# 使用包装脚本
./ansible-playbook-wrapper.sh --report

# 或直接查看
cat /tmp/qfusion_ansible_reports/*_check_report.txt

# 查看特定节点
cat /tmp/qfusion_ansible_reports/master1_check_report.txt
```

## 故障排查

### 连接问题

```bash
# 检查SSH连接
ssh root@192.168.1.97

# 使用详细模式
ansible -i inventory/hosts.yml all -m ping -vvv

# 检查Ansible配置
ansible --version
```

### 权限问题

```bash
# 检查sudo权限
ansible all -i inventory/hosts.yml -m shell -a "whoami" -b

# 检查become权限
ansible all -i inventory/hosts.yml -m shell -a "sudo whoami"
```

### 模块问题

```bash
# 检查目标节点Python
ansible all -i inventory/hosts.yml -m shell -a "python --version"

# 安装Python（如果需要）
ansible all -i inventory/hosts.yml -m yum -a "name=python3 state=present" -b
```

## 最佳实践

### 1. 使用SSH密钥认证

```bash
# 推荐
ansible_ssh_private_key_file: /root/.ssh/id_rsa

# 不推荐（仅测试环境）
ansible_ssh_pass: "password"
```

### 2. 使用标签

```bash
# 只运行检查
ansible-playbook playbooks/fix_and_check.yml --tags check

# 只运行修复
ansible-playbook playbooks/fix_and_check.yml --tags fix
```

### 3. 限制目标

```bash
# 只在master节点
ansible-playbook playbooks/check_only.yml --limit qfusion_masters

# 只在特定节点
ansible-playbook playbooks/check_only.yml --limit master1
```

### 4. 使用检查模式

```bash
# 预览修改，不实际执行
ansible-playbook playbooks/fix_and_check.yml --check
```

### 5. 并行执行

```bash
# 在ansible.cfg中设置
forks = 20

# 或命令行指定
ansible-playbook playbooks/check_only.yml --forks 10
```

## 与原Bash脚本对应关系

| 原脚本命令 | Ansible命令 |
|-----------|-------------|
| `qfusion.sh --check` | `ansible-playbook playbooks/check_only.yml` |
| `qfusion.sh --remote-init` | `ansible-playbook playbooks/remote_init.yml` |
| `qfusion.sh`（菜单） | `./ansible-playbook-wrapper.sh` |

## 扩展开发

### 添加新检查项

1. 在 `roles/qfusion_check/tasks/main.yml` 中添加任务
2. 添加报告输出
3. 更新本文档

### 添加新修复项

1. 在 `roles/qfusion_check/tasks/fix.yml` 中添加任务
2. 添加条件判断
3. 测试修复逻辑

### 添加新Playbook

1. 在 `playbooks/` 目录创建新文件
2. 引用需要的roles
3. 更新包装脚本菜单

## 性能优化

### 1. 启用pipelining

在 `ansible.cfg` 中：
```ini
[ssh_connection]
pipelining = True
```

### 2. 增加并发数

在 `ansible.cfg` 中：
```ini
[defaults]
forks = 20
```

### 3. 禁用facts收集（如果不需要）

```bash
ansible-playbook playbooks/check_only.yml --gather-facts no
```

## 安全建议

1. **使用SSH密钥认证**，不要使用密码
2. **限制become权限**，只给必要的权限
3. **使用vault**加密敏感变量：
   ```bash
   ansible-vault encrypt group_vars/vault.yml
   ```
4. **定期更新Ansible**
5. **审查playbook内容**，确保没有恶意代码

## 获取帮助

- 项目文档：`README.md`
- 迁移指南：`MIGRATION_GUIDE.md`
- Ansible官方文档：https://docs.ansible.com/
- QFusion原脚本：`/opt/qfusion-check/qfusion_package/qfusion.sh`

## 版本信息

- 版本：1.0.0
- 日期：2026-04-03
- 基于原Bash脚本重构
- 支持25个检查项
