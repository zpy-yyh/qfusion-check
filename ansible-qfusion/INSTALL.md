# QFusion Ansible 安装说明

## 📦 包内容

本包包含完整的QFusion Ansible自动化部署方案：

- `ansible.cfg` - Ansible配置文件
- `ansible-playbook-wrapper.sh` - 交互式包装脚本
- `inventory/` - 节点清单
- `group_vars/` - 全局变量
- `playbooks/` - 执行剧本
- `roles/` - Ansible角色
- `README.md` - 项目文档
- `VERSION.txt` - 版本信息

## 🚀 快速安装

### 1. 解压安装包

```bash
tar -xzf ansible-qfusion-v1.0.0.tar.gz
cd ansible-qfusion-v1.0.0
```

### 2. 安装依赖

#### 安装Ansible（控制节点）

```bash
# CentOS/RHEL 7.x/8.x
yum install -y epel-release
yum install -y ansible

# 或使用pip安装
pip3 install ansible

# 验证安装
ansible --version
```

#### 检查Python版本

```bash
# 控制节点需要Python 3.6+
python3 --version

# 目标节点支持Python 2.7+ 或 Python 3.5+
ansible all -i inventory/hosts.yml -m shell -a "python --version" --become
```

### 3. 配置节点清单

编辑 `inventory/hosts.yml`：

```yaml
qfusion_masters:
  hosts:
    master1:
      ansible_host: 10.10.156.97
      ansible_user: root
      ansible_ssh_private_key_file: /root/.ssh/id_rsa

qfusion_workers:
  hosts:
    worker1:
      ansible_host: 10.10.156.87
      ansible_user: root
```

### 4. 配置SSH免密登录

```bash
# 生成SSH密钥（如果���有）
ssh-keygen -t rsa -b 2048 -N ""

# 复制公钥到目标节点
ssh-copy-id root@10.10.156.97
ssh-copy-id root@10.10.156.98
ssh-copy-id root@10.10.156.87

# 测试连接
ssh root@10.10.156.97
```

### 5. 测试连接

```bash
# 设置包装脚本为可执行
chmod +x ansible-playbook-wrapper.sh

# 测试Ansible连接
ansible -i inventory/hosts.yml qfusion_cluster -m ping
```

## 🎯 使用方法

### 方式1: 使用包装脚本（推荐）

```bash
# 交互式菜单
./ansible-playbook-wrapper.sh

# 只检查（不修改）
./ansible-playbook-wrapper.sh --check

# 检查并修复
./ansible-playbook-wrapper.sh --fix

# 远程初始化
./ansible-playbook-wrapper.sh --init
```

### 方式2: 直接使用Ansible

```bash
# 只检查
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml

# 检查并修复
ansible-playbook -i inventory/hosts.yml playbooks/fix_and_check.yml

# 远程初始化
ansible-playbook -i inventory/hosts.yml playbooks/remote_init.yml
```

## 📊 支持的检查项

本方案支持25个检查项，包括：

1. 操作系统检测
2. 内核版本检查
3. YUM源配置
4. 硬件时间同步
5. 网卡速率检查
6. DNS配置
7. NetworkManager管理
8. Swap分区检查
9. SELinux检查
10. I/O调度算法
11. Auditd服务
12. 主机名格式验证
13. 必需软件包检查
14. 容器软件冲突检查
15. /tmp目录权限
16. virbr0网卡检查
17. CPU AVX指令集
18. 用户资源限制
19. lsblk与fstab匹配
20. IPv6状态
21. iptables状态
22. kdump参数
23. crashkernel内存
24. 裸盘LVM挂载
25. 麒麟ARM bpf_jit检查

## 🔧 配置说明

### 自定义检查参数

编辑 `group_vars/all.yml`：

```yaml
# 网络配置
network:
  min_nic_speed: 1000
  dns_servers:
    - "114.114.114.114"
    - "8.8.8.8"

# 系统配置
system:
  selinux_state: "disabled"
  swap_enabled: false

# kdump配置
kdump:
  enabled: false
  crashkernel: "4096M,high"
```

## 📋 系统要求

### 控制节点
- Ansible 2.9+
- Python 3.6+
- SSH客户端
- Bash

### 目标节点
- Python 2.7+ 或 Python 3.5+
- SSH服务
- Bash
- 支持的操作系统:
  - RedHat 7.8/7.9
  - CentOS 7.x
  - 麒麟V10 SP3

## 📚 文档

本包包含以下文档：

- `README.md` - 项目总览
- `MIGRATION_GUIDE.md` - 从Bash迁移到Ansible
- `QUICK_REFERENCE.md` - 快速参考手册
- `PROJECT_SUMMARY.md` - 项目摘要
- `INSTALL.md` - 本文件（安装说明）
- `VERSION.txt` - 版本信息

## ⚠️ 注意事项

1. **SSH密钥认证**：推荐使用SSH密钥，不推荐密码认证
2. **生产环境**：使用前先在测试���境验证
3. **修复模式**：`fix_and_check.yml` 会修改系统配置
4. **重启需求**：修改SELinux或grub后需要重启
5. **报告查看**：检查报告保存在 `/tmp/qfusion_ansible_reports/`

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

### Ansible版本问题

```bash
# 升级Ansible
pip3 install --upgrade ansible
```

## 📞 技术支持

- 查看文档：README.md
- 快速参考：QUICK_REFERENCE.md
- 迁移指南：MIGRATION_GUIDE.md

## 📅 版本信息

- 版本：1.0.0
- 打包时间：请查看VERSION.txt
- Ansible版本要求：2.9+
- Python版本要求：3.6+

---

**祝您使用愉快！**
