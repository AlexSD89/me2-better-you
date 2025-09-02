# 🎯 PocketCorn投资分析数据收集系统使用指南

## 📋 系统概述

本系统基于Scraperr平台和PocketCorn v4投资方法论，专门用于发现和分析华人AI企业的投资机会。系统通过多维度信号采集，实现对企业MRR、增长率、团队质量等关键投资指标的智能推断。

## 🎯 核心功能

### 1. 华人企业识别
- **多维度识别**: 姓名、教育背景、地理位置、语言模式
- **置信度评分**: 科学的置信度计算机制
- **全球覆盖**: 中国、美国、日本三大区域

### 2. MRR智能推断
- **五大信号源**: 招聘、产品、客户、技术、媒体
- **多模型融合**: 回归模型 + 规则模型 + 综合模型
- **置信度量化**: 基于信号质量和数量的置信度评估

### 3. 多维度评分
- **MRR评分 (40%)**: 基于财务信号的收入推断
- **媒体评分 (20%)**: 基于媒体报道和品牌影响力
- **赛道评分 (25%)**: 基于行业趋势和市场机会  
- **认知评分 (15%)**: 基于团队背景和技术能力

### 4. 投资决策支持
- **S-D级分级**: 专业的投资标的分级体系
- **风险评估**: 多层次风险控制机制
- **报告生成**: 自动化投资分析报告

## 🚀 快速开始

### 环境准备

```bash
# 1. 确保Python 3.8+环境
python --version

# 2. 安装依赖包
pip install aiohttp requests lxml sqlite3

# 3. 检查配置文件
ls configs/
```

### 基本使用

#### 1. 发现模式 - 自动发现投资机会
```bash
# 在中国区域发现投资机会
python pocketcorn_data_collection.py --mode discovery --region china

# 在美国区域发现投资机会  
python pocketcorn_data_collection.py --mode discovery --region us

# 在日本区域发现投资机会
python pocketcorn_data_collection.py --mode discovery --region japan
```

#### 2. 分析模式 - 分析指定企业
```bash
# 分析特定企业
python pocketcorn_data_collection.py --mode analysis --company "百度" --region china

# 分析美国华人企业
python pocketcorn_data_collection.py --mode analysis --company "ByteDance" --region us
```

#### 3. 监控模式 - 持续监控
```bash
# 单次监控扫描
python pocketcorn_data_collection.py --mode monitoring --region china

# 持续监控模式(每小时扫描)
python pocketcorn_data_collection.py --mode monitoring --continuous --region china
```

#### 4. 报告生成 - 生成投资报告
```bash
# 生成投资分析报告
python pocketcorn_data_collection.py --mode report --output investment_report.md

# 查看报告
cat investment_report.md
```

## 📁 配置文件说明

### 1. chinese_company_detection.json
华人企业识别配置，包含：
- **chinese_identity_signals**: 华人身份识别信号
  - `chinese_names`: 中文姓名模式
  - `education_background`: 教育背景识别
  - `geographic_indicators`: 地理位置指标
  - `language_patterns`: 语言模式识别
- **data_sources**: 数据源配置
  - `china_sources`: 中国数据源(智联招聘、36氪、企查查)
  - `us_sources`: 美国数据源(LinkedIn、Crunchbase、TechCrunch)  
  - `japan_sources`: 日本数据源(リクナビ、ITmedia)

### 2. mrr_signals_config.json  
MRR信号采集配置，包含：
- **signal_categories**: 信号分类
  - `recruiting_signals`: 招聘信号(30%权重)
  - `product_signals`: 产品信号(25%权重)
  - `customer_signals`: 客户信号(30%权重)
  - `technology_signals`: 技术信号(15%权重)
- **mrr_calculation_models**: MRR计算模型
  - `regression_model`: 回归模型
  - `rule_based_model`: 规则模型
  - `ensemble_model`: 综合模型

### 3. multi_dimension_scoring.json
多维度评分配置，包含：
- **scoring_dimensions**: 评分维度
  - `mrr_dimension`: MRR维度(40%权重)
  - `media_dimension`: 媒体维度(20%权重)  
  - `sector_dimension`: 赛道维度(25%权重)
  - `cognitive_dimension`: 认知维度(15%权重)
- **comprehensive_scoring**: 综合评分
  - `final_score_calculation`: 最终评分计算
  - `ranking_system`: S-D级分级体系

## 🎯 核心筛选标准

根据PocketCorn v4方法论，系统重点识别以下特征的企业：

### 财务指标
- ✅ **MRR**: ≥¥50,000/月
- ✅ **增长率**: ≥15%/月  
- ✅ **客户获取成本**: ≤MRR的3倍
- ✅ **客户生命周期价值**: ≥客户获取成本的5倍

### 团队指标
- ✅ **团队规模**: 3-10人(避免管理复杂性)
- ✅ **创始人背景**: 华人背景，相关行业经验
- ✅ **技术能力**: AI/ML专业能力
- ✅ **执行力**: 产品上线和客户获取记录

### 市场指标
- ✅ **市场规模**: TAM ≥ $10B
- ✅ **竞争格局**: 差异化优势，非红海市场
- ✅ **客户需求**: 真实痛点，付费意愿
- ✅ **增长潜力**: 爆发期或即将爆发

### 技术指标  
- ✅ **技术壁垒**: 独特技术优势或专利
- ✅ **产品成熟度**: MVP上线，实际用户
- ✅ **技术架构**: 可扩展，支持快速增长
- ✅ **数据资产**: 独特数据积累或算法

