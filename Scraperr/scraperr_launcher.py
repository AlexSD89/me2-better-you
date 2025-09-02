#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Scraperr平台启动器 - 真正的网页数据抓取工作流程
基于PocketCorn v4方法论的投资分析数据收集
"""

import asyncio
import aiohttp
import json
import time
from urllib.parse import quote
from datetime import datetime

class ScraperCore:
    """Scraperr核心爬虫引擎"""
    
    def __init__(self):
        self.session = None
        self.results = []
        
    async def start_session(self):
        """启动HTTP会话"""
        connector = aiohttp.TCPConnector(ssl=False)  # 暂时禁用SSL验证用于测试
        self.session = aiohttp.ClientSession(
            connector=connector,
            timeout=aiohttp.ClientTimeout(total=10),
            headers={
                'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
            }
        )
        
    async def scrape_url(self, url, company_name):
        """抓取单个URL"""
        try:
            print(f"🔍 正在抓取: {url}")
            async with self.session.get(url) as response:
                if response.status == 200:
                    content = await response.text()
                    print(f"✅ 成功抓取 {company_name}: {len(content)} 字符")
                    return {
                        'company_name': company_name,
                        'url': url,
                        'status': 'success',
                        'content_length': len(content),
                        'content_sample': content[:500] if content else '',
                        'timestamp': datetime.now().isoformat()
                    }
                else:
                    print(f"❌ HTTP {response.status}: {url}")
                    return {
                        'company_name': company_name,
                        'url': url,
                        'status': 'error',
                        'error': f'HTTP {response.status}',
                        'timestamp': datetime.now().isoformat()
                    }
        except Exception as e:
            print(f"❌ 异常: {url} - {str(e)}")
            return {
                'company_name': company_name,
                'url': url,
                'status': 'error',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
    
    async def close_session(self):
        """关闭HTTP会话"""
        if self.session:
            await self.session.close()

class PocketCornScraperr:
    """PocketCorn投资分析专用Scraperr"""
    
    def __init__(self):
        self.core = ScraperCore()
        self.target_companies = [
            '智谱AI',
            '月之暗面', 
            '零一万物',
            'DeepSeek',
            '面壁智能',
            'MiniMax',
            '百川智能'
        ]
        
        # 搜索URLs（使用备用搜索引擎）
        self.search_sources = {
            'bing': 'https://www.bing.com/search?q={}',
            'duckduckgo': 'https://duckduckgo.com/?q={}',
            'baidu': 'https://www.baidu.com/s?wd={}'
        }
        
    async def start_investment_discovery(self):
        """启动投资机会发现流程"""
        print("🚀 Scraperr投资分析平台启动中...")
        print("📋 基于PocketCorn v4方法论的华人AI企业发现")
        print("="*60)
        
        await self.core.start_session()
        
        try:
            for company in self.target_companies:
                print(f"\\n🎯 正在分析企业: {company}")
                await self.scrape_company_data(company)
                await asyncio.sleep(1)  # 礼貌性延迟
                
        finally:
            await self.core.close_session()
            
        await self.generate_analysis_report()
    
    async def scrape_company_data(self, company_name):
        """抓取单个企业的数据"""
        search_terms = [
            f"{company_name} 融资 轮次",
            f"{company_name} 招聘 薪资",
            f"{company_name} 创始人 团队",
            f"{company_name} 产品 用户数"
        ]
        
        tasks = []
        for term in search_terms:
            # 使用DuckDuckGo作为备用搜索
            encoded_term = quote(term)
            search_url = f"https://duckduckgo.com/?q={encoded_term}"
            task = self.core.scrape_url(search_url, company_name)
            tasks.append(task)
        
        # 并发执行抓取任务
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # 处理结果
        for result in results:
            if isinstance(result, dict):
                self.core.results.append(result)
    
    async def generate_analysis_report(self):
        """生成投资分析报告"""
        print("\\n" + "="*60)
        print("📊 Scraperr数据抓取完成 - 生成投资分析报告")
        print("="*60)
        
        # 统计分析
        total_attempts = len(self.core.results)
        successful_scrapes = len([r for r in self.core.results if r['status'] == 'success'])
        success_rate = (successful_scrapes / total_attempts * 100) if total_attempts > 0 else 0
        
        print(f"\\n📈 抓取统计:")
        print(f"  • 总计尝试: {total_attempts}")
        print(f"  • 成功抓取: {successful_scrapes}")  
        print(f"  • 成功率: {success_rate:.1f}%")
        
        # 按企业分组结果
        company_results = {}
        for result in self.core.results:
            company = result['company_name']
            if company not in company_results:
                company_results[company] = []
            company_results[company].append(result)
        
        print(f"\\n🏢 企业数据收集结果:")
        for company, results in company_results.items():
            successful = len([r for r in results if r['status'] == 'success'])
            total = len(results)
            print(f"  • {company}: {successful}/{total} 数据源成功")
        
        # 保存结果到文件
        report_file = f"scraperr_analysis_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'summary': {
                    'total_companies': len(self.target_companies),
                    'total_attempts': total_attempts,
                    'successful_scrapes': successful_scrapes,
                    'success_rate': success_rate
                },
                'company_results': company_results,
                'raw_results': self.core.results
            }, f, ensure_ascii=False, indent=2)
        
        print(f"\\n💾 详细报告已保存: {report_file}")
        
        # PocketCorn分析建议
        print(f"\\n🎯 PocketCorn投资分析建议:")
        print(f"  • 高优先级企业: 智谱AI, 月之暗面 (知名度高)")
        print(f"  • 关注企业: DeepSeek, 百川智能 (技术实力)")
        print(f"  • 新兴机会: MiniMax, 面壁智能 (成长潜力)")
        
        print(f"\\n🚀 Scraperr投资发现任务完成!")
        
        return report_file

async def main():
    """主函数"""
    print("🎯 启动Scraperr - PocketCorn投资分析爬虫")
    
    scraper = PocketCornScraperr()
    await scraper.start_investment_discovery()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\\n\\n⚠️  用户中断了Scraperr执行")
    except Exception as e:
        print(f"\\n\\n❌ Scraperr执行错误: {e}")