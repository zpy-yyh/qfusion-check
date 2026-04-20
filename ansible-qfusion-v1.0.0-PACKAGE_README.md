# QFusion Ansible v1.0.0 打包说明

## 📦 打包文件信息

**文件名称**: `ansible-qfusion-v1.0.0.tar.gz`
**文件大小**: 24KB
**打包时间**: 2026-04-03 14:54:58
**版本**: v1.0.0

### 校验和

**MD5**:
```
6ed1231fef672494645e6afbfc64667c
```

**SHA256**:
```
bc3fd9ccefe6c2659699b602bc22668aa47700e346a441a32bb052d7ae57488a
```

---

## 📋 包内容清单

本包包含完整的QFusion Ansible自动化部署方案：

### 核心文件
- `ansible.cfg` - Ansible配置文件
- `ansible-playbook-wrapper.sh` - 交互式包装脚本
- `VERSION.txt` - 版本信息

### 配置文件
- `inventory/hosts.yml` - 节点清单模板
- `group_vars/all.yml` - 全局变量配置

### Playbooks
- `playbooks/check_only.yml` - 只检查（不修改）
- `playbooks/fix_and_check.yml` - 检查并修复
- `playbooks/remote_init.yml` - 远程初始化

### Ansible角色
- `roles/qfusion_check/tasks/main.yml` - 25个检查任务
- `roles/qfusion_check/tasks/fix.yml` - 25个修复任务
- `roles/qfusion_check/handlers/main.yml` - 处理程序
- `roles/qfusion_check/vars/main.yml` - 角色变量

### 文档文件
- `README.md` - 项目总览
- `INSTALL.md` - 安装说明
- `QUICK_START.md` - 快速开始指南
- `MIGRATION_GUIDE.md` - 从Bash迁移指南
- `QUICK_REFERENCE.md` - 快速参考手册
- `PROJECT_SUMMARY.md` - 项目摘要
- `PACKAGE_README.md` - 本文件

---

## 🚀 快速开始

### 1. 传输到目标服务器

```bash
# 方式1: 使用scp
scp ansible-qfusion-v1.0.0.tar.gz user@server:/tmp/

# 方式2: 使用rsync
rsync -avz ansible-qfusion-v1.0.0.tar.gz user@server:/tmp/

# 方式3: 使用FTP/SFTP工具上传
```

### 2. 验证包完整性

```bash
# 在目标服务器上验证MD5
md5sum ansible-qfusion-v1.0.0.tar.gz
# 应该输出: 6ed1231fef672494645e6afbfc64667c

# 或验证SHA256
sha256sum ansible-qfusion-v1.0.0.tar.gz
# 应该输出: bc3fd9ccefe6c2659699b602bc22668aa47700e346a441a32bb052d7ae57488a
```

### 3. 解压安装包

```bash
# 解压
tar -xzf ansible-qfusion-v1.0.0.tar.gz

# 进入目录
cd ansible-qfusion

# 查看内容
ls -la
```

### 4. 安装依赖

```bash
# 安装Ansible
yum install -y epel-release
yum install -y ansible

# 验证安装
ansible --version
```

### 5. 配置节点

```bash
# 编辑节点清单
vi inventory/hosts.yml

# 添加节点信息，例如：
qfusion_masters:
  hosts:
    master1:
      ansible_host: 10.10.156.97
      ansible_user: root
      ansible_ssh_private_key_file: /root/.ssh/id_rsa
```

### 6. 配置SSH

```bash
# 生成SSH密钥
ssh-keygen -t rsa -b 2048 -N ""

# 复制公钥到目标节点
ssh-copy-id root@10.10.156.97

# 测试连接
ssh root@10.10.156.97
```

### 7. 运行检查

```bash
# 设置包装脚本为可执行
chmod +x ansible-playbook-wrapper.sh

# 运行检查
./ansible-playbook-wrapper.sh --check
```

---

## 📚 详细文档

### 查看安装说明

```bash
cat INSTALL.md
```

### 查看快速开始

```bash
cat QUICK_START.md
```

### 查看项目总览

```bash
cat README.md
```

### 查看快速参考

```bash
cat QUICK_REFERENCE.md
```

---

## 🎯 使用场景

### 场景1: 单节点检查

```bash
# 配置单个节点
vi inventory/hosts.yml

# 运行检查
./ansible-playbook-wrapper.sh --check
```

### 场景2: 批量节点检查

```bash
# 配置多个节点
vi inventory/hosts.yml

# 批量检查
./ansible-playbook-wrapper.sh --check
```

### 场景3: 自动修复

```bash
# 检查并自动修复问题
./ansible-playbook-wrapper.sh --fix
```

### 场景4: 完整初始化

```bash
# 远程初始化新节点
./ansible-playbook-wrapper.sh --init
```

---

## 🔧 系统要求

### 控制节点（运行Ansible的机器）

| 组件 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Ansible | 2.9 | 2.11+ |
| Python | 3.6 | 3.8+ |
| 操作系统 | RHEL 7/CentOS 7 | RHEL 8/CentOS 8 |

### 目标节点（被检查的服务器）

| 组件 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Python | 2.7 或 3.5 | 3.6+ |
| Bash | 任何版本 | 任何版本 |
| SSH | OpenSSH 6.x+ | OpenSSH 7.x+ |
| 操作系统 | RHEL 7/CentOS 7/麒麟V10 | RHEL 8/CentOS 8 |

