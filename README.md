
# qfusion-check

## 📂 项目简介

本项目提供基于 K8s 的数据库私有云平台安装前的自动化环境检查工具，包含：
- Bash 脚本版本
- Ansible 自动化版本
- 使用文档和操作指南

---

## 🎯 快速导航

### 核心项目

| 项目 | 路径 | 状态 | 说明 |
|------|------|------|------|
| **QFusion Ansible** | `./ansible-qfusion/` | ⭐ **推荐** | Ansible自动化部署方案 |
| **QFusion Bash** | `./qfusion_package/` | ✅ 可用 | 原始Bash脚本版本 |

### 重要文档

| 文档 | 说明 |
|------|------|
| [DIRECTORY_STRUCTURE.md](./DIRECTORY_STRUCTURE.md) | 完整的目录结构说明 |
| [快速开始.md](./快速开始.md) | 快速入门指南 |
| [批量部署测试指南.md](./批量部署测试指南.md) | 批量部署说明 |
| [SSH认证方案说明.md](./SSH认证方案说明.md) | SSH配置指南 |
| [安装前检查项对比.md](./安装前检查项对比.md) | 检查项详细对比 |

---

## 🚀 快速开始

### 方案1: 使用Ansible（推荐）

```bash
# 1. 进入Ansible项目目录
cd /opt/qfusion-check/ansible-qfusion

# 2. 配置节点清单
vi inventory/hosts.yml

# 3. 运行检查
./ansible-playbook-wrapper.sh --check
```

### 方案2: 使用Bash脚本

```bash
# 1. 进入Bash脚本目录
cd /opt/qfusion-check/qfusion_package

# 2. 运行检查
bash qfusion.sh --check
```

---

## 📊 支持的操作系统

- ✅ RedHat 7.8/7.9
- ✅ CentOS 7.x
- ✅ 麒麟V10 SP3

---

## 📋 检查项概览

### 系统环境（3项）
- 操作系统检测
- 内核版本检查（要求 > 4.19）
- 主机名格式验证

### 网络配置（5项）
- 网卡速率检查（最低1000 Mbps）
- DNS配置
- NetworkManager管理
- IPv6状态
- iptables状态

### 存储配置（4项）
- Swap分区检查
- I/O调度算法
- lsblk与fstab匹配
- 裸盘LVM挂载

### 系统服务（5项）
- SELinux
- Auditd
- kdump
- crashkernel
- virbr0网卡

### 软件包（3项）
- YUM源配置
- 必需软件包检查
- 容器软件冲突检查

### 系统资源（4项）
- 硬件时间同步
- /tmp目录权限
- 用户资源限制
- CPU AVX指令集

### 麒麟系统特有（1项）
- bpf_jit参数（麒麟ARM）

**总计：25个检查项**

---

## 🔧 工具脚本

### 批量  查工具
- `batch_check_only_expect.sh` - 批量只读检查（expect版本）
- `batch_check_only.sh` - 批量只读检查（密钥版本）

### SSH配置工具
- `setup_ssh_keys.sh` - 配置SSH免密登录

### YUM检查工具
- `check_yum.sh` - YUM源检查
- `check_yum_config.sh` - YUM配置检查
- `test_yum_on_cluster.sh` - YUM集群测试

### 其他工具
- `package_qfusion.sh` - 脚本打包工具
- `run_full_check.sh` - 运行完整检查

---

## 📁 检查结果存档

| 目录 | 日期 | 节点数 |
|------|------|--------|
| `check_results_20260306_101129/` | 2026-03-06 | 6个节点 |
| `check_results_20260325_164419/` | 2026-03-25 | 3个节点 |

查看报告：
```bash
# 查看汇总报告
cat check_results_*/summary_report.txt

# 查看特定节点报告
cat check_results_*/192.168.1.97/report.txt
```

---

## 🎨 Claude Skills模板

本目录还包含多个Claude Skills模板，用于生成各种类型的文档和应用：

