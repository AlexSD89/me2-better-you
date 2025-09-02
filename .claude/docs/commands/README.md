# LaunchX 命令系统

基于awesome-claude-code最佳实践的智能命令生态

## 📋 命令分类

### 🔍 研究分析类
- `/smart-research` - 智能研究编排系统
- `/market-analysis` - 市场分析工作流
- `/trend-scout` - 趋势侦察命令
- `/cross-validate` - 交叉验证工具

### 💼 投资决策类  
- `/investment-spelo` - SPELO投资分析流程
- `/seven-dimension` - 7维度评分系统
- `/risk-quantify` - 风险量化分析
- `/portfolio-optimize` - 投资组合优化

### 🏗️ 平台开发类
- `/zhilink-develop` - Zhilink平台开发
- `/feature-implement` - 功能实现工作流
- `/code-review` - 智能代码审查
- `/performance-test` - 性能测试套件

### 🔧 系统维护类
- `/system-optimize` - 系统优化工具
- `/auto-backup` - 自动备份机制
- `/health-check` - 健康状态检查
- `/log-analysis` - 日志分析工具

## 🚀 快速命令参考

```bash
# 投资分析
/smart-research "分析AI芯片行业投资机会"

# 平台开发
/zhilink-develop "添加智能推荐功能"

# 系统优化  
/performance-test "优化数据库查询性能"

# 风险控制
/risk-quantify "评估区块链投资风险"
```

## 📖 命令开发指南

### 1. 命令命名规范
- 使用动词-名词结构：`/action-target`
- 保持简洁易记：`/smart-research` 而非 `/intelligent-research-orchestrator`
- 符合业务场景：反映LaunchX的核心工作流

### 2. 参数设计原则
- 位置参数：核心输入（如搜索关键词）
- 可选参数：配置选项（如深度、格式）
- 标志参数：行为修饰符（如 --verbose, --async）

### 3. Agent集成策略
- 单一职责：每个命令对应明确的业务场景
- 智能路由：根据参数自动选择最优Agent组合
- 错误恢复：提供降级方案和错误处理

## 🎯 命令创建模板

参考 `templates/command-template.md` 创建新命令。