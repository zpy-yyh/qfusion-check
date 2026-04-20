# QFusion 项目目录结构说明

## 📁 当前目录组织

### 🎯 主要项目

#### `/root/zpy/qfusion_package/` - QFusion Bash脚本包（原版）
**作用**: 存放原始的QFusion安装前检查和初始化Bash脚本
- `qfusion.sh` - 主脚本（6059行）
- `install.sh` - 安装脚本
- `nodes.conf` - 节点配置文件
- `qfusion.sh.backup*` - 备份文件

#### `/root/zpy/ansible-qfusion/` - QFusion Ansible版本（新版）⭐
**作用**: Ansible自动化部署方案，替代原Bash脚本
- `ansible.cfg` - Ansible配置
- `ansible-playbook-wrapper.sh` - 交互式包装脚本
- `inventory/hosts.yml` - 节点清单
- `playbooks/` - 执行剧本
- `roles/qfusion_check/` - 检查角色

---

### 📊 检查结果目录

#### `/root/zpy/check_results_20260306_101129/` - 检查结果存档1
**作用**: 2026-03-06的批量检查结果（6个节点）

#### `/root/zpy/check_results_20260325_164419/` - 检查结果存档2
**作用**: 2026-03-25的批量检查结果（3个��点）

#### `/root/zpy/yum_check_logs/` - YUM检查日志
**作用**: YUM源配置检查的日志文件

#### `/root/zpy/yum_test_logs/` - YUM测试日志
**作用**: YUM源测试的临时日志

---

### 📜 文档目录

#### `/root/zpy/*.md` - Markdown文档
**作用**: 项目相关文档
- `安装前检查项对比.md` - 检查项对比分析
- `功能测试报告.md` - 功能测试结果
- `快速开始.md` - 快速入门指南
- `批量部署测试指南.md` - 批量部署说明
- `SSH认证方案说明.md` - SSH认证配置
- `依赖要求说明.md` - 系统依赖说明

---

### 🔧 工具脚本

#### Bash工具脚本
- `batch_check_only_expect.sh` - 批量只读检查（expect版本）
- `batch_check_only.sh` - 批量只读检查（密钥版本）
- `setup_ssh_keys.sh` - SSH密钥配置工具
- `package_qfusion.sh` - 脚本打包工具
- `check_yum*.sh` - YUM检查工具
- `test_yum_on_cluster.sh` - YUM集群测试
- `new_check_functions.sh` - 新增检查函数库

---

### 📦 压缩备份

#### 历史备份文件
- `qfusion_precheck_script_*.tar.gz` - 历史版本备份
- `zpyclaude.tar` - Claude相关备份
- `skills-main.zip` - Skills模板压缩包

---

### 🎨 Skills模板库

以下目录包含各种Claude Skills模板（用于生成不同类型的文档和应用）

#### `/root/zpy/algorithmic-art/` - 算法艺术
**作用**: 生成基于代码的艺术作品

#### `/root/zpy/brand-guidelines/` - 品牌规范
**作用**: 应用Anthropic品牌指南

#### `/root/zpy/canvas-design/` - 画布设计
**作用**: 创建PDF格式的视觉设计作品

#### `/root/zpy/claude-api/` - Claude API
**作用**: 使用Claude API构建应用（多语言示例）

#### `/root/zpy/doc-coauthoring/` - 文档协作
**作用**: 结构化文档创作工作流

#### `/root/zpy/docx/` - Word文档
**作用**: 创建、编辑Word文档

#### `/root/zpy/frontend-design/` - 前端设计
**作用**: 创建高质量前端界面

#### `/root/zpy/internal-comms/` - 内部通讯
**作用**: 创建公司内部通讯文档

#### `/root/zpy/mcp-builder/` - MCP构建器
**作用**: 创建Model Context Protocol服务器

#### `/root/zpy/pdf/` - PDF处理
**作用**: 处理PDF文件

#### `/root/zpy/pptx/` - PowerPoint
**作用**: 创建、编辑PowerPoint演示文稿

#### `/root/zpy/skill-creator/` - Skill创建器
**作用**: 创建和管理Claude Skills

#### `/root/zpy/slack-gif-creator/` - Slack GIF
**作用**: 创建Slack动画GIF

#### `/root/zpy/theme-factory/` - 主题工厂
**作用**: 应用各种主题样式

#### `/root/zpy/webapp-testing/` - Web应用测试
**作用**: 使用Playwright测试Web应用

#### `/root/zpy/web-artifacts-builder/` - Web构���器
**作用**: 创建复杂的Web组件

#### `/root/zpy/xlsx/` - Excel表格
**作用**: 处理Excel表格文件

#### `/root/zpy/skills-main/` - Skills主目录
**作用**: Skills模板主仓库

---

### 🔍 其他目录

#### `/root/zpy/.claude/` - Claude配置
**作用**: Claude Code的配置和记忆存储

#### `/root/zpy/zpy1/` - 临时工作区
**作用**: 临时文件存储

---

## 📋 建议的整理方案

### 方案A: 按功能分类整理
```
/root/zpy/
├── 01_qfusion_bash/          # 原Bash脚本
├── 02_qfusion_ansible/       # Ansible版本
├── 03_qfusion_docs/          # QFusion文档
├── 04_qfusion_scripts/       # QFusion工具脚本
├── 05_qfusion_results/       # 检查结果存档
├── 06_claude_skills/         # Claude Skills模板
├── 07_backup/               # 历史备份
└── README.md                # 项目索引
```

### 方案B: 保持当前结构，添加说明文件
在主目录和每个子目录添加 `README.md` 说明文件

---

## 📌 推荐使用

**主要使用**:
- `/root/zpy/ansible-qfusion/` ⭐ - 新的Ansible自动化方案（推荐）
- `/root/zpy/qfusion_package/` - 原Bash脚本（备用）

**参考文档**:
- `/root/zpy/快速开始.md`
- `/root/zpy/批量部署测试指南.md`
- `/root/zpy/SSH认证方案说明.md`

**检查结果查看**:
- `/root/zpy/check_results_*/` - 历史检查结果
- `/root/zpy/yum_check_logs/` - YUM检查日志
