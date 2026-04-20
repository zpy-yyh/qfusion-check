# QFusion 项目目录索引

> **最后更新**: 2026-04-03
> **状态**: ✅ 整理完成

---

## 🎯 快速导航

### 核心项目（使用这两个）
| 项目 | 路径 | 推荐度 | 说明 |
|------|------|--------|------|
| **Ansible版本** ⭐ | `./ansible-qfusion/` | ⭐⭐⭐⭐⭐ | 新版，推荐使用 |
| **Bash版本** | `./qfusion_package/` | ⭐⭐⭐⭐ | 原版，稳定可靠 |

### 重要文档
| 文档 | 说明 |
|------|------|
| [README.md](./README.md) | 项目总览（必读） |
| [DIRECTORY_STRUCTURE.md](./DIRECTORY_STRUCTURE.md) | 完整目录结构说明 |
| [快速开始.md](./快速开始.md) | 快速入门指南 |
| [批量部署测试指南.md](./批量部署测试指南.md) | 批量部署说明 |

---

## 📁 一级目录说明

### 🎯 QFusion核心项目

#### `ansible-qfusion/` ⭐ **推荐**
**作用**: QFusion Ansible自动化部署方案
**状态**: ✅ 可用
**优势**: 幂等性、并行执行、易维护
**快速开始**:
```bash
cd ansible-qfusion
./ansible-playbook-wrapper.sh --check
```

#### `qfusion_package/`
**作用**: QFusion Bash脚本包（原版）
**状态**: ✅ 可用
**优势**: 功能完整、成熟稳定
**快速开始**:
```bash
cd qfusion_package
bash qfusion.sh --check
```

---

### 📊 检查结果存档

#### `check_results_20260306_101129/`
**作用**: 2026-03-06批量检查结果（6节点）
**内容**: 每个节点的详细检查报告 + 汇总报告

#### `check_results_20260325_164419/`
**作用**: 2026-03-25批量检查结果（3节点）
**内容**: 每个节点的详细检查报告 + 汇总报告

#### `yum_check_logs/`
**作用**: YUM源配置检查日志
**内容**: 各节点的YUM检查详细日志

#### `yum_test_logs/`
**作用**: YUM源测试临时日志
**内容**: 测试期间的临时文件

---

### 📚 文档目录

#### Markdown文档（主目录）
- `README.md` - 项目总览
- `DIRECTORY_STRUCTURE.md` - 目录结构说明
- `安装前检查项对比.md` - 25个检查项详细对比
- `功能测试报告.md` - 功能测试结果
- `快速开始.md` - 快速入门指南
- `批量部署测试指南.md` - 批量部署说明
- `SSH认证方案说明.md` - SSH配置指南
- `依赖要求说明.md` - 系统依赖说明
- `QFusion手动操作指南.md` - 手动操作步骤
- `QFusion安装前检查项-未实现项分析.md` - 未实现项分析
- `三节点完整检查报告.md` - 完整检查报告分析
- `集群检查结果报告.md` - 集群检查结果
- `集群节点配置说明.md` - 节点��置说明

#### Word/PDF文档
- `QFusion安装前后检查项.docx` - 完整检查项说明（Word）
- `QFusion安装前后检查项.pdf` - 完整检查项说明（PDF）

---

### 🔧 工具脚本

#### 批量检查工具
- `batch_check_only_expect.sh` - 批量只读检查（expect版本）
- `batch_check_only.sh` - 批量只读检查（密钥版本）

#### SSH配置工具
- `setup_ssh_keys.sh` - 配置SSH免密登录

#### YUM检查工具
- `check_yum.sh` - YUM源检查
- `check_yum_config.sh` - YUM配置检查
- `check_yum_status.exp` - YUM状态检查（expect）
- `check_yum_v2.sh` - YUM检查v2版本
- `test_yum_on_cluster.sh` - YUM集群测试

#### 其他工具
- `package_qfusion.sh` - 脚本打包工具
- `copy_script.sh` - 脚本复制工具
- `fix_yum_check.sh` - YUM检查修复工具
- `run_full_check.sh` - 运行完整检查
- `new_check_functions.sh` - 新增检查函数库

---

### 📦 历史备份

