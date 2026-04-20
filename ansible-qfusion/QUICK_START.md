# QFusion Ansible 快速开始

## 5分钟快速上手

### 1️⃣ 安装依赖（1分钟）

```bash
# 安装Ansible
yum install -y epel-release
yum install -y ansible

# 验证
ansible --version
```

### 2️⃣ 配置节点（1分钟）

编辑 `inventory/hosts.yml`，添加你的节点：

```yaml
qfusion_masters:
  hosts:
    master1:
      ansible_host: 10.10.156.97
      ansible_user: root
      ansible_ssh_private_key_file: /root/.ssh/id_rsa
```

### 3️⃣ 配置SSH（1分钟）

```bash
# 复制SSH密钥
ssh-copy-id root@10.10.156.97

# 测试连接
ansible -i inventory/hosts.yml all -m ping
```

### 4️⃣ 运行检查（1分钟）

```bash
# 只检查，不修改
./ansible-playbook-wrapper.sh --check
```

### 5️⃣ 查看报告（1分钟）

```bash
# 查看报告
cat /tmp/qfusion_ansible_reports/*_check_report.txt
```

## 🎯 常用命令

```bash
# 查看菜单
./ansible-playbook-wrapper.sh

# 只检查
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

## 📖 详细文档

- `README.md` - 完整文档
- `INSTALL.md` - 安装说明
- `QUICK_REFERENCE.md` - 快速参考

---

**开始使用吧！**