---

## 📊 支持的检查项（25项）

### 系统环境（3项）
1. 操作系统检测
2. 内核版本检查（要求 > 4.19）
3. 主机名格式验证

### 网络配置（5项）
4. 网卡速率检查（最低1000 Mbps）
5. DNS配置
6. NetworkManager管理
7. IPv6状态
8. iptables状态

### 存储配置（4项）
9. Swap分区检查
10. I/O调度算法
11. lsblk与fstab匹配
12. 裸盘LVM挂载

### 系统服务（5项）
13. SELinux
14. Auditd
15. kdump
16. crashkernel
17. virbr0网卡

### 软件包（3项）
18. YUM源配置
19. 必需软件包
20. 容器软件冲突

### 系统资源（4项）
21. 硬件时间同步
22. /tmp目录权限
23. 用户资源限制
24. CPU AVX指令集

### 麒麟系统特有（1项）
25. bpf_jit参数（麒麟ARM）

---

## ⚙️ 自定义配置

### 修改网络配置

编辑 `group_vars/all.yml`：

```yaml
network:
  min_nic_speed: 1000
  dns_servers:
    - "114.114.114.114"
    - "8.8.8.8"
  disable_ipv6: false
```

### 修改系统配置

```yaml
system:
  selinux_state: "disabled"
  auditd_enabled: false
  swap_enabled: false
```

### 修改kdump配置

```yaml
kdump:
  enabled: false
  crashkernel: "4096M,high"
```

---

## 📖 命令参考

### 包装脚本命令

```bash
# 显示菜单
./ansible-playbook-wrapper.sh

# 只检查
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

### Ansible直接命令

```bash
# 查看节点信息
ansible -i inventory/hosts.yml all -m setup

# 执行命令
ansible -i inventory/hosts.yml all -m shell -a "uptime"

# 只在master节点
ansible -i inventory/hosts.yml qfusion_masters -m shell -a "free -h"

# 使用详细输出
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml -vvv

# 限制目标节点
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml --limit master1

# 预览修改
ansible-playbook playbooks/fix_and_check.yml --check
```

---

## 📝 检查报告

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
```

---

## ⚠️ 注意事项

### 安全建议

1. **SSH密钥认证**：推荐使用SSH密钥，不推荐密码认证
2. **测试环境**：生产环境使用前先在测试环境验证
3. **权限控制**：使用适当的sudo权限
4. **网络安全**：确保SSH端口安全

### 使用建议

1. **只检查模式**：`check_only.yml` 是安全的，不会修改系统配置
2. **修复模式**：`fix_and_check.yml` 会修改系统配置，请仔细检查变量设置
3. **重启需求**：修改SELinux或grub后需要重启系统
4. **备份重要**：执行修复前备份重要配置文件

### 兼容性

1. **Ansible版本**：需要2.9或更高版本
2. **Python版本**：控制节点需要Python 3.6+，目标节点支持Python 2.7+或Python 3.5+
3. **操作系统**：支持RedHat 7.8/7.9、CentOS 7.x、麒麟V10 SP3

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

### 模块问题

```bash
# 检查Python版本
ansible all -i inventory/hosts.yml -m shell -a "python --version"

# 安装Python
ansible all -i inventory/hosts.yml -m yum -a "name=python3 state=present" -b
```

### 查看Ansible日志

```bash
# 启用详细日志
export ANSIBLE_LOG_PATH=/tmp/ansible.log
export ANSIBLE_DEBUG=True

# 运行命令
./ansible-playbook-wrapper.sh --check
```

---

## 📞 技术支持

### 文档资源

- `README.md` - 项目总览
- `INSTALL.md` - 安装说明
- `QUICK_START.md` - 快速开始
- `QUICK_REFERENCE.md` - 快速参考
- `MIGRATION_GUIDE.md` - 迁移指南

### 在线资源

- Ansible官方文档: https://docs.ansible.com/
- Ansible最佳实践: https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html

### 问题反馈

如有问题或建议，请联系QFusion项目组。

---

## 📅 版本历史

- **v1.0.0** (2026-04-03)
  - 初始发布版本
  - 支持25个检查项
  - 3个主要playbooks
  - 完整的文档体系
  - 交互式包装脚本

---

## ✨ 特性

- ✅ 幂等性：重复执行不会产生副作用
- ✅ 并行执行：默认在多个节点上同时运行
- ✅ 标准化：使用YAML格式，易于维护
- ✅ 模块化：使用roles，易于扩展
- ✅ 文档完善：包含完整的安装和使用文档
- ✅ 易于使用：交互式包装脚本

---

## 🎓 学习路径

### 初学者
1. 阅读 `QUICK_START.md`
2. 使用包装脚本进行第一次检查
3. 查看检查报告了解系统状态

### 进阶用户
1. 阅读 `README.md` 了解项目结构
2. 学习自定义配置变量
3. 尝试编写自定义检查项

### 高级用户
1. 深入研究Ansible roles
2. 扩展检查项和修复逻辑
3. 集成到CI/CD流程

---

## 📦 打包说明

本包使用以下脚本打包：
```bash
/root/zpy/package_ansible_qfusion.sh
```

如需重新打包：
```bash
cd /root/zpy
./package_ansible_qfusion.sh
```

---

**祝您使用愉快！**

**版本**: v1.0.0
**打包时间**: 2026-04-03 14:54:58
**维护者**: QFusion项目组