#### 压缩备份文件
- `qfusion_precheck_script_20260306_114533.tar.gz` - 历史版本备份1
- `qfusion_precheck_script_20260306_170300.tar.gz` - 历史版本备份2
- `zpyclaude.tar` - Claude相关备份
- `skills-main.zip` - Skills模板压缩包

#### 临时文件
- `nodes_temp.conf` - 临时节点配置
- `节点配置` - 节点配置文件

---

### 🎨 Claude Skills模板库

以下目录包含各种Claude Skills模板，用于生成不同类型的文档和应用：

#### 核心Skills
- `algorithmic-art/` - 算法艺术生成
- `brand-guidelines/` - 品牌规范应用
- `canvas-design/` - 画布设计（PDF）
- `claude-api/` - Claude API示例（多语言）
- `doc-coauthoring/` - 文档协作工作流
- `docx/` - Word文档处理
- `frontend-design/` - 前端界面设计
- `mcp-builder/` - MCP服务器构建
- `pdf/` - PDF文件处理
- `pptx/` - PowerPoint演示文稿
- `skill-creator/` - Skill创建和管理
- `skills-main/` - Skills主仓库

#### 专用Skills
- `internal-comms/` - 内部通讯文档
- `slack-gif-creator/` - Slack GIF创建
- `theme-factory/` - 主题样式应用
- `webapp-testing/` - Web应用测试
- `web-artifacts-builder/` - Web组件构建
- `xlsx/` - Excel表格处理

---

### 🔍 配置和缓存

#### Claude配置
- `.claude/` - Claude Code配置和记忆存储

#### 临时工作区
- `zpy1/` - 临时文件存储
- `o/` - 其他临时目录

---

## 📋 文件分类统计

| 类型 | 数量 | 说明 |
|------|------|------|
| YML文件 | 9个 | Ansible配置和剧本 |
| Shell脚本 | 12个 | 工具和检查脚本 |
| Markdown文档 | 15个 | 各类说明文档 |
| Skills模板 | 16个 | Claude Skills模板 |
| 压缩备份 | 3个 | 历史版本备份 |
| 其他文档 | 2个 | Word/PDF文档 |

---

## 🚀 使用建议

### 日常使用
1. **主要使用** Ansible版本（`ansible-qfusion/`）
2. **参考文档** 快速开始指南（`快速开始.md`）
3. **查看结果** 检查结果目录（`check_results_*/`）

### 首次使用
1. 阅读 [README.md](./README.md)
2. 阅读 [快速开始.md](./快速开始.md)
3. 配置节点清单
4. 执行第一次检查

### 问题排查
1. 查看相关文档（`README.md`、`DIRECTORY_STRUCTURE.md`）
2. 检查历史结果（`check_results_*/`）
3. 查看YUM日志（`yum_check_logs/`）

---

## 📊 目录大小统计

```bash
# 查看目录大小
du -sh /root/zpy/*/ 2>/dev/null | sort -hr
```

**主要目录大小估计**:
- `ansible-qfusion/`: ~500KB
- `qfusion_package/`: ~1MB
- `skills-main/`: ~500KB
- `check_results_*/`: ~10MB
- 其他Skills模板: ~5MB
- 文档文件: ~10MB

---

## 🔗 相关链接

- [README.md](./README.md) - 项目总览
- [DIRECTORY_STRUCTURE.md](./DIRECTORY_STRUCTURE.md) - 详细目录说明
- [ansible-qfusion/README.md](./ansible-qfusion/README.md) - Ansible项目文档
- [ansible-qfusion/MIGRATION_GUIDE.md](./ansible-qfusion/MIGRATION_GUIDE.md) - 迁移指南

---

## ⚠️ 维护建议

### 定期清理
1. 删除旧的检查结果（`check_results_*/`）
2. 清理YUM日志（`yum_check_logs/`）
3. 删除临时文件（`*.tmp`、`nodes_temp.conf`）

### 版本管理
1. 定期备份重要文件
2. 删除过期的压缩备份
3. 保持文档更新

### 最佳实践
1. 使用Ansible版本进行新部署
2. Bash版本作为备用方案
3. 保留Skills模板用于其他项目

---

**文档版本**: v1.0
**最后更新**: 2026-04-03
**维护者**: QFusion项目组
