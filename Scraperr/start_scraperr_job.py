#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Scraperr任务启动脚本
使用配置文件启动PocketCorn投资分析数据收集任务
"""

import json
import os
import sys
from datetime import datetime

def load_job_config():
    """加载Scraperr任务配置"""
    config_file = "scraperr_job_config.json"
    
    if not os.path.exists(config_file):
        print(f"❌ 配置文件不存在: {config_file}")
        return None
        
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)
            print(f"✅ 已加载配置文件: {config['job_name']} v{config['version']}")
            return config
    except Exception as e:
        print(f"❌ 配置文件加载失败: {e}")
        return None

def validate_scraperr_environment():
    """验证Scraperr运行环境"""
    print("🔧 检查Scraperr环境...")
    
    # 检查必要的目录
    required_dirs = ['configs', 'data', 'api/backend']
    missing_dirs = []
    
    for dir_path in required_dirs:
        if not os.path.exists(dir_path):
            missing_dirs.append(dir_path)
    
    if missing_dirs:
        print(f"⚠️  缺少目录: {missing_dirs}")
    else:
        print("✅ 目录结构完整")
    
    # 检查配置文件
    config_files = [
        'configs/chinese_company_detection.json',
        'configs/mrr_signals_config.json', 
        'configs/multi_dimension_scoring.json'
    ]
    
    for config_file in config_files:
        if os.path.exists(config_file):
            print(f"✅ 配置文件: {config_file}")
        else:
            print(f"❌ 缺少配置: {config_file}")
    
    return True

def create_scraperr_task_file(config):
    """创建Scraperr任务文件"""
    task_data = {
        "task_id": f"pocketcorn_investment_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        "name": config["job_name"],
        "type": "investment_analysis",
        "status": "pending",
        "created_at": datetime.now().isoformat(),
        "config": config,
        "targets": config["target_companies"],
        "sources": len(config["data_sources"]),
        "expected_completion": "2-4 hours"
    }
    
    # 保存任务文件到data目录
    task_file = f"data/scraperr_task_{task_data['task_id']}.json"
    
    try:
        # 确保data目录存在
        os.makedirs('data', exist_ok=True)
        
        with open(task_file, 'w', encoding='utf-8') as f:
            json.dump(task_data, f, ensure_ascii=False, indent=2)
        
        print(f"📋 任务文件已创建: {task_file}")
        return task_file
        
    except Exception as e:
        print(f"❌ 任务文件创建失败: {e}")
        return None

def generate_scraperr_commands(config):
    """生成Scraperr执行命令"""
    print("\\n🚀 Scraperr执行指南:")
    print("="*50)
    
    print("\\n1️⃣ 启动Scraperr平台:")
    print("   如果是Next.js应用:")
    print("   npm run dev")
    print("   或者")  
    print("   yarn dev")
    print()
    print("   如果是Python FastAPI:")
    print("   python api/backend/main.py")
    print("   或者")
    print("   uvicorn main:app --reload")
    
    print("\\n2️⃣ 配置抓取任务:")
    print(f"   • 任务名称: {config['job_name']}")
    print(f"   • 目标企业: {len(config['target_companies'])}家")
    print(f"   • 数据源: {len(config['data_sources'])}个")
    print(f"   • 调度方式: {config['schedule']['type']} at {config['schedule']['time']}")
    
    print("\\n3️⃣ 数据源配置:")
    for i, source in enumerate(config['data_sources'], 1):
        print(f"   {i}. {source['name']}")
        print(f"      URL: {source['base_url']}")
        print(f"      频率限制: {source['rate_limit']['requests_per_minute']} req/min")
        print()
    
    print("4️⃣ 输出设置:")
    print(f"   • 格式: {config['output_settings']['format']}")
    print(f"   • 文件命名: {config['output_settings']['file_naming']}")
    print(f"   • 实时警报: {'启用' if config['output_settings']['real_time_alerts']['high_value_targets'] else '禁用'}")
    
    print("\\n5️⃣ 监控面板访问:")
    print("   • Web界面: http://localhost:3000 (如果是Next.js)")
    print("   • API文档: http://localhost:8000/docs (如果是FastAPI)")
    print("   • 任务状态: 检查data/目录下的任务文件")

def main():
    """主函数"""
    print("🎯 启动Scraperr - PocketCorn投资分析任务配置")
    print("="*60)
    
    # 1. 验证环境
    if not validate_scraperr_environment():
        print("❌ 环境检查失败")
        return
    
    # 2. 加载配置
    config = load_job_config()
    if not config:
        return
    
    # 3. 创建任务文件
    task_file = create_scraperr_task_file(config)
    if not task_file:
        return
    
    # 4. 生成执行指南
    generate_scraperr_commands(config)
    
    print("\\n✅ Scraperr任务配置完成!")
    print("\\n💡 下一步:")
    print("   1. 启动Scraperr平台服务")
    print("   2. 在平台界面中导入任务配置")
    print("   3. 开始数据收集") 
    print("   4. 监控收集进度")
    print("   5. 分析收集结果")

if __name__ == "__main__":
    main()