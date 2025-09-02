# LaunchX Claude Code 技术文档中心

> 基于 [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) 的LaunchX专用技术资源库

**项目性质**: 零代码背景AI协作开发系统  
**技术底座**: Claude Code + Subagent生态 + MCP工具链  
**核心能力**: 自然语言驱动的智能编排系统

---

## 📚 目录结构

```
.claude/docs/
├── README.md                    # 本文档 - 技术资源总览
├── 📋 commands/                 # 命令与工作流
│   ├── README.md               # 命令系统概述
│   ├── investment-analysis.md  # 投资分析工作流
│   ├── platform-development.md # 平台开发命令
│   └── research-workflow.md    # 研究工作流程
├── 🤖 agents/                  # Agent配置与指南  
│   ├── README.md               # Agent系统架构
│   ├── orchestration.md       # 编排策略指南
│   ├── best-practices.md      # Agent最佳实践
│   └── custom-agents.md       # 自定义Agent开发
├── 🔧 mcp-integrations/        # MCP服务器集成
│   ├── README.md               # MCP生态概述
│   ├── search-services.md     # 搜索服务集成
│   ├── data-sources.md        # 数据源配置
│   └── api-integrations.md    # API集成指南
├── ⚡ hooks-automation/        # Hook自动化系统
│   ├── README.md               # Hook系统原理
│   ├── task-routing.md        # 任务路由策略
│   ├── performance-monitoring.md # 性能监控
│   └── quality-control.md     # 质量控制机制
├── 📊 workflows/               # 工作流模板
│   ├── README.md               # 工作流概述
│   ├── pocketcorn-investment.md # PocketCorn投资流程
│   ├── zhilink-development.md  # Zhilink开发流程
│   └── research-analysis.md   # 研究分析流程
└── 🎯 templates/               # 模板资源库
    ├── README.md               # 模板使用指南
    ├── project-structure.md   # 项目结构模板
    ├── agent-template.md      # Agent模板
    └── command-template.md    # 命令模板
```

---

## 🚀 快速开始

### 1. 基础设置
```bash
# 进入LaunchX工作目录
cd "/Users/dangsiyuan/Documents/obsidion/launch x"

# 验证系统配置
claude config get

# 测试MCP服务
claude mcp list
```

### 2. 核心工作流
```bash
# 投资分析
/smart-research "分析[行业]投资机会"

# 平台开发  
/code-analysis "优化[项目]性能"

# 文档生成
/create-docs "生成[模块]技术文档"
```

### 3. Agent调用
```bash
# 使用Task工具调用专业Agent
Task(market-research-analyst): "深度分析智能制造AI投资"
Task(concurrent-search-orchestrator): "多源搜索区块链趋势"
Task(methodology-fusion-analyst): "应用SPELO方法论评估"
```

---

## 📋 可用命令列表

### 核心工作流命令

| 命令 | 功能 | 使用场景 | 复杂度 |
|------|------|----------|--------|
| `/smart-research` | 智能研究编排 | 投资分析、市场研究 | S/A级 |
| `/code-analysis` | 代码分析优化 | 代码审查、性能优化 | A/B级 |
| `/commit` | 智能Git提交 | 版本控制 | B级 |
| `/optimize` | 系统优化 | 性能调优 | A级 |
| `/create-docs` | 文档生成 | 技术文档创建 | B级 |
| `/create-pr` | PR创建 | 代码审查流程 | B级 |
| `/todo` | 任务管理 | 项目进度跟踪 | C级 |
| `/tdd` | 测试驱动开发 | 质量保证 | A级 |
| `/clean` | 环境清理 | 维护操作 | C级 |

### LaunchX专用命令
```bash
# PocketCorn投资分析
/investment-spelo-analysis "[企业名称或行业]"

# Zhilink平台开发
/zhilink-feature-develop "[功能描述]"

# 7维度评分系统
/seven-dimension-scoring "[投资标的]"

# 智能上下文切换
/context-switch "[pocketcorn|zhilink|research]"
```

---

## 🤖 Agent生态系统

### 按领域分类

