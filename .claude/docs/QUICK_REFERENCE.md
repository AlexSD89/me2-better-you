# LaunchX 快速参考手册

> 基于awesome-claude-code的LaunchX系统快速操作指南

## 🚀 即用命令

### 投资分析
```bash
/smart-research "分析[行业]投资机会"
/investment-spelo "[企业名称]" --depth deep
/seven-dimension "[投资标的]" --format json
/risk-quantify "[投资项目]" --comprehensive
```

### 平台开发
```bash
/zhilink-develop "[功能描述]" --priority high
/code-analysis "[代码路径]" --security-check
/performance-test "[模块名称]" --benchmark
/create-docs "[项目模块]" --format technical
```

### 系统运维
```bash
/system-monitor --health-check --performance
/log-analysis --error-pattern --last-24h
/auto-backup --incremental --verify
/optimize --memory --database --cache
```

## 🤖 常用Agent调用

### 投资分析Agent
```typescript
// 市场研究
Task(market-research-analyst): "深度分析智能制造AI投资机会"

// 风险评估  
Task(risk-manager): "量化区块链投资风险，提供缓解策略"

// 趋势预测
Task(trend-researcher): "识别2024年AI技术投资趋势"

// SPELO分析
Task(methodology-fusion-analyst): "应用SPELO方法论评估独角兽企业"
```

### 开发工程Agent
```typescript
// AI算法开发
Task(ai-engineer): "设计智能推荐算法，集成到Zhilink平台"

// 后端架构
Task(backend-architect): "优化API性能，支持高并发用户访问"

// 前端开发
Task(frontend-developer): "实现响应式设计，符合Cloudsway规范"

// 安全审计
Task(security-auditor): "全面安全审查，确保企业级安全标准"
```

## 📊 MCP服务速查

### 搜索分析
```json
{
  "tavily-search": "实时搜索，市场数据收集",
  "jina-reader": "文档解析，内容提取",
  "workspace-filesystem": "文件访问，代码分析"
}
```

### 项目数据
```json
{
  "pocketcorn-data": "投资分析引擎数据库",
  "zhilink-platform": "AI平台代码仓库", 
  "knowledge-base": "知识库和研究资料",
  "methodology-library": "方法论和框架库"
}
```

## ⚡ Hook触发机制

### 智能路由关键词
```yaml
投资分析触发词:
  - "投资", "分析", "评估", "风险"
  - "SPELO", "7维度", "独角兽"
  - "市场", "趋势", "机会"

平台开发触发词:
  - "开发", "功能", "优化", "实现"
  - "Zhilink", "平台", "系统"
  - "前端", "后端", "API"

研究分析触发词:
  - "研究", "调研", "报告", "数据"
  - "搜索", "分析", "整理"
  - "市场", "竞品", "技术"
```

### 复杂度自动识别
```yaml
S级关键词: "架构", "重构", "核心", "关键", "战略"
A级关键词: "功能", "模块", "组件", "优化", "集成"  
B级关键词: "修复", "调试", "更新", "维护", "配置"
C级关键词: "格式", "清理", "备份", "日志", "文档"
```

## 🎯 工作流快速选择

| 需求类型 | 推荐工作流 | 预期时间 | 复杂度 |
|----------|------------|----------|--------|
| 投资决策 | SPELO投资分析 | 8-15分钟 | S级 |
| 市场研究 | 趋势研究流程 | 5-10分钟 | A级 |
| 功能开发 | Zhilink开发流程 | 10-20分钟 | A级 |
| 代码优化 | 质量优化流程 | 3-8分钟 | B级 |
| 系统监控 | 健康监控流程 | 2-5分钟 | B级 |
| 问题修复 | 错误诊断流程 | 3-8分钟 | B级 |

## 📋 质量标准速查

### 投资分析质量标准
```yaml
数据质量:
  - 覆盖度 >90%
  - 时效性 <24小时
  - 来源权威性 >85%

分析质量:
  - SPELO评分一致性 >85%
  - 风险识别准确率 >95%
  - 投资建议明确度 >90%
```

### 开发质量标准
```yaml
代码质量:
  - 测试覆盖率 >90%
  - 代码规范符合度 100%
  - 安全漏洞数量 = 0

性能质量:
  - API响应时间 <200ms
  - 页面加载时间 <3秒
  - 系统可用性 >99.9%
```

## 🔧 常见问题解决

### Hook执行问题
```bash
# 检查Hook权限
chmod +x .claude/hooks/*.sh

# 验证Hook配置
claude config get hooks

# 查看Hook日志
tail -f .claude/logs/hooks.log
```

### MCP服务问题
```bash
# 检查MCP服务状态
claude mcp list

# 重启MCP服务
claude mcp reload

# 验证API密钥
curl -H "Authorization: Bearer $API_KEY" $SERVICE_URL/health
```

### Agent调用问题
```bash
# 查看可用Agent
claude agent list

# 验证Agent配置
claude agent validate [agent-name]

# 查看Agent执行日志
tail -f .claude/logs/agent-execution.log
```

## 📚 学习资源快速访问

### 核心文档
- [技术文档中心](./README.md) - 完整技术资源概览
- [智能编排系统](../ORCHESTRATION_GUIDE.md) - 系统架构详解
- [系统测试报告](../SYSTEM_TEST_REPORT.md) - 性能和功能验证

### 模板资源
- [Agent开发模板](./templates/agent-template.md)
- [命令开发模板](./templates/command-template.md)
- [工作流程模板](./workflows/README.md)

### 外部资源
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
- [Claude Code官方文档](https://docs.anthropic.com/en/docs/claude-code)
- [MCP协议规范](https://docs.anthropic.com/en/docs/claude-code/mcp)

## 🎪 实战技巧

### 高效使用技巧
1. **组合使用**: 多个命令串联使用，形成完整工作流
2. **参数优化**: 根据具体需求调整深度和输出格式
3. **缓存利用**: 相似任务使用缓存结果，提高效率
4. **异步执行**: 长时间任务使用异步模式，避免等待

### 错误避免
1. **输入验证**: 确保输入格式正确，避免参数错误
2. **权限检查**: 验证必要的文件和服务访问权限
3. **资源限制**: 注意API调用频率限制和系统资源使用
4. **版本兼容**: 确保Agent和MCP服务版本兼容

### 性能优化
1. **批量处理**: 相似任务批量执行，减少初始化开销
2. **并发利用**: 利用系统并发能力，提高处理效率
3. **结果复用**: 保存和复用中间结果，避免重复计算
4. **监控调优**: 定期查看性能监控，及时优化瓶颈

---

**快速参考版本**: v1.0  
**更新时间**: 2025年8月15日  
**适用系统**: LaunchX Claude Code智能编排系统

> 💡 **提示**: 这是一个动态文档，会根据系统使用情况和用户反馈持续更新。建议收藏此页面，作为日常工作的快速参考指南。