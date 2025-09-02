#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PocketCorn早期项目发现器 - 专门寻找MRR 5万以下的华人AI创业公司
基于真实Scraperr平台的定制化投资分析工具
"""

import asyncio
import aiohttp
import json
import time
from urllib.parse import quote
from datetime import datetime
import sqlite3

class EarlyStagePocketCornScraper:
    """早期华人AI项目专用爬虫"""
    
    def __init__(self):
        self.session = None
        self.results = []
        
        # 调整为早期项目画像 - MRR 5万以下，小团队
        self.search_patterns = {
            'early_stage_signals': [
                "天使轮 华人AI创业",
                "Pre-A轮 AI初创公司", 
                "种子轮 机器学习",
                "小团队 AI产品",
                "B端SaaS 月收入 3万",
                "AI工具 早期用户",
                "华人创始人 AI初创",
                "算法工程师 创业",
                "AI应用 MVP",
                "机器学习 原型"
            ],
            'mrr_indicators': [
                "月收入 2万-5万",
                "MRR 30000-50000", 
                "付费用户 100-500",
                "B端客户 10-50家",
                "SaaS订阅 月费",
                "企业服务 小客户",
                "API调用 付费",
                "软件授权 月订阅"
            ],
            'team_signals': [
                "团队 3-8人",
                "创始团队 技术背景",
                "CTO 华人",
                "算法负责人",
                "AI团队 清华北大",
                "海归创业 AI",
                "前大厂 AI工程师",
                "博士创业 机器学习"
            ]
        }
        
        # 专注寻找这类早期项目
        self.target_characteristics = {
            'revenue_range': '月收入2-5万人民币',
            'team_size': '3-8人小团队',
            'funding_stage': '天使轮/Pre-A轮',
            'business_model': 'B端SaaS/AI工具',
            'founder_background': '华人技术创始人',
            'product_stage': 'MVP/早期产品'
        }
        
    async def start_session(self):
        """启动HTTP会话"""
        connector = aiohttp.TCPConnector(ssl=False)
        self.session = aiohttp.ClientSession(
            connector=connector,
            timeout=aiohttp.ClientTimeout(total=15),
            headers={
                'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
        )
        
    async def search_early_stage_companies(self):
        """搜索早期阶段的华人AI公司"""
        print("🚀 PocketCorn早期项目发现器启动中...")
        print("🎯 目标画像: MRR 5万以下的华人AI创业公司")
        print("="*70)
        
        await self.start_session()
        
        try:
            # 搜索早期项目信号
            for category, patterns in self.search_patterns.items():
                print(f"\\n🔍 搜索类别: {category}")
                for pattern in patterns:
                    await self.scrape_search_results(pattern, category)
                    await asyncio.sleep(2)  # 避免过于频繁的请求
                    
        finally:
            await self.session.close()
            
        await self.analyze_early_stage_opportunities()
        
    async def scrape_search_results(self, search_term, category):
        """抓取搜索结果"""
        try:
            # 使用多个搜索引擎
            search_engines = [
                f"https://cn.bing.com/search?q={quote(search_term)}",
                f"https://www.so.com/s?q={quote(search_term)}",  # 360搜索
                f"https://www.sogou.com/web?query={quote(search_term)}"  # 搜狗
            ]
            
            for search_url in search_engines[:1]:  # 先测试一个搜索引擎
                print(f"  📊 搜索: {search_term}")
                result = await self.scrape_url(search_url, search_term, category)
                if result:
                    self.results.append(result)
                    
        except Exception as e:
            print(f"  ❌ 搜索失败: {search_term} - {str(e)}")
            
    async def scrape_url(self, url, search_term, category):
        """抓取单个URL"""
        try:
            async with self.session.get(url) as response:
                if response.status == 200:
                    content = await response.text()
                    
                    # 分析内容寻找早期项目信号
                    signals = self.extract_early_stage_signals(content, search_term)
                    
                    return {
                        'search_term': search_term,
                        'category': category,
                        'url': url,
                        'status': 'success',
                        'signals_found': signals,
                        'content_sample': content[:1000] if content else '',
                        'timestamp': datetime.now().isoformat()
                    }
                else:
                    return {
                        'search_term': search_term,
                        'category': category,
                        'url': url,
                        'status': 'error',
                        'error': f'HTTP {response.status}',
                        'timestamp': datetime.now().isoformat()
                    }
        except Exception as e:
            return {
                'search_term': search_term,
                'category': category,
                'url': url,
                'status': 'error',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
            
    def extract_early_stage_signals(self, content, search_term):
        """从内容中提取早期项目信号"""
        signals = []
        
        # 关键词匹配
        early_stage_keywords = [
            '天使轮', '种子轮', 'Pre-A', '初创', '创业团队',
            '月收入', 'MRR', '付费用户', 'SaaS', 'B端',
            '小团队', '华人创始人', 'CTO', '算法工程师',
            'MVP', '产品原型', 'beta测试', '早期用户'
        ]
        
        for keyword in early_stage_keywords:
            if keyword in content:
                signals.append({
                    'type': 'keyword_match',
                    'keyword': keyword,
                    'relevance': 'high' if keyword in search_term else 'medium'
                })
                
        return signals
        
    async def analyze_early_stage_opportunities(self):
        """分析早期投资机会"""
        print("\\n" + "="*70)
        print("📊 PocketCorn早期项目分析结果")
        print("="*70)
        
        # 统计分析
        total_searches = len(self.results)
        successful_searches = len([r for r in self.results if r['status'] == 'success'])
        
        print(f"\\n📈 搜索统计:")
        print(f"  • 搜索查询数: {total_searches}")
        print(f"  • 成功查询数: {successful_searches}")
        print(f"  • 成功率: {(successful_searches/total_searches*100) if total_searches > 0 else 0:.1f}%")
        
        # 信号分析
        all_signals = []
        for result in self.results:
            if result['status'] == 'success' and result.get('signals_found'):
                all_signals.extend(result['signals_found'])
                
        print(f"\\n🎯 发现的早期项目信号:")
        signal_counts = {}
        for signal in all_signals:
            keyword = signal['keyword']
            signal_counts[keyword] = signal_counts.get(keyword, 0) + 1
            
        for keyword, count in sorted(signal_counts.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  • {keyword}: {count} 次提及")
            
        # 保存结果
        report_file = f"pocketcorn_early_stage_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'target_profile': self.target_characteristics,
                'search_summary': {
                    'total_searches': total_searches,
                    'successful_searches': successful_searches,
                    'signals_found': len(all_signals)
                },
                'signal_analysis': signal_counts,
                'detailed_results': self.results
            }, f, ensure_ascii=False, indent=2)
            
        print(f"\\n💾 详细报告已保存: {report_file}")
        
        # 投资建议
        print(f"\\n🎯 PocketCorn早期投资建议:")
        print(f"  • 目标画像: {self.target_characteristics['revenue_range']}")
        print(f"  • 团队规模: {self.target_characteristics['team_size']}")
        print(f"  • 融资阶段: {self.target_characteristics['funding_stage']}")
        print(f"  • 商业模式: {self.target_characteristics['business_model']}")
        
        return report_file

async def main():
    """主函数 - 驱动Scraperr寻找早期项目"""
    print("🚀 启动PocketCorn早期项目发现器")
    print("🎯 基于Scraperr平台的专业投资分析工具")
    
    scraper = EarlyStagePocketCornScraper()
    await scraper.search_early_stage_companies()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\\n\\n⚠️  用户中断了早期项目发现")
    except Exception as e:
        print(f"\\n\\n❌ 发现器执行错误: {e}")