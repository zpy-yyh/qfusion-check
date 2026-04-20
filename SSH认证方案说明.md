# QFusion 批量部署 - SSH认证方案说明

## 📋 依赖要求总结

### 方案对比

| 方案 | 需要额外软件 | 推荐度 | 适用场景 |
|------|-------------|--------|----------|
| **SSH密钥认证** | ❌ 无需额外软件 | ⭐⭐⭐⭐⭐ | **推荐** - 生产环境首选 |
| expect脚本 | ✅ 需要安装expect | ⭐⭐⭐⭐ | 当前使用，兼容性好 |
| sshpass | ✅ 需要安装sshpass | ⭐⭐⭐ | 需要epel源 |
| 手动输入密码 | ❌ 无需额外软件 | ⭐ | 仅适合单节点 |

---

## 🎯 推荐方案：SSH密钥认证（无需额外软件）

### 优势
- ✅ **无需安装任何额外软件**
- ✅ **更安全**（公钥加密）
- ✅ **适合生产环境**
- ✅ **无需ISO或网络**
- ✅ **系统自带SSH功能**

### 配置步骤

#### 步骤1: 在管理节点生成SSH密钥

```bash
# 在当前管理节点（运行脚本的机器）执行
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa
```

#### 步骤2: 配置免密登录到各节点

**方式A：使用ssh-copy-id（推荐）**

```bash
# 对每个节点执行一次
ssh-copy-id root@10.10.156.97
ssh-copy-id root@10.10.156.98
ssh-copy-id root@10.10.156.99
ssh-copy-id root@10.10.156.87
ssh-copy-id root@10.10.156.88
ssh-copy-id root@10.10.156.89
```

**方式B：手动配置（如果ssh-copy-id不可用）**

```bash
# 1. 复制公钥到各节点
scp ~/.ssh/id_rsa.pub root@10.10.156.97:/tmp/
scp ~/.ssh/id_rsa.pub root@10.10.156.98:/tmp/
# ... 其他节点

# 2. 在每个节点上执行
ssh root@10.10.156.97 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && rm /tmp/id_rsa.pub"
ssh root@10.10.156.98 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && rm /tmp/id_rsa.pub"
# ... 其他节点
```

#### 步骤3: 验证免密登录

```bash
# 测试是否可以无密码登录
ssh root@10.10.156.97 "hostname"
ssh root@10.10.156.98 "hostname"
# ... 应该不需要输入密码
```

#### 步骤4: 修改节点配置文件

```bash
cat > /root/zpy/qfusion_package/nodes.conf << EOF
# 使用SSH密钥认证（推荐）
10.10.156.97 rds001 master root /root/.ssh/id_rsa
10.10.156.98 rds002 master root /root/.ssh/id_rsa
10.10.156.99 rds003 master root /root/.ssh/id_rsa
10.10.156.87 rds004 worker root /root/.ssh/id_rsa
10.10.156.88 rds005 worker root /root/.ssh/id_rsa
10.10.156.89 rds006 worker root /root/.ssh/id_rsa
EOF
```

#### 步骤5: 使用标准SSH脚本运行

```bash
# 使用标准SSH批量检查脚本（无需expect）
bash /root/zpy/batch_check_only.sh
```

---

## 🔧 方案2：使用expect（当前方案）

### 依赖
- 需要安装expect
- 通常系统已自带

### 安装方法

**使用本地YUM源（推荐）**

```bash
# 1. 挂载ISO镜像
mount /dev/sr0 /mnt/

# 2. 配置本地YUM源
cat > /etc/yum.repos.d/local.repo << EOF
[local]
name=Local ISO
baseurl=file:///mnt/
enabled=1
gpgcheck=0
EOF

# 3. 安装expect
yum install -y expect

# 4. 卸载ISO
umount /mnt
```

**使用在线YUM源**

```bash
yum install -y expect
```

### 优缺点
- ✅ 优点：支持密码认证，不需要配置免密登录
- ❌ 缺点：需要安装expect包
- ⚠️  注意：密码明文存储在配置文件中

---

## 🔐 方案3：使用sshpass

### 依赖
- 需要安装sshpass
- 通常需要epel源

### 安装方法

```bash
# 方法1: 使用epel源
yum install -y epel-release
yum install -y sshpass

# 方法2: 手动编译（如果YUM源没有）
wget http://sourceforge.net/projects/sshpass/files/sshpass/1.05/sshpass-1.05.tar.gz
tar xvzf sshpass-1.05.tar.gz
cd sshpass-1.05
./configure
make && make install
```

### 优缺点
- ✅ 优点：简单易用
- ❌ 缺点：很多YUM源没有，需要epel
- ⚠️  注意：密码明文存储

---

## 📊 方案选择建议

### 生产环境（推荐）
```bash
✅ 使用SSH密钥认证
- 无需额外软件
- 更安全
- 稳定可靠
```

### 测试环境
```bash
⚠️ 使用expect + 密码认证
- 快速方便
- 无需配置免密
- 适合测试
```

### 内网/隔离环境
```bash
✅ 使用SSH密钥认证
- 不需要网络
- 不需要YUM源
- 系统自带功能
```

---

## 🎯 总结

### 最简单的方案（推荐）

**SSH密钥认证 + 标准SSH**

```bash
# 1. 生成密钥
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa

# 2. 复制公钥到各节点
for ip in 97 98 99 87 88 89; do
  ssh-copy-id root@10.10.156.$ip
done

# 3. 修改配置文件使用密钥认证
cat > /root/zpy/qfusion_package/nodes.conf << EOF
10.10.156.97 rds001 master root /root/.ssh/id_rsa
...
EOF

# 4. 运行检查
bash /root/zpy/batch_check_only.sh
```

### 优势总结

- ✅ **无需安装任何额外软件**
- ✅ **不需要ISO镜像**
- ✅ **不需要网络连接**
- ✅ **更安全可靠**
- ✅ **系统自带功能**

---

## 📝 文档更新说明

需要在以下文档中标注：

### README.md
```markdown
## 依赖要求

### 必需依赖
- Bash (系统自带)
- SSH (系统自带)

### 可选依赖（用于批量部署）
- SSH密钥认证：**无需额外软件（推荐）**
- expect: 用于密码认证
- sshpass: 用于密码认证（可选）

### 推荐配置
- 生产环境：使用SSH密钥认证（无需额外软件）
- 测试环境：使用expect + 密码认证
```

### 安装前检查.md
```markdown
## 系统要求

### 基本要求
- 操作系统：RedHat 7.8/7.9 或 麒麟V10 SP3
- 用户权限：root权限

### 批量部署要求

**方案A：SSH密钥认证（推荐）**
- ✅ 无需安装额外软件
- ✅ 使用系统自带SSH功能
- ✅ 更安全可靠

**方案B：expect认证**
- ⚠️ 需要安装expect
- ✅ 支持密码认证
- 安装：yum install -y expect

**方案C：sshpass认证**
- ⚠️ 需要安装sshpass和epel源
- ⚠️ 部分YUM源不可用
```

---

## 🔗 相关文件

- SSH密钥配置脚本: `/root/zpy/setup_ssh_keys.sh` (待创建)
- 批量检查脚本(密钥版): `/root/zpy/batch_check_only.sh`
- 批量检查脚本(expect版): `/root/zpy/batch_check_only_expect.sh`
