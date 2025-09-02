#!/bin/bash
# PocketCorn投资分析系统快速启动脚本

echo "🚀 PocketCorn投资分析系统快速启动"
echo "基于PocketCorn v4方法论的华人AI企业发现系统"
echo "================================================"

# 检查Python版本
python_version=$(python3 --version 2>/dev/null || python --version 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ Python环境: $python_version"
else
    echo "❌ 未找到Python环境，请安装Python 3.8+"
    exit 1
fi

# 检查依赖包
echo -n "🔧 检查依赖包... "
python3 -c "
import json, sqlite3, asyncio
try:
    import aiohttp, requests
    print('✅ 核心依赖包已安装')
except ImportError as e:
    print(f'❌ 缺少依赖包: {e}')
    print('请运行: pip install aiohttp requests lxml')
    exit(1)
" || exit 1

# 检查配置文件
echo -n "📋 检查配置文件... "
if [ -f "configs/chinese_company_detection.json" ] && [ -f "configs/mrr_signals_config.json" ] && [ -f "configs/multi_dimension_scoring.json" ]; then
    echo "✅ 配置文件完整"
else
    echo "❌ 配置文件缺失"
    exit 1
fi

# 运行测试
echo "🧪 运行系统测试..."
python3 test_pocketcorn.py
if [ $? -ne 0 ]; then
    echo "❌ 系统测试失败，请检查配置"
    exit 1
fi

echo ""
echo "🎉 系统准备就绪！"
echo ""
echo "💡 快速使用指南:"
echo "  1. 分析特定企业:"
echo "     python3 pocketcorn_data_collection.py --mode analysis --company '企业名称'"
echo ""  
echo "  2. 发现投资机会:"
echo "     python3 pocketcorn_data_collection.py --mode discovery --region china"
echo ""
echo "  3. 生成投资报告:"
echo "     python3 pocketcorn_data_collection.py --mode report"
echo ""
echo "  4. 持续监控模式:"
echo "     python3 pocketcorn_data_collection.py --mode monitoring --continuous"
echo ""
echo "📚 详细使用说明请查看: README_PocketCorn.md"
echo ""

# 询问用户是否要运行示例
echo -n "🤔 是否运行示例分析? (y/n): "
read -r response
if [[ "$response" == "y" || "$response" == "Y" ]]; then
    echo "🔬 运行示例企业分析..."
    python3 pocketcorn_data_collection.py --mode analysis --company "智能科技公司" --region china
    echo ""
    echo "📊 生成示例报告..."
    python3 pocketcorn_data_collection.py --mode report --output example_report.md
    echo "✅ 示例完成！查看 example_report.md"
fi

echo ""
echo "🚀 PocketCorn系统启动完成！"
echo "Happy Investing! 🎯💰"