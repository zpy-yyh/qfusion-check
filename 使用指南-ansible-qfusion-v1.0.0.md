# QFusion Ansible v1.0.0 使用指��

## 📦 打包文件

**文件**: `ansible-qfusion-v1.0.0.tar.gz`
**大小**: 22KB
**位置**: `/root/zpy/`

---

## 🚀 5分钟快速上手

### 步骤1: 传输文件（30秒）

```bash
# 从本机传输到目标服务器
scp /root/zpy/ansible-qfusion-v1.0.0.tar.gz user@server:/tmp/
```

### 步骤2: 解压（30秒）

```bash
# 在目标服务器上
cd /tmp
tar -xzf ansible-qfusion-v1.0.0.tar.gz
cd ansible-qfusion
```

### 步骤3: 安装依赖（2分钟）

```bash
# 安装Ansible
yum install -y epel-release
yum install -y ansible

# 验证安装
ansible --version
```

### 步骤4: 配置SSH（1分钟）

```bash
# 生成SSH密钥
ssh-keygen -t rsa -b 2048 -N ""

# 复制到目标节点
ssh-copy-id root@10.10.156.97
```

### 步骤5: 配置节点（30秒）

```bash
# 编辑节点清单
vi inventory/hosts.yml

# 添加节点信息
qfusion_masters:
  hosts:
    master1:
      ansible_host: 10.10.156.97
      ansible_user: root
```

### 步骤6: 运行检查（30秒）

```bash
# 运行检查
chmod +x ansible-playbook-wrapper.sh
./ansible-playbook-wrapper.sh --check
```

---

## 📋 包含文件清单

```
ansible-qfusion/
├── ansible.cfg                      # Ansible配置
├── ansible-playbook-wrapper.sh       # 交互式脚本 ⭐
├── VERSION.txt                       # 版本信息
├── INSTALL.md                        # 安装说明
├── QUICK_START.md                    # 快速开始
├── README.md                         # 项目总览
├── MIGRATION_GUIDE.md               # 迁移指南
├── QUICK_REFERENCE.md               # 快速参考
├── PROJECT_SUMMARY.md               # 项目摘要
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
        │   ├── main.yml            # 25个检查任务
        │   └── fix.yml             # 25个修复任务
        ├── handlers/
        │   └── main.yml            # 处理程序
        └── vars/
            └── main.yml            # 角色变量
```

---

## 🎯 常用命令

### 交互式模式

```bash
# 显示菜单
./ansible-playbook-wrapper.sh

# 只检查（不修改）
./ansible-playbook-wrapper.sh --check

# 检查并修复
./ansible-playbook-wrapper.sh --fix

# 远程初始化
./ansible-playbook-wrapper.sh --init

# 测试连接
./ansible-playbook-wrapper.sh --test

# 查看报告
./ansible-playbook-wrapper.sh --report
```

### 直接使用Ansible

```bash
# 只检查
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml

# 检查并修复
ansible-playbook -i inventory/hosts.yml playbooks/fix_and_check.yml

# 远程初始化
ansible-playbook -i inventory/hosts.yml playbooks/remote_init.yml

# 使用详细输出
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml -vvv

# 限制目标节点
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml --limit master1
```

---

## 📊 支持的检查项（25项）

| 分类 | 检查项 | 说明 |
|------|--------|------|
| 系统环境 | 操作系统检测 | RedHat/CentOS/麒麟 |
| | 内核版本检查 | 要求 > 4.19 |
| | 主机名格式 | 验证FQDN格式 |
| 网络配置 | 网卡速率 | 最低1000 Mbps |
| | DNS配置 | 可自定义DNS服务器 |
| | NetworkManager | 检查服务状态 |
| | IPv6 | 检查和配置状态 |
| | iptables | 检查防火墙状态 |
| 存储配置 | Swap分区 | 检查和可选禁用 |
| | I/O调度算法 | 检查deadline调度 |
| | lsblk与fstab | 验证设备匹配 |
| | 裸盘LVM挂载 | 检查挂载方式 |
| 系统服务 | SELinux | 检查和配置状态 |
| | Auditd | 检查服务状态 |
| | kdump | 检查参数配置 |
| | crashkernel | 检查内存保留 |
| | virbr0网卡 | 检查和可选禁用 |
| 软件包 | YUM源 | 检查和配置 |
| | 必需软件包 | 检查安装状态 |
| | 容器软件冲突 | 检测docker等 |
| 系统资源 | 硬件时间同步 | 检查hwclock |
| | /tmp目录权限 | 检查1777权限 |
| | 用户资源限制 | 检查ulimit |
| | CPU AVX指令集 | 检查AVX支持 |
| 麒麟系统 | bpf_jit | 麒麟ARM特有检查 |