## 📊 数据源说明

### 中国数据源
- **招聘网站**: 智联招聘、拉勾网、Boss直聘
- **企业信息**: 企查查、天眼查、国家企业信用信息公示系统
- **新闻媒体**: 36氪、钛媒体、创业邦、IT桔子
- **社交媒体**: 微博、知乎、小红书

### 美国数据源  
- **招聘网站**: LinkedIn、Indeed、Glassdoor
- **企业信息**: Crunchbase、PitchBook、SEC EDGAR
- **新闻媒体**: TechCrunch、VentureBeat、The Information
- **社交媒体**: Twitter、LinkedIn、Reddit

### 日本数据源
- **招聘网站**: リクナビ、マイナビ、Indeed Japan
- **企业信息**: 帝国データバンク、東京商工リサーチ  
- **新闻媒体**: 日経新聞、ITmedia、CNET Japan
- **社交媒体**: Twitter Japan、LINE

## 🔧 高级配置

### 1. 自定义配置参数

```python
# 修改MRR阈值
"target_mrr_threshold": 80000,  # 提高到8万/月

# 调整权重配置
"signal_categories": {
    "recruiting_signals": {"weight": 0.35},  # 调整招聘信号权重
    "product_signals": {"weight": 0.25},
    "customer_signals": {"weight": 0.25},
    "technology_signals": {"weight": 0.15}
}

# 自定义置信度阈值
"confidence_scoring": {
    "high_confidence": {"min_score": 0.85},  # 提高高置信度阈值
    "medium_confidence": {"min_score": 0.65},
    "low_confidence": {"min_score": 0.45}
}
```

### 2. 添加新数据源

在配置文件中添加新的数据源：

```json
{
    "name": "新数据源",
    "url": "https://newsource.com",
    "xpath_selectors": {
        "company_name": "//h1[@class='company']/text()",
        "job_info": "//div[@class='job-info']//text()"
    }
}
```

### 3. 自定义评分规则

```json
"custom_rules": [
    {
        "condition": "github_stars > 5000 AND team_size < 15",
        "mrr_estimate": "200000-800000",
        "confidence": 0.9
    }
]
```

## 📈 输出示例

### 企业分析输出
```
📊 企业分析结果:
• 企业名称: AI创新科技
• 综合评分: 87.3/100 (🥇 A级)
• MRR估算: ¥85,000 /月
• 增长率: 22.5%
• 团队规模: 8人
• 华人置信度: 94.2%

📈 维度评分:
• MRR评分: 85.6/100
• 媒体评分: 78.2/100
• 赛道评分: 92.1/100
• 认知评分: 89.5/100
```

### 投资报告输出
生成的Markdown报告包含：
- 📊 执行摘要
- 🏆 Top 20 投资候选企业排名  
- 📈 详细分析和投资建议
- 🔍 市场趋势分析
- ⚠️ 风险提示

## ⚠️ 重要说明

### 数据准确性
- 所有MRR估算基于间接信号，**需要实地验证**
- 华人身份识别存在误差，**建议人工确认**  
- 评分模型持续优化中，**应结合人工判断**

### 使用建议
1. **S级企业**: 立即启动尽调，72小时内完成初评
2. **A级企业**: 2周内详细调研，准备投资方案
3. **B级企业**: 1个月内基础调研，列入观察名单
4. **C/D级企业**: 定期跟踪，等待改善机会

### 法律合规
- 所有数据收集遵循robots.txt规范
- 尊重网站使用条款和频率限制
- 不收集个人隐私敏感信息
- 仅用于投资研究分析目的

## 🛠️ 故障排除

### 常见问题

1. **配置文件加载失败**
   ```bash
   # 检查配置文件路径和格式
   python -c "import json; json.load(open('configs/chinese_company_detection.json'))"
   ```

2. **网络访问超时**
   ```bash
   # 设置代理或调整超时时间
   export HTTP_PROXY=http://proxy.company.com:8080
   ```

3. **数据库连接错误**
   ```bash
   # 检查数据库文件权限
   ls -la pocketcorn_data.db
   chmod 644 pocketcorn_data.db
   ```

4. **依赖包缺失**
   ```bash
   # 安装缺失的包
   pip install lxml aiohttp sqlite3
   ```

### 调试模式
```bash
# 开启详细日志
python pocketcorn_data_collection.py --mode analysis --company "测试企业" --verbose

# 查看日志文件
tail -f pocketcorn_collection.log
```

## 📚 扩展开发

### 添加新信号处理器
```python
class CustomSignalProcessor:
    def process_custom_signals(self, company_data: Dict) -> Dict:
        # 实现自定义信号处理逻辑
        return {"custom_score": 0.8}
```

### 自定义评分算法
```python  
def custom_scoring_algorithm(signals: Dict) -> float:
    # 实现自定义评分算法
    return weighted_score
```

### 集成新数据源API
```python
async def fetch_from_new_api(self, company_name: str) -> Dict:
    # 集成新的API数据源
    return api_data
```

## 🤝 支持与反馈

如需技术支持或提出改进建议，请：

1. 查看日志文件：`pocketcorn_collection.log`
2. 检查数据库状态：`sqlite3 pocketcorn_data.db`
3. 提交Issue或Pull Request

---

**系统版本**: PocketCorn v4.0  
**最后更新**: 2025-01-27  
**兼容性**: Python 3.8+ | Scraperr Platform  
**许可证**: MIT License