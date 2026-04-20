# Skills 使用指南

## 📚 已安装的Skills

### 1. Superpowers (using-superpowers)
**作用**: 自动检测和使用相关技能的元技能
**安装量**: 41.2K installs

### 2. Planning with Files
**作用**: 文件化规划工具，组织复杂任务
**安装量**: 11.7K installs

### 3. Ralph Loop
**作用**: 自动化代理驱动开发
**安装量**: 1.1K installs

---

## 🚀 快速开始

### Superpowers - 自动技能检测

**何时使用**:
- 这个技能会在后台自动运行
- 你不需要手动激活它
- 它会在你工作时自动检测是否有其他技能适用

**工作原理**:
- 当你发送消息时，Superpowers会评估是否有相关的技能可用
- 如果有1%以上的可能性某个技能适用，它会自动调用
- 调用后显示: "Using [skill] to [purpose]"

**示例**:
```
你: "帮我创建一个React组件"
AI: "Using frontend-design to create a React component"
```

---

### Planning with Files - 文件化规划

**何时使用**:
- 多步骤任务（3步以上）
- 研究任务
- 需要组织的复杂项目
- 跨越多个工具调用的任务

**核心概念**:
```
Context Window = RAM (易失性，有限)
Filesystem = Disk (持久化，无限)

→ 任何重要内容都要写入磁盘
```

**创建规划文件**:

在你的项目目录中创建三个文件:

```bash
# 1. 任务计划 (task_plan.md)
- 定义阶段和进度
- 记录决策和错误
- 追踪完成状态

# 2. 研究发现 (findings.md)
- 记录研究成果
- 存储发现信息
- 保存重要数据

# 3. 进度日志 (progress.md)
- 记录会话日志
- 保存测试结果
- 追踪工作历史
```

**模板位置**:
```
~/.agents/skills/planning-with-files/templates/
├── task_plan.md
├── findings.md
└── progress.md
```

**使用步骤**:

1. 复制模板到你的项目目录
2. 编辑task_plan.md定义你的任务阶段
3. 开始工作时先读取规划文件
4. 每完成一个阶段更新文件
5. 每有新发现写入findings.md

**关键规则**:

1. **先创建计划**: 永远不要在没有task_plan.md的情况下开始复杂任务
2. **2-行动规则**: 每执行2次查看/浏览/搜索操作后，立即保存关键发现
3. **决策前读取**: 做重大决定前先读取计划文件
4. **行动后更新**: 完成任何阶段后立即更新文件
5. **记录所有错误**: 每个错误都要记录到计划文件中

**使用示例**:

```bash
# 复制模板
cp ~/.agents/skills/planning-with-files/templates/task_plan.md ./
cp ~/.agents/skills/planning-with-files/templates/findings.md ./
cp ~/.agents/skills/planning-with-files/templates/progress.md ./

# 编辑任务计划
vim task_plan.md

# 开始工作
```

task_plan.md 示例:
```markdown
# 任务计划

## 目标
[你的任务目标]

## 阶段

### Phase 1: 需求分析
- [x] 收集需求
- [x] 分析现有代码
- [ ] 创建技术方案

### Phase 2: 实现功能
- [ ] 编写代码
- [ ] 单元测试
- [ ] 集成测试

### Phase 3: 部署验证
- [ ] 部署到测试环境
- [ ] 验证功能
- [ ] 性能测试

## 错误记录
| 错误 | 尝试 | 解决方案 |
|------|------|----------|
```

---

### Ralph Loop - 自动化代理开发

**何时使用**:
- 需要自动化开发流程
- 有多个功能需要实现
- 需要持续测试和验证

**前置要求**:

完成以下步骤（按顺序）:

1. **AI编码代理配置**
   ```bash
   curl -H "Accept: text/markdown" \
     https://fullstackrecipes.com/api/recipes/agent-setup
   ```

2. **用户故事设置**
   ```bash
   curl -H "Accept: text/markdown" \
     https://fullstackrecipes.com/api/recipes/user-stories-setup
   ```

3. **使用用户故事**
   ```bash
   curl -H "Accept: text/markdown" \
     https://fullstackrecipes.com/api/recipes/using-user-stories
   ```

4. **Ralph代理循环设置**
   ```bash
   curl -H "Accept: text/markdown" \
     https://fullstackrecipes.com/api/recipes/ralph-setup
   ```

**工作流程**:

1. 将功能定义为用户故事
2. 为每个故事添加可测试的验收标准
3. 运行AI代理循环
4. 代理实现功能并验证标准
5. 所有标准通过后继续下一个故事

**用户故事示例**:

```json
{
  "id": "feature-001",
  "title": "用户登录功能",
  "description": "用户可以使用邮箱和密码登录",
  "acceptance_criteria": [
    {
      "criteria": "显示登录表单",
      "test": "访问 /login 页面，检查是否存在邮箱和密码输入框"
    },
    {
      "criteria": "有效凭证可以登录",
      "test": "使用有效凭证提交表单，验证重定向到首页"
    },
    {
      "criteria": "无效凭证显示错误",
      "test": "使用无效凭证提交表单，验证显示错误消息"
    }
  ]
}
```

---

## 💡 使用技巧

### Superpowers技巧
- 信任自动检测: 让Superpowers帮你找到合适的技能
- 不要跳过技能调用: 即使觉得简单也要检查
- 优先级: 用户指令 > Superpowers > 默认系统提示

### Planning技巧
- **在项目目录创建文件，不是skill目录**
- 使用2-行动规则防止信息丢失
- 定期读取计划文件保持专注
- 记录所有错误和尝试
- 使用5问题重启测试验证上下文管理

### Ralph Loop技巧
- 完成前置步骤: 按顺序完成所有前置设置
- 明确验收标准: 每个标准都要可测试
- 持续集成: 自动化测试和验证流程
- 记录进度: 使用用户故事追踪功能完成度

---

## 🎯 实际场景示例

### 场景1: 创建新的Web应用
```
1. 使用Planning with Files创建项目计划
2. Superpowers自动调用frontend-design技能
3. 按计划逐阶段实现
4. 使用Ralph Loop自动化测试流程
```

### 场景2: 调试现有代码
```
1. Superpowers自动调用debugging技能
2. Planning记录调试过程和发现
3. 每次尝试更新进度和错误记录
4. 成功后更新计划文件
```

### 场景3: 研究新技术
```
1. Planning创建研究计划
2. 记录所有发现到findings.md
3. Superpowers可能调用相关技能
4. 整理研究成果到计划文件
```

---

## 📝 总结

| Skill | 主要用途 | 自动化程度 | 适用场景 |
|-------|---------|-----------|---------|
| Superpowers | 技能发现和调用 | 全自动 | 所有场景 |
| Planning | 任务规划和跟踪 | 半自动 | 复杂任务 |
| Ralph Loop | 自动化开发流程 | 需要配置 | 持续开发 |

## 🔗 相关资源

- Planning模板: `~/.agents/skills/planning-with-files/templates/`
- Ralph参考: `~/.agents/skills/ralph-loop/`
- 文档链接: https://skills.sh/