```yaml
数据分析类:
  - concurrent-search-orchestrator: 多层级并发搜索
  - cross-validation-engine: 交叉验证评分
  - methodology-fusion-analyst: 方法论融合分析
  - data-scientist: 量化数据分析

工程开发类:
  - ai-engineer: AI算法开发
  - backend-architect: 后端架构设计  
  - frontend-developer: 前端界面开发
  - security-auditor: 安全审计

投资分析类:
  - market-research-analyst: 市场研究分析
  - risk-manager: 风险评估管理
  - business-analyst: 商业分析
  - quant-analyst: 量化分析

项目管理类:
  - task-router: 智能任务路由
  - sprint-prioritizer: 冲刺优先级管理
  - project-shipper: 项目交付管理
  - performance-benchmarker: 性能基准测试
```

### Agent调用最佳实践

```typescript
// 1. 单一Agent调用
Task(market-research-analyst): "分析智能制造AI投资机会"

// 2. 多Agent协作
Task(concurrent-search-orchestrator): "搜索区块链投资数据" 
→ Task(cross-validation-engine): "验证数据质量"
→ Task(methodology-fusion-analyst): "应用SPELO评分"

// 3. 条件化Agent选择
if (complexity === "S级") {
  Task(methodology-fusion-analyst) + 多专家协作
} else if (domain === "investment") {
  Task(market-research-analyst)
}
```

---

## 🔧 MCP服务器集成

### 已配置的MCP服务

```json
{
  "搜索分析服务": {
    "tavily-search": "实时搜索和市场研究",
    "jina-reader": "智能内容提取和文档解析"
  },
  "开发工具服务": {
    "smithery-tools": "API测试和服务验证",
    "workspace-filesystem": "工作区文件访问"
  },
  "项目数据服务": {
    "pocketcorn-data": "投资分析引擎数据",
    "zhilink-platform": "AI平台代码访问",
    "knowledge-base": "知识库和研究资料"
  }
}
```

### API Keys配置

| 服务 | API Key | 状态 | 用途 |
|------|---------|------|------|
| Tavily | `tvly-dev-T5AC...` | ✅ 活跃 | 实时搜索 |
| Jina AI | `jina_6e538c64...` | ✅ 活跃 | 内容解析 |
| Smithery | `86ba62ee-5972...` | ✅ 活跃 | API测试 |

---

## ⚡ Hook自动化系统

### 3层Hook架构

```bash
1. UserPromptSubmit Hook
   ├── 任务复杂度分析 (S/A/B/C级)
   ├── 领域识别 (investment/platform/research)
   ├── Agent推荐算法
   └── 上下文智能切换

2. PreToolUse Hook  
   ├── MCP服务健康检查
   ├── 负载均衡策略
   ├── 权限验证机制
   └── 资源预分配

3. PostToolUse Hook
   ├── 结果质量评估 (1-10分)
   ├── 执行时间监控
   ├── 错误模式检测
   └── 优化建议生成
```

### Hook配置示例

```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "hooks": [{ 
        "type": "command",
        "command": ".claude/hooks/intelligent-task-router.sh"
      }]
    }],
    "PreToolUse": [{
      "matcher": "Task(*)",
      "hooks": [{
        "type": "command", 
        "command": ".claude/hooks/agent-orchestrator.sh"
      }]
    }],
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/result-validator.sh"
      }]
    }]
  }
}
```

---

## 📊 工作流模板

### PocketCorn投资分析流程

```yaml
阶段1 - 数据收集:
  - Agent: concurrent-search-orchestrator
  - MCP: tavily-search + jina-reader
  - 输出: 多维度市场数据

阶段2 - 交叉验证:
  - Agent: cross-validation-engine  
  - 方法: SPELO闭环验证
  - 输出: 验证后的可靠数据

阶段3 - 综合评估:
  - Agent: methodology-fusion-analyst
  - 方法: 7维度评分系统
  - 输出: 投资建议报告 (1-5分)

阶段4 - 风险控制:
  - Agent: risk-manager
  - 分析: 不确定性量化
  - 输出: 风险提示和缓解策略
```

### Zhilink平台开发流程

