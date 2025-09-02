#!/bin/bash

# Shadcn UI MCP Server 安装脚本
# 用于快速安装和配置 shadcn-ui MCP 服务器

echo "🚀 开始安装 Shadcn UI MCP 服务器..."

# 检查 Node.js 是否已安装
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，请先安装 Node.js"
    exit 1
fi

# 检查 npm 是否已安装
if ! command -v npm &> /dev/null; then
    echo "❌ NPM 未安装，请先安装 NPM"
    exit 1
fi

# 进入服务器目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📦 安装依赖包..."
npm install

echo "🔧 设置执行权限..."
chmod +x index.js

# 检查是否设置了 GitHub Token
if [ -z "$GITHUB_API_KEY" ] && [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  警告: 未设置 GitHub API Token"
    echo "   默认限制: 60 请求/小时"
    echo "   设置 Token 可提升到: 5000 请求/小时"
    echo ""
    echo "   设置方法:"
    echo "   export GITHUB_API_KEY=your_github_token"
    echo "   或在 .env 文件中添加"
else
    echo "✅ 检测到 GitHub Token，将使用高级限制 (5000 请求/小时)"
fi

echo ""
echo "🎉 Shadcn UI MCP 服务器安装完成!"
echo ""
echo "📋 使用方法:"
echo "  启动服务器: npm start"
echo "  直接运行: npx @jpisnice/shadcn-ui-mcp-server"
echo ""
echo "🔧 MCP 客户端配置:"
echo "  请将以下配置添加到您的 MCP 客户端配置文件中:"
echo ""
echo "  Claude Desktop (~/.config/claude/mcp_config.json):"
echo '  {
    "mcpServers": {
      "shadcn-ui": {
        "transport": "stdio",
        "command": "node",
        "args": ["'$SCRIPT_DIR'/index.js"],
        "env": {
          "GITHUB_API_KEY": "your_github_token"
        }
      }
    }
  }'
echo ""
echo "✨ 开始享受 AI 辅助的 shadcn/ui 开发体验吧!"