---

## ⚙️ 配置说明

### 修改网络配置

编辑 `group_vars/all.yml`：

```yaml
network:
  min_nic_speed: 1000              # 最低网卡速率（Mbps）
  dns_servers:                     # DNS服务器列表
    - "114.114.114.114"
    - "8.8.8.8"
  disable_ipv6: false              # 是否禁用IPv6
  stop_iptables: false             # 是否停止iptables
```

### 修改系统配置

```yaml
system:
  selinux_state: "disabled"        # SELinux状态
  auditd_enabled: false            # 是否启用auditd
  swap_enabled: false              # 是否启用swap
  tmp_dir_perms: "1777"            # /tmp目录权限
  disable_virbr0: true             # 是否禁用virbr0
```

### 修改kdump配置

```yaml
kdump:
  enabled: false                   # 是否启用kdump
  crashkernel: "4096M,high"        # crashkernel参数
```

### 修改麒麟系统配置

```yaml
kylin:
  bpf_jit_limit: 264241152         # bpf_jit限制（麒麟ARM）
```

---

## 📖 查看文档

### 安装说明

```bash
cat INSTALL.md
```

内容包括：
- 详细的安装步骤
- 系统要求说明
- 配置方法
- 故障排查

### 快速开始

```bash
cat QUICK_START.md
```

内容包括：
- 5分钟快速上手
- 常用命令
- 使用场景

### 快速参考

```bash
cat QUICK_REFERENCE.md
```

内容包括：
- 命令参考
- 变量配置
- 故障排查
- 最佳实践

### 迁移指南

```bash
cat MIGRATION_GUIDE.md
```

内容包括：
- 从Bash脚本迁移
- 功能对比
- 命令对照
- 依赖变化

---

## 📝 检查报告

### 报告位置

```
/tmp/qfusion_ansible_reports/
├── master1_check_report.txt
├── master2_check_report.txt
└── worker1_check_report.txt
```

### 查看报告

```bash
# 使用包装脚本
./ansible-playbook-wrapper.sh --report

# 或直接查看
cat /tmp/qfusion_ansible_reports/*_check_report.txt
```

### 报告格式

```
# QFusion Ansible 检查报告
# 生成时间: 2026-04-03 15:00:00
# 主机: master1
# 操作系统: CentOS Linux 7.9
# 内核: 3.10.0-1160.el7.x86_64
# 架构: x86_64

## 检查项汇总

✓ 操作系统: CentOS Linux 7.9 (centos)
✓ 内核版本: 3.10.0-1160.el7.x86_64 (要求: >= 4.19)
⚠ YUM源: 3 个仓库文件
✓ 硬件时间同步: hwclock可用
✓ 网卡速率: 最低 1000 Mbps
✓ DNS配置: 114.114.114.114
✓ NetworkManager: active
✓ SELinux: disabled
...
```

---

## ⚠️ 注意事项

### 安全建议

1. **使用SSH密钥**：推荐使用SSH密钥认证
2. **测试环境**：生产环境使用前先测试
3. **备份配置**：执行修复前备份重要文件
4. **权限控制**：使用适当的sudo权限

### 使用建议

1. **只检查模式**：`check_only.yml` 不会修改系统
2. **修复模式**：`fix_and_check.yml` 会修改系统配置
3. **重启需求**：修改SELinux或grub后需要重启
4. **定期清理**：定期清理检查报告和临时文件

---

## 🔍 故障排查

### 连接失败

```bash
# 检查SSH连接
ssh root@10.10.156.97

# 使用详细模式
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml -vvv
```

### 权限问题

```bash
# 检查sudo权限
ansible all -i inventory/hosts.yml -m shell -a "whoami" -b
```

### Python问题

```bash
# 检查Python版本
ansible all -i inventory/hosts.yml -m shell -a "python --version"

# 安装Python
ansible all -i inventory/hosts.yml -m yum -a "name=python3 state=present" -b
```

---

## 📞 技术支持

### 文档资源

- `README.md` - 项目总览
- `INSTALL.md` - 安装说明
- `QUICK_START.md` - 快速开始
- `QUICK_REFERENCE.md` - 快速参考

### 在线资源

- Ansible官方文档: https://docs.ansible.com/
- QFusion项目: `/root/zpy/qfusion_package/`

---

## 📅 版本信息

- **版本**: v1.0.0
- **打包时间**: 2026-04-03
- **Ansible要求**: 2.9+
- **Python要求**: 3.6+（控制节点）
- **支持系统**: RedHat 7.8/7.9, CentOS 7.x, 麒麟V10 SP3

---

**祝您使用愉快！**

如有问题，请参考相关文档或联系技术支持。
