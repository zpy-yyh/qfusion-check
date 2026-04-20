# QFusion Ansible v1.0.3 更新说明

**版本**: 1.0.3
**发布日期**: 2026-04-08
**包大小**: 35K
**MD5**: 0bf4cf3563fd4b39d9d03d7277a3baac
**SHA256**: dc6d393c97a55dba7195874ba64fc0c8debb9ecb90e639bd59838ca3865634aa

---

## 🎉 新增功能

### Oracle数据库依赖包支持

**重大更新**: 新增Oracle数据库依赖包的检查和自动安装功能

#### 新增软件包列表（23个）
```yaml
- bc
- binutils
- elfutils-libelf
- elfutils-libelf-devel
- fontconfig-devel
- glibc
- glibc-devel
- ksh
- libaio
- libaio-devel
- libXrender
- libXrender-devel
- libX11
- libXau
- libXi
- libXtst
- libgcc
- libstdc++
- libstdc++-devel
- libxcb
- make
- policycoreutils
- smartmontools
- sysstat
```

---

## 📝 修改内容

### 1. 全局变量配置
**文件**: `group_vars/all.yml`

新增 `oracle_required_packages` 变量，包含23个Oracle数据库依赖包。

### 2. 检查任务
**文件**: `roles/qfusion_check/tasks/main.yml`

新增检查任务：
- 检查每个Oracle依赖包是否已安装
- 统计缺失的包数量
- 在报告中记录检查结果
- 显示缺失包的详细信息

**输出示例**:
```
✓ Oracle依赖包: 缺少 0 个
```
或
```
⚠ Oracle依赖包: 缺少 5 个
缺失的Oracle包: bc, binutils, elfutils-libelf, ksh, libaio
```

### 3. 自动安装任务
**文件**: `roles/qfusion_check/tasks/fix.yml`

新增自动安装任务：
- 显示即将安装的包列表
- 使用 `yum install -y` 批量安装缺失的包
- 记录安装结果

**执行方式**:
```bash
ansible-playbook -i inventory/hosts.yml playbooks/fix_and_check.yml
```

---

## 🔧 技术细节

### 包检查机制
使用Ansible的 `package` 模块的 `check_mode` 参数：
- 只检查包是否存在，不进行实际安装
- 返回每个包的安装状态
- 统计缺失的包列表

### 自动安装机制
使用Ansible的 `package` 模块：
- 自动检测系统包管理器（yum/dnf/apt）
- 批量安装缺失的包
- 支持幂等性操作（重复执行无影响）

---

## 📊 检查项更新

### 更新前（v1.0.2）
总检查项: 25项
- 必需软件包: 9个（基础系统包）
- Oracle依赖包: ❌ 不支持

### 更新后（v1.0.3）
总检查项: 26项
- 必需软件包: 9个（基础系统包）
- **Oracle依赖包: 23个（新增）** ✅

---

## 🚀 使用示例

### 只检查Oracle依赖包
```bash
cd ansible-qfusion-v1.0.3
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml
```

### 检查并自动安装缺失的包
```bash
cd ansible-qfusion-v1.0.3
ansible-playbook -i inventory/hosts.yml playbooks/fix_and_check.yml
```

### 查看检查报告
```bash
cat /tmp/qfusion_ansible_reports/<hostname>_check_report.txt
```

---

## 💡 兼容性说明

### 操作系统支持
- ✅ RedHat 7.8/7.9
- ✅ CentOS 7.x
- ✅ 麒麟V10 SP3

### 包管理器支持
- ✅ yum (RHEL/CentOS 7)
- ✅ dnf (RHEL/CentOS 8+)
- ✅ apt (Debian/Ubuntu, 实验性)

### 软件包兼容性
注意：某些软件包在不同系统上可能有不同的包名：
- `policycoreutils-python` 在较新系统中可能是 `python3-policycoreutils`
- `compat-libstdc++-33` 在某些发行版中可能不可用（已从列表中移除）

---

## 🐛 已知问题

1. **包名差异**: 不同Linux发行版的包名可能略有差异
2. **网络依赖**: 安装包需要可用的YUM源或网络连接
3. **权限要求**: 需要root权限或sudo权限

---

## 🔮 未来计划

### v1.0.4 计划
- [ ] 支持更多数据库类型（MySQL、PostgreSQL）
- [ ] 添加软件包依赖关系分析
- [ ] 支持离线安装包
- [ ] 添加软件包版本检查

### v1.1.0 计划
- [ ] 支持容器化部署检查
- [ ] 添加性能基准测试
- [ ] 集成健康检查功能

---

## 📞 技术支持

### 文档
- README.md - 项目总览
- INSTALL.md - 安装说明
- QUICK_START.md - 快速开始
- QUICK_REFERENCE.md - 快速参考

### 脚本文件
- ansible-playbook-wrapper.sh - 交互式包装脚本
- playbooks/check_only.yml - 只检查
- playbooks/fix_and_check.yml - 检查并修复

### 联系方式
- 查看文档了解详细使用方法
- 遇到问题请检查日志文件
- 查看 `/tmp/qfusion_ansible_reports/` 目录获取详细报告

---

## 📦 下载信息

### 文件信息
- **文件名**: ansible-qfusion-v1.0.3.tar.gz
- **大小**: 35K
- **格式**: tar.gz (gzip压缩)
- **平台**: Linux (x86_64, ARM64)

### 校验和
```
MD5:    0bf4cf3563fd4b39d9d03d7277a3baac
SHA256:  dc6d393c97a55dba7195874ba64fc0c8debb9ecb90e639bd59838ca3865634aa
```

### 验证方法
```bash
# MD5验证
md5sum ansible-qfusion-v1.0.3.tar.gz
# 应输出: 0bf4cf3563fd4b39d9d03d7277a3baac

# SHA256验证
sha256sum ansible-qfusion-v1.0.3.tar.gz
# 应输出: dc6d393c97a55dba7195874ba64fc0c8debb9ecb90e639bd59838ca3865634aa
```

---

## 🎯 升级建议

### 从v1.0.2升级
1. 下载v1.0.3包
2. 解压覆盖（建议先备份配置）
3. 重新运行检查脚本

### 配置迁移
- inventory配置: 无需修改
- 自定义变量: 可能需要添加Oracle相关配置
- 自定义任务: 保持兼容

---

**祝您使用愉快！**

*QFusion Ansible v1.0.3 - 更安全、更强大、更智能*
