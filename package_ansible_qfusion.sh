#!/bin/bash

# QFusion Ansible 脚本打包脚本
# 作用: 将ansible-qfusion项目打包为tar.gz文件

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
PROJECT_NAME="ansible-qfusion"
VERSION="1.0.4"
PACKAGE_NAME="${PROJECT_NAME}-v${VERSION}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="/root/zpy"
PACKAGE_FILE="${OUTPUT_DIR}/${PACKAGE_NAME}.tar.gz"

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/${PROJECT_NAME}"

# 输出函数
echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo_blue() {
    echo -e "${BLUE}[*]${NC} $1"
}

show_separator() {
    echo "=========================================="
}

# 检查项目目录
check_project_dir() {
    if [ ! -d "$PROJECT_DIR" ]; then
        echo_error "项目目录不存在: $PROJECT_DIR"
        exit 1
    fi
    echo_info "✓ 项目目录存在: $PROJECT_DIR"
}

# 清理临时文件
cleanup_temp_files() {
    echo_blue "清理临时文件..."

    cd "$PROJECT_DIR"

    # 清理Python缓存
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true

    # 清理临时文件
    find . -type f -name "*.tmp" -delete 2>/dev/null || true
    find . -type f -name "*.log" -delete 2>/dev/null || true

    # 清理Ansible缓存
    rm -rf .ansible/tmp 2>/dev/null || true

    echo_info "✓ 临时文件清理完成"
}

# 创建版本信息文件
create_version_info() {
    echo_blue "创建版本信息文件..."

    cat > "${PROJECT_DIR}/VERSION.txt" << EOF
QFusion Ansible Project
========================

版本: ${VERSION}
打包时间: $(date '+%Y-%m-%d %H:%M:%S')
打包脚本: $(basename "$0")
系统信息: $(uname -a)

文件清单:
EOF

    cd "$PROJECT_DIR"
    find . -type f ! -path "./.git/*" ! -path "./.*" | sort >> VERSION.txt

    echo_info "✓ 版本信息文件创建完成"
}

# 创建安装说明
create_install_guide() {
    echo_blue "创建安装说明..."

    cat > "${PROJECT_DIR}/INSTALL.md" << 'EOF'
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
EOF

    echo_info "✓ 安装说明创建完成"
}

# 创建快速开始指南
create_quick_start() {
    echo_blue "创建快速开始指南..."

    cat > "${PROJECT_DIR}/QUICK_START.md" << 'EOF'
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
EOF

    echo_info "✓ 快速开始指南创建完成"
}

# 打包项目
package_project() {
    echo_blue "开始打包项目..."

    cd "$OUTPUT_DIR"

    # 打包（排除临时文件和缓存）
    tar -czf "$PACKAGE_FILE" \
        --exclude='.ansible' \
        --exclude='.git' \
        --exclude='*.tmp' \
        --exclude='*.log' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        --exclude='.DS_Store' \
        "$PROJECT_NAME"

    # 计算文件大小
    PACKAGE_SIZE=$(du -h "$PACKAGE_FILE" | cut -f1)

    echo_info "✓ 打包完成: $PACKAGE_FILE ($PACKAGE_SIZE)"
}

# 生成MD5校验和
generate_checksum() {
    echo_blue "生成校验和..."

    cd "$OUTPUT_DIR"

    if command -v md5sum &>/dev/null; then
        md5sum "$PACKAGE_FILE" > "${PACKAGE_FILE}.md5"
        echo_info "✓ MD5校验和已生成"
    fi

    if command -v sha256sum &>/dev/null; then
        sha256sum "$PACKAGE_FILE" > "${PACKAGE_FILE}.sha256"
        echo_info "✓ SHA256校验和已生成"
    fi
}

# 显示包信息
show_package_info() {
    show_separator
    echo "包信息:"
    show_separator
    echo "项目名称: $PROJECT_NAME"
    echo "版本: $VERSION"
    echo "包文件: $PACKAGE_FILE"
    echo "包大小: $(du -h "$PACKAGE_FILE" | cut -f1)"
    echo "打包时间: $(date '+%Y-%m-%d %H:%M:%S')"
    show_separator

    # 显示校验和
    if [ -f "${PACKAGE_FILE}.md5" ]; then
        echo "MD5校验和:"
        cat "${PACKAGE_FILE}.md5"
    fi

    if [ -f "${PACKAGE_FILE}.sha256" ]; then
        echo "SHA256校验和:"
        cat "${PACKAGE_FILE}.sha256"
    fi

    show_separator
}

# 主函数
main() {
    show_separator
    echo "      QFusion Ansible 打包工具"
    show_separator
    echo ""

    echo_blue "开始打包流程..."
    echo ""

    # 执行打包步骤
    check_project_dir
    cleanup_temp_files
    create_version_info
    create_install_guide
    create_quick_start
    package_project
    generate_checksum

    echo ""
    show_separator
    echo_info "✓ 打包完成！"
    show_separator
    echo ""

    show_package_info

    echo ""
    echo_blue "使用说明:"
    echo ""
    echo "1. 传输到目标服务器:"
    echo "   scp $PACKAGE_FILE user@server:/path/"
    echo ""
    echo "2. 在目标服务器解压:"
    echo "   tar -xzf $PACKAGE_FILE"
    echo "   cd $PROJECT_NAME"
    echo ""
    echo "3. 查看安装说明:"
    echo "   cat INSTALL.md"
    echo ""
    echo "4. 快速开始:"
    echo "   cat QUICK_START.md"
    echo ""
    echo "5. 运行检查:"
    echo "   ./ansible-playbook-wrapper.sh --check"
    echo ""
    show_separator
}

# 运行主函数
main "$@"
