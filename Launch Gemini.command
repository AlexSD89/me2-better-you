#!/bin/bash

# 切换到脚本所在目录
cd "$(dirname "$0")"

# 设置环境变量
export GEMINI_API_KEY="AIzaSyCU_Ze9ohX6Gvg8iaQLmTvo1YqYEKOBDiU"
export GOOGLE_CLOUD_PROJECT="macro-climber-454109-p4"

# 显示欢迎信息
echo "🚀 欢迎使用 Gemini CLI"
echo "📍 工作目录: $(pwd)"
echo ""

# 启动 Gemini CLI
gemini

# 保持终端窗口打开
echo ""
echo "按任意键退出..."
read -n 1 