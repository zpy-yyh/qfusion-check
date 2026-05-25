# QFusion Ansible 项目

## 🎯 项目简介

这是QFusion安装前检查和初始化脚本的Ansible重构版本，替代原Bash脚本。

## ✨ 主要优势

| 特性 | Bash脚本 | Ansible |
|------|---------|---------|
| 幂等性 | ❌ | ✅ |
| 并行执行 | 需要实现 | ✅ 原生 |
| 可维护性 | 一般 | ✅ 优秀 |
| 版本控制 | 可行 | ✅ 优秀 |
| 标准化 | 不统一 | ✅ YAML |
| 扩展性 | 一般 | ✅ 模块化 |

## 📁 项目结构

```
ansible-qfusion/
├── ansible.cfg              # Ansible配置文件
├── ansible-playbook-wrapper.sh  # 交互式包装脚本 ⭐
├── README.md                # 本文件
├── MIGRATION_GUIDE.md      # 迁移指南
├── QUICK_REFERENCE.md       # 快速参考
├── PROJECT_SUMMARY.md       # 项目摘要
├── inventory/
│   └── hosts.yml           # 节点清单
├── group_vars/
│   └── all.yml             # 全局变量
├── playbooks/
│   ├── check_only.yml      # 只检查（不修改）
│   ├── fix_and_check.yml   # 检查并修复
│   └── remote_init.yml     # 远程初始化
└── roles/
    └── qfusion_check/
        ├── tasks/
        │   ├── main.yml    # 检查任务（25项）
        │   └── fix.yml     # 修复任务（25项）
        ├── handlers/
        │   └── main.yml    # 处理程序
        └── vars/
            └── main.yml    # 角色变量
```

## 🚀 快速开始

### 1. 安装Ansible

```bash
yum install -y ansible
ansible --version
```

### 2. 配置节点清单

编辑 `inventory/hosts.yml`:

```yaml
qfusion_masters:
  hosts:
    master1:
      ansible_host: 192.168.1.97
      ansible_user: root
      ansible_ssh_private_key_file: /root/.ssh/id_rsa

qfusion_workers:
  hosts:
    worker1:
      ansible_host: 192.168.1.87
      ansible_user: root
```

### 3. 配置SSH免密登录

```bash
ssh-copy-id root@192.168.1.97
ssh-copy-id root@192.168.1.98
ssh-copy-id root@192.168.1.87
```

### 4. 测试连接

```bash
ansible -i inventory/hosts.yml qfusion_cluster -m ping
```

### 5. 运行检查

**使用包装脚本（推荐）**:
```bash
./ansible-playbook-wrapper.sh          # 交互式菜单
./ansible-playbook-wrapper.sh --check   # 只检查
./ansible-playbook-wrapper.sh --fix     # 检查并修复
./ansible-playbook-wrapper.sh --init    # 远程初始化
```

**直接使用ansible-playbook**:
```bash
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml
ansible-playbook -i inventory/hosts.yml playbooks/fix_and_check.yml
ansible-playbook -i inventory/hosts.yml playbooks/remote_init.yml
```

## 📋 Playbook说明

| Playbook | 功能 | 修改系统 | 适用场景 |
|----------|------|---------|---------|
| `check_only.yml` | 只执行检查 | ❌ 否 | 日常巡检、预检查 |
| `fix_and_check.yml` | 检查并自动修复 | ✅ 是 | 系统准备、自动化配置 |
| `remote_init.yml` | 完整远程初始化 | ✅ 是 | 新节点部署、批量初始化 |

## 🔧 检查项清单（25项）

### 系统环境（3项）
1. ✅ 操作系统检测
2. ✅ 内核版本检查
3. ✅ 主机名格式验证

### 网络配置（5项）
4. ✅ 网卡速率检查
5. ✅ DNS配置
6. ✅ NetworkManager
7. ✅ IPv6状态
8. ✅ iptables状态

### 存储配置（4项）
9. ✅ Swap分区
10. ✅ I/O调度算法
11. ✅ lsblk与fstab匹配
12. ✅ 裸盘LVM挂载

### 系统服务（5项）
13. ✅ SELinux
14. ✅ Auditd
15. ✅ kdump
16. ✅ crashkernel
17. ✅ virbr0网卡

### 软件包（3项）
18. ✅ YUM源配置
19. ✅ 必需软件包
20. ✅ 容器软件冲突

### 系统资源（4项）
21. ✅ 硬件时间同步
22. ✅ /tmp目录权限
23. ✅ 用户资源限制
24. ✅ CPU AVX指令集

### 麒麟系统特有（1项）
25. ✅ bpf_jit（麒麟ARM）

## ⚙️ 配置变量

编辑 `group_vars/all.yml` 自定义配置：

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
  auditd_enabled: false
  tmp_dir_perms: "1777"

# kdump配置
kdump:
  enabled: false
  crashkernel: "4096M,high"
```

## 📊 检查报告

报告位置：`/tmp/qfusion_ansible_reports/`

查看报告：
```bash
./ansible-playbook-wrapper.sh --report
# 或
cat /tmp/qfusion_ansible_reports/*_check_report.txt
```

## 🔗 相关文档

- [README.md](./README.md) - 本文件
- [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) - 从Bash迁移到Ansible
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - 快速参考手册
- [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md) - 项目摘要
- [../../README.md](../../README.md) - 项目总览

## ⚠️ 注意事项

1. **SSH密钥认证**：推荐使用SSH密钥，不推荐密码认证
2. **生产环境**：使用前先在测试环境验证
3. **修复模式**：`fix_and_check.yml` 会修改系统配置
4. **重启需求**：修改SELinux或grub后需要重启

## 🆚 与Bash脚本对应关系

| 原Bash脚本 | Ansible命令 |
|-----------|-------------|
| `qfusion.sh --check` | `./ansible-playbook-wrapper.sh --check` |
| `qfusion.sh --remote-init` | `./ansible-playbook-wrapper.sh --init` |
| `qfusion.sh`（菜单） | `./ansible-playbook-wrapper.sh` |

## 📝 命令参考

### Ansible常用命令

```bash
# 查看节点信息
ansible -i inventory/hosts.yml all -m setup | less

# 执行命令
ansible -i inventory/hosts.yml all -m shell -a "uptime"

# 使用详细输出
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml -vvv

# 限制目标节点
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml --limit master1

# 预览修改（不实际执行）
ansible-playbook playbooks/fix_and_check.yml --check

# 使用标签
ansible-playbook playbooks/fix_and_check.yml --tags fix
```

## 📚 学习资源

- Ansible官方文档: https://docs.ansible.com/
- Ansible最佳实践: https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html
- QFusion Bash脚本: `../../qfusion_package/qfusion.sh`

## 🤝 贡献

欢迎提交Issue和Pull Request来扩展功能。

## 📅 版本历史

- **v1.0.0** (2026-04-03): 初始版本
  - 支持25个检查项
  - 3个主要playbooks
  - 完整的文档体系
  - 交互式包装脚本

## 📞 技术支持

如有问题，请参考文档或联系QFusion项目组。
