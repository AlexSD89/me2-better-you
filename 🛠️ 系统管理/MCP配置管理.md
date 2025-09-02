# MCP配置管理

## 📋 概述
本文档整合LaunchX系统中的MCP（Model Context Protocol）配置管理内容，提供统一的MCP服务器配置标准和流程。

## 🏗️ MCP服务器架构

### 当前MCP服务器列表
```yaml
MCP服务器集群:
  - hn-server: "Hacker News内容抓取服务器"
  - MediaCrawler: "社交媒体爬虫服务器"
  - shadcn-ui-server: "shadcn/ui组件访问服务器"
  - serena: "Serena本地服务器"
  - git-mcp: "Git操作服务器"
```

## 📁 服务器配置详情

### 1. hn-server
- **功能**: 获取Hacker News的热门故事、新故事、问答、展示和招聘信息
- **技术栈**: Node.js + TypeScript
- **启动**: `npm run build` → `node build/index.js`
- **用途**: 获取最新的技术趋势和创业信息
- **状态**: ✅ 正常工作

### 2. MediaCrawler
- **功能**: 抓取抖音、微博、知乎、小红书等社交媒体平台内容
- **技术栈**: Python + Selenium
- **启动**: `uv run main.py`
- **用途**: 社交媒体内容分析和趋势监控
- **状态**: ✅ 已配置

### 3. shadcn-ui-server
- **功能**: 提供 shadcn/ui v4 组件源码、演示和元数据访问
- **技术栈**: Node.js + NPM Package Wrapper
- **启动**: `npm start` 或 `npx @jpisnice/shadcn-ui-mcp-server`
- **用途**: AI 辅助 UI 开发，提供高质量 React 组件
- **状态**: ✅ 新集成
- **特性**: 
  - 支持所有 shadcn/ui 组件和区块
  - GitHub Token 支持（5000请求/小时）
  - 智能组件推荐和最佳实践

### 4. serena
- **功能**: Serena本地服务器
- **状态**: ✅ 已配置

### 5. git-mcp
- **功能**: Git操作服务器
- **状态**: ✅ 已配置

## 🔧 配置管理

### 配置文件位置
- **主配置**: `💻 技术开发/02_开发工具 🛠️/mcp-servers/README.md`
- **服务器目录**: `💻 技术开发/02_开发工具 🛠️/mcp-servers/`

### 配置标准
1. **统一启动方式**: 每个服务器都有独立的启动脚本
2. **环境变量管理**: 敏感信息通过环境变量配置
3. **权限控制**: 根据需要调整autoApprove权限设置
4. **日志监控**: 关注服务器运行日志，及时处理错误

## 📊 服务器状态监控

### 实时状态
```json
{
  "active_mcp_servers": 5,
  "total_configured_servers": 5,
  "last_health_check": "2025-01-27T15:30:00Z",
  "critical_services": {
    "hn-server": "✅ 运行中",
    "MediaCrawler": "✅ 运行中",
    "shadcn-ui-server": "✅ 运行中",
    "serena": "✅ 运行中",
    "git-mcp": "✅ 运行中"
  }
}
```

## 🛠️ 维护指南

### 日常维护
1. **更新依赖**: 定期更新各服务器的依赖包
2. **API密钥**: 及时更新过期的API密钥
3. **日志监控**: 关注服务器运行日志，及时处理错误
4. **性能优化**: 根据使用情况调整服务器配置

### 故障处理
1. **连接问题**: 检查网络连接和防火墙设置
2. **权限问题**: 验证API密钥和访问权限
3. **资源问题**: 检查服务器资源使用情况
4. **配置问题**: 验证配置文件格式和内容

## 📚 相关文档

- [MCP服务器集合](../💻 技术开发/02_开发工具 🛠️/mcp-servers/README.md)
- [系统配置总览](./系统配置/系统配置总览.md)
- [环境配置管理](./环境配置/README.md)

## 🔗 外部链接

- [MCP官方文档](https://modelcontextprotocol.io/)
- [Cursor MCP集成](https://cursor.sh/docs/mcp)

---

**最后更新**: 2025-01-27  
**版本**: v1.0  
**维护者**: LaunchX系统管理团队


