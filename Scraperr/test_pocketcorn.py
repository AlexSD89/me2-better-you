#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PocketCorn数据收集系统测试脚本
用于验证配置和功能是否正常工作
"""

import json
import sys
from pathlib import Path

def test_config_files():
    """测试配置文件是否正确加载"""
    print("🔧 测试配置文件...")
    
    config_dir = Path("configs")
    config_files = [
        "chinese_company_detection.json",
        "mrr_signals_config.json", 
        "multi_dimension_scoring.json"
    ]
    
    all_passed = True
    
    for config_file in config_files:
        config_path = config_dir / config_file
        try:
            if not config_path.exists():
                print(f"❌ 配置文件不存在: {config_file}")
                all_passed = False
                continue
                
            with open(config_path, 'r', encoding='utf-8') as f:
                config_data = json.load(f)
                
            # 基本结构检查
            if not config_data.get('name'):
                print(f"⚠️  {config_file}: 缺少name字段")
                all_passed = False
            
            if not config_data.get('version'):
                print(f"⚠️  {config_file}: 缺少version字段")
                all_passed = False
                
            print(f"✅ {config_file}: 格式正确")
            
        except json.JSONDecodeError as e:
            print(f"❌ {config_file}: JSON格式错误 - {e}")
            all_passed = False
        except Exception as e:
            print(f"❌ {config_file}: 读取错误 - {e}")
            all_passed = False
    
    return all_passed

def test_chinese_detection_config():
    """测试华人企业识别配置"""
    print("\n🎯 测试华人企业识别配置...")
    
    try:
        with open("configs/chinese_company_detection.json", 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        # 检查核心配置
        identity_signals = config.get('chinese_identity_signals', {})
        
        # 检查中文姓名配置
        chinese_names = identity_signals.get('chinese_names', {})
        if not chinese_names.get('patterns'):
            print("❌ 缺少中文姓名模式配置")
            return False
        
        patterns = chinese_names.get('patterns', [])
        print(f"✅ 中文姓名模式: {len(patterns)}个")
        
        # 检查教育背景配置
        education = identity_signals.get('education_background', {})
        unis = education.get('chinese_universities', [])
        print(f"✅ 中国大学: {len(unis)}所")
        
        # 检查地理位置配置
        geographic = identity_signals.get('geographic_indicators', {})
        locations = geographic.get('chinese_locations', [])
        print(f"✅ 地理位置: {len(locations)}个")
        
        # 检查数据源配置
        data_sources = config.get('data_sources', {})
        china_sources = data_sources.get('china_sources', {})
        us_sources = data_sources.get('us_sources', {})
        japan_sources = data_sources.get('japan_sources', {})
        
        print(f"✅ 中国数据源: {len(china_sources)}类")
        print(f"✅ 美国数据源: {len(us_sources)}类")  
        print(f"✅ 日本数据源: {len(japan_sources)}类")
        
        return True
        
    except Exception as e:
        print(f"❌ 华人企业识别配置测试失败: {e}")
        return False

def test_mrr_signals_config():
    """测试MRR信号配置"""
    print("\n💰 测试MRR信号配置...")
    
    try:
        with open("configs/mrr_signals_config.json", 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        # 检查目标阈值
        target_mrr = config.get('target_mrr_threshold', 0)
        target_growth = config.get('target_growth_rate', 0)
        print(f"✅ 目标MRR阈值: ¥{target_mrr:,}/月")
        print(f"✅ 目标增长率: {target_growth*100:.1f}%")
        
        # 检查信号分类
        signal_categories = config.get('signal_categories', {})
        for category, details in signal_categories.items():
            weight = details.get('weight', 0)
            indicators = details.get('indicators', {})
            print(f"✅ {category}: 权重{weight*100:.0f}%, {len(indicators)}个指标")
        
        # 检查计算模型
        models = config.get('mrr_calculation_models', {})
        for model_name, model_config in models.items():
            print(f"✅ {model_name}: 已配置")
        
        return True
        
    except Exception as e:
        print(f"❌ MRR信号配置测试失败: {e}")
        return False

def test_scoring_config():
    """测试评分配置"""
    print("\n📊 测试多维度评分配置...")
    
    try:
        with open("configs/multi_dimension_scoring.json", 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        # 检查评分维度
        scoring_dimensions = config.get('scoring_dimensions', {})
        total_weight = 0
        
        for dimension, details in scoring_dimensions.items():
            weight = details.get('weight', 0)
            total_weight += weight
            description = details.get('description', '')
            print(f"✅ {dimension}: 权重{weight*100:.0f}% - {description}")
        
        # 检查权重总和
        if abs(total_weight - 1.0) < 0.01:
            print(f"✅ 权重配置正确: 总和 = {total_weight:.1f}")
        else:
            print(f"⚠️  权重配置异常: 总和 = {total_weight:.1f} (应为1.0)")
        
        # 检查分级系统
        ranking_system = config.get('comprehensive_scoring', {}).get('ranking_system', {})
        for tier, details in ranking_system.items():
            score_range = details.get('score_range', [])
            description = details.get('description', '')
            print(f"✅ {tier}级: {score_range[0]}-{score_range[1]}分 - {description}")
        
        return True
        
    except Exception as e:
        print(f"❌ 评分配置测试失败: {e}")
        return False

def test_dependencies():
    """测试依赖包"""
    print("\n📦 测试Python依赖包...")
    
    required_packages = [
        'json',
        'sqlite3', 
        'asyncio',
        'aiohttp',
        'requests'
    ]
    
    optional_packages = [
        'lxml'
    ]
    
    all_passed = True
    
    for package in required_packages:
        try:
            __import__(package)
            print(f"✅ {package}: 已安装")
        except ImportError:
            print(f"❌ {package}: 未安装 (必需)")
            all_passed = False
    
    for package in optional_packages:
        try:
            __import__(package)
            print(f"✅ {package}: 已安装")
        except ImportError:
            print(f"⚠️  {package}: 未安装 (可选，用于XPath解析)")
    
    return all_passed

def test_sample_analysis():
    """测试样本分析"""
    print("\n🧪 测试样本企业分析...")
    
    try:
        # 导入主要类
        sys.path.append('.')
        from pocketcorn_data_collection import ConfigManager, ChineseCompanyDetector
        
        # 初始化配置
        config_manager = ConfigManager()
        detector = ChineseCompanyDetector(
            config_manager.get_config('chinese_company_detection')
        )
        
        # 测试样本数据
        sample_company_data = {
            'company_name': '智能科技公司',
            'founder': '张伟，清华大学计算机博士，前百度高级工程师',
            'location': '北京中关村',
            'description': '专注于AI machine learning解决方案的创业公司',
            'team': '团队8人，主要来自清华北大，有丰富的人工智能开发经验',
            'product': '企业级SaaS产品，月活跃用户5万+',
            'news': '36氪报道：获得天使轮融资500万人民币'
        }
        
        # 执行华人身份识别
        is_chinese, confidence, factors = detector.detect_chinese_identity(sample_company_data)
        
        print(f"✅ 华人身份识别: {is_chinese}")
        print(f"✅ 置信度: {confidence*100:.1f}%")
        print(f"✅ 因素分析: {factors}")
        
        if is_chinese and confidence > 0.6:
            print("✅ 样本分析通过，系统工作正常")
            return True
        else:
            print("⚠️  样本分析未通过，可能需要调整配置")
            return False
            
    except Exception as e:
        print(f"❌ 样本分析测试失败: {e}")
        return False

def run_all_tests():
    """运行所有测试"""
    print("🚀 PocketCorn数据收集系统测试开始...\n")
    
    test_results = []
    
    # 配置文件测试
    test_results.append(("配置文件", test_config_files()))
    
    # 华人企业识别配置测试
    test_results.append(("华人企业识别", test_chinese_detection_config()))
    
    # MRR信号配置测试  
    test_results.append(("MRR信号配置", test_mrr_signals_config()))
    
    # 评分配置测试
    test_results.append(("多维度评分配置", test_scoring_config()))
    
    # 依赖包测试
    test_results.append(("依赖包", test_dependencies()))
    
    # 样本分析测试
    test_results.append(("样本分析", test_sample_analysis()))
    
    # 输出测试结果汇总
    print("\n" + "="*50)
    print("📋 测试结果汇总:")
    print("="*50)
    
    passed_count = 0
    total_count = len(test_results)
    
    for test_name, passed in test_results:
        status = "✅ 通过" if passed else "❌ 失败"
        print(f"{test_name:15} {status}")
        if passed:
            passed_count += 1
    
    print("="*50)
    print(f"总计: {passed_count}/{total_count} 测试通过")
    
    if passed_count == total_count:
        print("🎉 所有测试通过，系统可以正常使用！")
        print("\n🚀 使用建议:")
        print("   python pocketcorn_data_collection.py --mode analysis --company '测试企业'")
        print("   python pocketcorn_data_collection.py --mode report")
    else:
        print("⚠️  部分测试失败，请检查配置或安装依赖包")
        
    return passed_count == total_count

if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)