```yaml
阶段1 - 需求分析:
  - Agent: business-analyst
  - 输入: 自然语言功能描述
  - 输出: 结构化技术需求

阶段2 - 架构设计:
  - Agent: ai-engineer + backend-architect
  - 考虑: 6角色协作系统集成
  - 输出: 技术架构方案

阶段3 - 实现开发:
  - Agent: frontend-developer + backend-architect
  - 框架: Next.js + React + TypeScript
  - 输出: 可运行的功能模块

阶段4 - 质量保证:
  - Agent: test-writer-fixer + security-auditor
  - 标准: 企业级质量要求
  - 输出: 完整测试覆盖
```

---

## 🎯 模板资源库

### CLAUDE.md模板

```markdown
# [项目名称] Claude Code 指导文档

## 项目概述
- **性质**: [项目类型描述]
- **技术栈**: [主要技术]
- **目标**: [项目目标]

## 开发规范
- **代码风格**: [编码标准]
- **测试要求**: [测试覆盖标准]
- **文档标准**: [文档要求]

## AI协作规范
- **Agent使用**: [推荐Agent列表]
- **工作流程**: [标准开发流程]
- **质量控制**: [质量门禁标准]
```

### Agent模板

```yaml
---
name: custom-agent
description: "明确描述Agent的触发条件和使用场景"
tools: [Read, Write, WebSearch, Task]
priority: high
model: sonnet
department: [engineering|analysis|execution] 
task_level: [S|A|B|C]
iteration_target: 3
alignment_threshold: 0.8
---

你是[领域]专家，专门处理[具体职责]。

**核心职责**:
1. [主要功能描述]
2. [工作流程说明]
3. [输出标准要求]

**工作约束**:
- 必须参考CLAUDE.md确保任务对齐
- 输出格式必须结构化
- 所有决策过程必须可追溯
```

### 命令模板

```markdown
# [命令名称]

## 概述
简述命令功能和使用场景

## 语法
```bash
/command-name [参数1] [参数2] --flag
```

## 参数说明
- `参数1`: 必需参数说明
- `参数2`: 可选参数说明  
- `--flag`: 选项标志说明

## 使用示例
```bash
# 基础用法
/command-name "示例输入"

# 高级用法
/command-name "复杂输入" --advanced
```

## Agent调用链
1. [主要Agent] - [功能描述]
2. [协作Agent] - [功能描述]

## 输出格式
预期的输出格式和结构说明

## 最佳实践
使用建议和注意事项
```

---

## 📚 学习资源

### 官方文档
- [Claude Code官方文档](https://docs.anthropic.com/en/docs/claude-code)
- [MCP协议规范](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [Hook系统指南](https://docs.anthropic.com/en/docs/claude-code/hooks)

### 社区资源
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
- [Claude Code用户社区](https://discord.gg/claude-code)
- [最佳实践案例库](https://github.com/claude-code-examples)

### LaunchX专用资源
- `CLAUDE.md` - 主项目指导文档
- `ORCHESTRATION_GUIDE.md` - 智能编排系统指南  
- `SYSTEM_TEST_REPORT.md` - 系统测试报告

---

## 🚧 开发计划

### 待开发命令
- [ ] `/portfolio-analysis` - 投资组合分析
- [ ] `/risk-assessment` - 风险评估工具
- [ ] `/market-monitor` - 市场监控系统
- [ ] `/auto-deploy` - 自动化部署

### 待开发Agent
- [ ] `portfolio-optimizer` - 投资组合优化
- [ ] `trend-predictor` - 趋势预测分析
- [ ] `compliance-checker` - 合规性检查
- [ ] `performance-tracker` - 性能跟踪器

### 系统优化
- [ ] Hook执行性能优化
- [ ] MCP服务负载均衡
- [ ] Agent选择算法优化
- [ ] 缓存策略改进

---

**文档维护**: AI自动更新 + 人工审核  
**最后更新**: 2025年8月15日  
**版本**: v1.0.0  

> 💡 **提示**: 这是一个活跃发展的技术文档库。当你需要创建新的Agent、命令或工作流时，请参考这里的模板和最佳实践。所有资源都经过LaunchX项目验证，确保与我们的智能编排系统完美集成。