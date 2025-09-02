# 命令开发模板

基于awesome-claude-code的LaunchX命令开发标准模板

## 📄 命令文件模板

```markdown
# [命令名称] - [简短功能描述]

## 概述

### 功能说明
[详细描述命令的功能和使用场景，解释为什么需要这个命令]

### 适用场景
- **主要场景**: [核心使用场景]
- **次要场景**: [其他相关场景]
- **不适用场景**: [明确不适合的场景]

### 复杂度级别
- **任务级别**: [S/A/B/C级]
- **预期时间**: [执行时间估计]
- **资源需求**: [所需的MCP服务和Agent]

## 语法格式

### 基础语法
```bash
/[command-name] "[主要参数]" [可选参数] [--flag]
```

### 完整语法
```bash
/[command-name] "[输入内容]" 
  --depth [shallow|medium|deep] 
  --format [markdown|json|summary]
  --output [console|file]
  --async [true|false]
```

## 参数说明

### 必需参数
- **主要输入** (`string`): [参数说明和格式要求]
- **目标类型** (`enum`): [可选值和含义]

### 可选参数  
- **--depth** (`string`): 分析深度
  - `shallow`: 快速概览分析
  - `medium`: 标准深度分析  
  - `deep`: 全面深度分析
- **--format** (`string`): 输出格式
  - `markdown`: 结构化文档格式
  - `json`: 机器可读数据格式
  - `summary`: 简洁摘要格式
- **--output** (`string`): 输出目标
  - `console`: 控制台直接输出
  - `file`: 保存到文件
- **--async** (`boolean`): 是否异步执行

### 标志参数
- **--verbose**: 详细输出模式
- **--cache**: 启用缓存机制
- **--validate**: 启用结果验证

## 使用示例

### 基础用法
```bash
# 最简单的调用方式
/[command-name] "基本输入内容"
```

### 标准用法
```bash
# 推荐的标准使用方式
/[command-name] "详细输入内容" --depth medium --format markdown
```

### 高级用法
```bash
# 复杂场景的完整参数
/[command-name] "复杂输入内容" 
  --depth deep 
  --format json 
  --output file 
  --async true 
  --verbose
```

### 特殊用法
```bash
# 特定业务场景的使用方式
/[command-name] "特殊输入" --cache --validate
```

## Agent调用链

### 主要执行流程
```yaml
阶段1 - 输入处理:
  - Agent: [input-processor]
  - 功能: 解析和验证输入参数
  - 输出: 结构化任务描述

阶段2 - 核心处理:
  - Agent: [main-processor]  
  - 功能: 执行主要业务逻辑
  - 输出: 初步处理结果

阶段3 - 结果优化:
  - Agent: [result-optimizer]
  - 功能: 优化和格式化结果
  - 输出: 最终用户结果

阶段4 - 质量验证:
  - Agent: [quality-validator]
  - 功能: 验证结果质量和完整性
  - 输出: 质量报告和建议
```

### MCP服务调用
```yaml
搜索服务:
  - tavily-search: 实时搜索和数据收集
  - jina-reader: 内容解析和提取

数据访问:
  - workspace-filesystem: 工作区文件访问
  - [project]-data: 项目特定数据访问

专业服务:
  - smithery-tools: API测试和验证
  - [domain]-specific: 领域专用服务
```

## 输出格式

### 标准输出结构
```markdown
# [命令执行结果标题]

## 📊 执行摘要
- 任务: [任务描述]
- 状态: [成功/失败/部分成功]
- 耗时: [执行时间]
- 质量评分: [1-10分]

## 🎯 核心结果
[主要输出内容，根据业务需求定制]

## 📋 详细分析
[详细的分析过程和结果]

## ⚠️ 注意事项
[重要提醒和风险提示]

## 💡 后续建议
[基于结果的行动建议]
```

### JSON输出格式
```json
{
  "command": "[command-name]",
  "timestamp": "2025-08-15T12:30:00Z",
  "execution_time": 180,
  "status": "success",
  "quality_score": 8.5,
  "results": {
    "summary": "[简要摘要]",
    "details": { [详细结果数据] },
    "recommendations": ["建议1", "建议2"]
  },
  "metadata": {
    "agents_used": ["agent1", "agent2"],
    "mcp_services": ["service1", "service2"],
    "input_parameters": { [输入参数记录] }
  }
}
```

## 错误处理

### 常见错误类型
1. **输入验证错误**: 参数格式不正确
2. **MCP服务错误**: 外部服务调用失败
3. **Agent执行错误**: Agent处理过程出错
4. **资源限制错误**: 超出系统资源限制

### 错误处理策略
```yaml
错误恢复机制:
  - 参数错误: 提供纠正建议和示例
  - 服务错误: 自动重试和降级方案
  - 处理错误: 部分结果返回和问题诊断
  - 资源错误: 优化策略建议

用户友好性:
  - 错误信息清晰易懂
  - 提供具体的解决步骤
  - 包含相关文档链接
  - 记录详细错误日志供调试
```

## 性能优化

### 性能指标
- **响应时间**: [目标响应时间]
- **成功率**: [目标成功率，如>95%]
- **用户满意度**: [目标满意度评分]
- **资源利用率**: [CPU/内存/网络使用目标]

### 优化策略
```yaml
缓存机制:
  - 搜索结果缓存: 避免重复API调用
  - 处理结果缓存: 相似任务结果复用
  - 配置缓存: 减少初始化时间

并发优化:
  - 多MCP服务并发调用
  - Agent并行处理能力
  - 异步执行支持

资源管理:
  - 内存使用优化
  - 网络请求频率控制
  - 文件IO操作优化
```

## 测试策略

### 单元测试
```bash
# 基础功能测试
test_basic_functionality() {
  result = execute_command("/[command-name] 'test input'")
  assert result.status == "success"
  assert result.quality_score > 7.0
}

# 错误处理测试
test_error_handling() {
  result = execute_command("/[command-name] ''")  # 空输入
  assert result.status == "error"
  assert "input required" in result.error_message
}
```

### 集成测试
```bash
# Agent协作测试
test_agent_collaboration() {
  # 测试多Agent协作流程
}

# MCP服务集成测试  
test_mcp_integration() {
  # 测试外部服务调用
}
```

## 维护和更新

### 版本管理
- **版本格式**: `v[major].[minor].[patch]`
- **更新频率**: 根据用户反馈和业务需求
- **兼容性**: 保持向后兼容性

### 监控指标
- 使用频率统计
- 错误率趋势分析
- 性能指标变化
- 用户反馈收集

## 相关资源

### 文档链接
- [Agent开发指南](../agents/README.md)
- [MCP集成文档](../mcp-integrations/README.md)
- [Hook系统说明](../hooks-automation/README.md)

### 示例参考
- [现有命令实现](../commands/)
- [工作流模板](../workflows/)
- [最佳实践案例](../../ORCHESTRATION_GUIDE.md)

---

**模板版本**: v1.0  
**适用范围**: LaunchX项目所有命令开发  
**维护标准**: 基于awesome-claude-code社区最佳实践