

# LayerX智能协作系统测试快速命令

## 🚀 一键启动完整测试
```bash
cd "/Users/dangsiyuan/Documents/obsidion/launch x"
./LayerX一键测试启动器.sh
```

## 📊 监控仪表板
```bash
open "LayerX测试实时监控仪表板.html"
```

## 🔍 手动执行测试
```bash
python3 "LayerX测试第1轮执行器.py"
```

## 📈 分析测试结果
```bash
# 使用实际结果
python3 "LayerX测试结果分析器.py" --test-file "LayerX测试结果/test_results.json" --generate-charts

# 使用演示数据
python3 "LayerX测试结果分析器.py" --generate-charts
```

## 🎯 测试成功标准
- 自动化程度: ≥85%
- 质量评分: ≥80% 
- 学习效果: ≥75%
- 总体成功率: ≥80%

## 📁 结果文件位置
- 测试报告: `LayerX测试结果/`
- 执行日志: `LayerX测试结果/layerx_test_execution_*.log`
- 可视化图表: `layerx_analysis_dashboard_*.png`

## 🔧 故障排除
```bash
# 检查权限
chmod +x "LayerX一键测试启动器.sh"

# 检查Python环境
python3 --version

# 查看详细日志
tail -f "LayerX测试结果/layerx_test_execution_*.log"
```