- `algorithmic-art/` - 算法艺术生成
- `brand-guidelines/` - 品牌规范应用
- `canvas-design/` - 画布设计
- `claude-api/` - Claude API示例
- `doc-coauthoring/` - 文档协作
- `docx/` - Word文档处理
- `frontend-design/` - 前端设计
- `mcp-builder/` - MCP服务器构建
- `pdf/` - PDF处理
- `pptx/` - PowerPoint
- `skill-creator/` - Skill创建器
- `webapp-testing/` - Web应用测试
- `web-artifacts-builder/` - Web组件构建
- `xlsx/` - Excel处理

详细说明请参考 [DIRECTORY_STRUCTURE.md](./DIRECTORY_STRUCTURE.md)

---

## 📖 文档索引

### QFusion相关
- [DIRECTORY_STRUCTURE.md](./DIRECTORY_STRUCTURE.md) - 完整目录结构
- [安装前检查项对比.md](./安装前检查项对比.md) - 25个检查项详细对比
- [功能测试报告.md](./功能测试报告.md) - 功能测试结果
- [功能更新总结.md](./功能更新总结.md) - 功能更新历史
- [更新后的测试报告.md](./更新后的测试报告.md) - 最新测试报告
- [三节点完整检查报告.md](./三节点完整检查报告.md) - 完整检查报告

### 操作指南
- [快速开始.md](./快速开始.md) - 快速入门
- [批量部署测试指南.md](./批量部署测试指南.md) - 批量部署
- [SSH认证方案说明.md](./SSH认证方案说明.md) - SSH配置
- [依赖要求说明.md](./依赖要求说明.md) - 系统依赖
- [QFusion手动操作指南.md](./QFusion手动操作指南.md) - 手动操作

### 其他
- [QFusion安装前检查项-未实现项分析.md](./QFusion安装前检查项-未实现项分析.md)
- [脚本修改说明_安装前后检查分离.md](./脚本修改说明_安装前后检查分离.md)

---

## 🔄 Bash脚本 vs Ansible

| 特性 | Bash脚本 | Ansible |
|------|---------|---------|
| 学习曲线 | 低 | 中等 |
| 可维护性 | 一般 | 好 |
| 扩展性 | 一般 | 优秀 |
| 幂等性 | 无 | 有 |
| 并行执行 | 需要额外实现 | 原生支持 |
| 版本控制 | 可行 | 优秀 |
| 推荐场景 | 单节点/小规模 | 大规模集群 |

---

## 📞 技术支持

- 原Bash脚本: `/opt/qfusion-check/qfusion_package/qfusion.sh`
- Ansible项目: `/opt/qfusion-check/ansible-qfusion/`
- 完整文档: 查看各目录下的 `README.md` 文件

---

## 📅 版本信息

- **Bash脚本版本**: v1.0（基于2026-03-06）
- **Ansible版本**: v1.0.0（2026-04-03）
- **检查项数量**: 25项
- **支持操作系统**: RedHat 7.8/7.9, CentOS 7.x, 麒麟V10 SP3

---

## 📌 注意事项

1. **生产环境使用前**，请先在测试环境验证
2. **Ansible版本**推荐使用SSH密钥认证，更安全
3. **Bash脚本**包含expect功能，适合需要交互的场景
4. **检查报告**会保存在各节点和本地，请定期清理
5. **备份文件**占用磁盘空间，建议定期清理

---

## 🎓 学习路径

### 初学者
1. 阅读 [快速开始.md](./快速开始.md)
2. 使用Ansible wrapper脚本进行第一次检查
3. 查看检查报告了解系统状态

### 进阶用户
1. 阅读 [DIRECTORY_STRUCTURE.md](./DIRECTORY_STRUCTURE.md) 了解项目结构
2. 学习自定义配置变量
3. 尝试编写自定义检查项

### 高级用户
1. 深入研究Ansible roles
2. 扩展检查项和修复逻辑
3. 集成到CI/CD流程

---

**最后更新**: 2026-04-03

