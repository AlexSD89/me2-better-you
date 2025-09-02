#!/usr/bin/env python3
"""
LayerX 5通道并发生产引擎
基于BMAD混合智能架构的自动化信息处理和知识生产系统
"""

import asyncio
import json
import time
import subprocess
from datetime import datetime
from typing import Dict, List, Any, Optional
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
import logging

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

@dataclass
class SearchResult:
    """搜索结果数据结构"""
    channel: str
    query: str
    results: List[Dict[str, Any]]
    timestamp: datetime
    quality_score: float
    source_count: int

@dataclass
class ChannelConfig:
    """通道配置"""
    name: str
    description: str
    tools: List[str]
    priority: int
    concurrent_queries: int
    quality_threshold: float

class FiveChannelConcurrentEngine:
    """5通道并发生产引擎"""
    
    def __init__(self, config_path: Optional[str] = None):
        self.config = self._load_config(config_path)
        self.channels = self._initialize_channels()
        self.active_searches = {}
        self.results_cache = {}
        self.executor = ThreadPoolExecutor(max_workers=10)
        
    def _load_config(self, config_path: Optional[str]) -> Dict[str, Any]:
        """加载配置文件"""
        default_config = {
            "max_concurrent_searches": 5,
            "quality_threshold": 7.5,
            "timeout_seconds": 120,
            "cache_duration": 3600,
            "bmad_optimization": True,
            "learning_enabled": True
        }
        
        if config_path:
            try:
                with open(config_path, 'r', encoding='utf-8') as f:
                    user_config = json.load(f)
                default_config.update(user_config)
            except FileNotFoundError:
                logger.warning(f"Config file {config_path} not found, using defaults")
        
        return default_config
    
    def _initialize_channels(self) -> Dict[str, ChannelConfig]:
        """初始化5个并发搜索通道"""
        return {
            "investment_discovery": ChannelConfig(
                name="投资发现通道",
                description="AI投资机会发现和分析",
                tools=["tavily-search", "python-sandbox", "workspace-filesystem"],
                priority=1,
                concurrent_queries=3,
                quality_threshold=8.0
            ),
            "tech_trends": ChannelConfig(
                name="技术趋势通道", 
                description="前沿技术发展趋势监控",
                tools=["tavily-search", "fetch", "jina-reader"],
                priority=2,
                concurrent_queries=2,
                quality_threshold=7.5
            ),
            "market_dynamics": ChannelConfig(
                name="市场动态通道",
                description="市场变化和商业机会分析",
                tools=["tavily-search", "firecrawl", "hotnews"],
                priority=2,
                concurrent_queries=2,
                quality_threshold=7.0
            ),
            "enterprise_needs": ChannelConfig(
                name="企业需求通道",
                description="企业服务需求和解决方案挖掘",
                tools=["tavily-search", "workspace-filesystem"],
                priority=3,
                concurrent_queries=2,
                quality_threshold=6.5
            ),
            "knowledge_synthesis": ChannelConfig(
                name="知识沉淀通道",
                description="方法论提取和经验总结",
                tools=["workspace-filesystem", "knowledge-base", "methodology-library"],
                priority=4,
                concurrent_queries=1,
                quality_threshold=7.5
            )
        }
    
    async def start_concurrent_search(self, 
                                    user_query: str, 
                                    domain: str = "general",
                                    priority_channels: Optional[List[str]] = None) -> Dict[str, SearchResult]:
        """启动5通道并发搜索"""
        
        logger.info(f"🚀 启动5通道并发搜索引擎")
        logger.info(f"📝 用户查询: {user_query}")
        logger.info(f"🎯 业务域: {domain}")
        
        # 生成针对性搜索查询
        channel_queries = self._generate_channel_queries(user_query, domain)
        
        # 如果指定了优先通道，调整执行顺序
        if priority_channels:
            channel_queries = self._prioritize_channels(channel_queries, priority_channels)
        
        # 并发执行所有通道搜索
        search_tasks = []
        for channel_name, queries in channel_queries.items():
            if channel_name in self.channels:
                task = asyncio.create_task(
                    self._execute_channel_search(channel_name, queries)
                )
                search_tasks.append(task)
        
        # 等待所有搜索完成
        results = {}
        completed_tasks = await asyncio.gather(*search_tasks, return_exceptions=True)
        
        for i, result in enumerate(completed_tasks):
            if isinstance(result, Exception):
                logger.error(f"通道搜索失败: {result}")
            else:
                channel_name = list(channel_queries.keys())[i]
                results[channel_name] = result
        
        # 质量评估和优化
        optimized_results = self._optimize_results(results, user_query, domain)
        
        # 记录学习数据
        if self.config.get("learning_enabled", True):
            await self._record_learning_data(user_query, domain, optimized_results)
        
        logger.info(f"✅ 5通道并发搜索完成，获得 {len(optimized_results)} 个高质量结果")
        
        return optimized_results
    
    def _generate_channel_queries(self, user_query: str, domain: str) -> Dict[str, List[str]]:
        """生成各通道专门化查询"""
        
        # 基础查询分析
        base_keywords = user_query.lower().split()
        
        # 投资发现通道查询
        investment_queries = []
        if any(word in user_query.lower() for word in ['投资', '融资', '估值', 'AI', '创业', '独角兽']):
            investment_queries = [
                f"{user_query} 投资机会",
                f"{user_query} 融资情况",
                f"{user_query} 市场估值",
                f"AI {user_query} 投资分析"
            ]
        else:
            investment_queries = [f"{user_query} 商业价值", f"{user_query} 投资潜力"]
        
        # 技术趋势通道查询
        tech_queries = [
            f"{user_query} 技术趋势 2024 2025",
            f"{user_query} 最新技术发展",
            f"{user_query} 前沿技术应用",
            f"{user_query} 技术创新突破"
        ]
        
        # 市场动态通道查询
        market_queries = [
            f"{user_query} 市场分析报告",
            f"{user_query} 行业发展趋势",
            f"{user_query} 竞争格局分析",
            f"{user_query} 商业模式创新"
        ]
        
        # 企业需求通道查询
        enterprise_queries = [
            f"{user_query} 企业解决方案",
            f"{user_query} 企业服务需求",
            f"{user_query} 企业数字化转型",
            f"企业如何应用 {user_query}"
        ]
        
        # 知识沉淀通道查询（主要是内部知识库检索）
        knowledge_queries = [
            f"{user_query} 方法论",
            f"{user_query} 最佳实践",
            f"{user_query} 经验总结",
            f"{user_query} 分析框架"
        ]
        
        return {
            "investment_discovery": investment_queries,
            "tech_trends": tech_queries,
            "market_dynamics": market_queries,
            "enterprise_needs": enterprise_queries,
            "knowledge_synthesis": knowledge_queries
        }
    
    def _prioritize_channels(self, channel_queries: Dict[str, List[str]], 
                           priority_channels: List[str]) -> Dict[str, List[str]]:
        """根据优先级重新排序通道"""
        prioritized = {}
        
        # 先添加优先通道
        for channel in priority_channels:
            if channel in channel_queries:
                prioritized[channel] = channel_queries[channel]
        
        # 添加其余通道
        for channel, queries in channel_queries.items():
            if channel not in prioritized:
                prioritized[channel] = queries
        
        return prioritized
    
    async def _execute_channel_search(self, channel_name: str, queries: List[str]) -> SearchResult:
        """执行单个通道的搜索"""
        
        channel_config = self.channels[channel_name]
        logger.info(f"🔍 执行{channel_config.name}搜索...")
        
        all_results = []
        total_quality_score = 0.0
        source_count = 0
        
        # 并发执行该通道的多个查询
        search_futures = []
        
        for i, query in enumerate(queries[:channel_config.concurrent_queries]):
            future = self.executor.submit(self._execute_single_search, channel_name, query)
            search_futures.append(future)
        
        # 收集搜索结果
        for future in as_completed(search_futures, timeout=self.config["timeout_seconds"]):
            try:
                result = future.result()
                if result:
                    all_results.extend(result.get("results", []))
                    source_count += result.get("source_count", 0)
                    total_quality_score += result.get("quality_score", 0.0)
            except Exception as e:
                logger.error(f"搜索查询失败: {e}")
        
        # 计算平均质量分数
        avg_quality = total_quality_score / max(len(queries), 1)
        
        # 去重和优化结果
        unique_results = self._deduplicate_results(all_results)
        
        return SearchResult(
            channel=channel_name,
            query="; ".join(queries),
            results=unique_results,
            timestamp=datetime.now(),
            quality_score=avg_quality,
            source_count=source_count
        )
    
    def _execute_single_search(self, channel_name: str, query: str) -> Optional[Dict[str, Any]]:
        """执行单次搜索"""
        try:
            channel_config = self.channels[channel_name]
            
            # 根据通道选择最佳工具
            if "tavily-search" in channel_config.tools:
                return self._tavily_search(query)
            elif "workspace-filesystem" in channel_config.tools:
                return self._knowledge_base_search(query)
            elif "fetch" in channel_config.tools:
                return self._web_fetch_search(query)
            else:
                return self._generic_search(query)
                
        except Exception as e:
            logger.error(f"搜索执行失败 - {channel_name}: {e}")
            return None
    
    def _tavily_search(self, query: str) -> Dict[str, Any]:
        """使用Tavily进行搜索"""
        try:
            # 模拟Tavily搜索调用
            # 实际环境中这里会调用MCP的tavily-search服务
            result = {
                "query": query,
                "results": [
                    {
                        "title": f"关于{query}的研究报告",
                        "url": "https://example.com/report1",
                        "content": f"基于最新数据的{query}深度分析...",
                        "relevance_score": 0.9,
                        "source_type": "research_report"
                    },
                    {
                        "title": f"{query}行业洞察",
                        "url": "https://example.com/insight1", 
                        "content": f"{query}领域的重要趋势和机会...",
                        "relevance_score": 0.85,
                        "source_type": "industry_analysis"
                    }
                ],
                "quality_score": 8.5,
                "source_count": 2
            }
            
            time.sleep(0.5)  # 模拟网络延迟
            return result
            
        except Exception as e:
            logger.error(f"Tavily搜索失败: {e}")
            return {"results": [], "quality_score": 0.0, "source_count": 0}
    
    def _knowledge_base_search(self, query: str) -> Dict[str, Any]:
        """搜索内部知识库"""
        try:
            # 模拟知识库搜索
            result = {
                "query": query,
                "results": [
                    {
                        "title": f"{query}方法论文档",
                        "path": "/knowledge/methodology/" + query.replace(" ", "_") + ".md",
                        "content": f"内部积累的{query}相关方法论和最佳实践...",
                        "relevance_score": 0.8,
                        "source_type": "internal_methodology"
                    }
                ],
                "quality_score": 7.5,
                "source_count": 1
            }
            
            time.sleep(0.2)  # 模拟文件访问延迟
            return result
            
        except Exception as e:
            logger.error(f"知识库搜索失败: {e}")
            return {"results": [], "quality_score": 0.0, "source_count": 0}
    
    def _web_fetch_search(self, query: str) -> Dict[str, Any]:
        """Web抓取搜索"""
        try:
            # 模拟Web抓取
            result = {
                "query": query,
                "results": [
                    {
                        "title": f"{query}最新动态",
                        "url": f"https://news.example.com/{query}",
                        "content": f"最新的{query}相关新闻和动态...",
                        "relevance_score": 0.75,
                        "source_type": "news_article"
                    }
                ],
                "quality_score": 7.0,
                "source_count": 1
            }
            
            time.sleep(0.8)  # 模拟网页抓取延迟
            return result
            
        except Exception as e:
            logger.error(f"Web抓取失败: {e}")
            return {"results": [], "quality_score": 0.0, "source_count": 0}
    
    def _generic_search(self, query: str) -> Dict[str, Any]:
        """通用搜索方法"""
        return {
            "query": query,
            "results": [
                {
                    "title": f"关于{query}的信息",
                    "content": f"通用搜索找到的{query}相关信息...",
                    "relevance_score": 0.6,
                    "source_type": "generic"
                }
            ],
            "quality_score": 6.0,
            "source_count": 1
        }
    
    def _deduplicate_results(self, results: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """去重搜索结果"""
        seen_titles = set()
        unique_results = []
        
        for result in results:
            title = result.get("title", "")
            if title not in seen_titles:
                seen_titles.add(title)
                unique_results.append(result)
        
        return unique_results
    
    def _optimize_results(self, 
                         results: Dict[str, SearchResult], 
                         user_query: str, 
                         domain: str) -> Dict[str, SearchResult]:
        """BMAD质量优化和结果筛选"""
        
        logger.info("📊 执行BMAD质量优化...")
        
        optimized_results = {}
        
        for channel_name, search_result in results.items():
            if search_result.quality_score >= self.channels[channel_name].quality_threshold:
                # 对高质量结果进行进一步优化
                optimized_result = self._apply_bmad_optimization(search_result, user_query, domain)
                optimized_results[channel_name] = optimized_result
            else:
                logger.warning(f"通道 {channel_name} 质量不达标: {search_result.quality_score}")
        
        return optimized_results
    
    def _apply_bmad_optimization(self, 
                               search_result: SearchResult, 
                               user_query: str, 
                               domain: str) -> SearchResult:
        """应用BMAD批评优化机制"""
        
        # 批评阶段 - 评估结果质量
        quality_issues = []
        
        if search_result.source_count < 2:
            quality_issues.append("来源数量不足")
        
        if len(search_result.results) < 1:
            quality_issues.append("结果数量过少")
        
        avg_relevance = sum(r.get("relevance_score", 0) for r in search_result.results) / max(len(search_result.results), 1)
        if avg_relevance < 0.7:
            quality_issues.append("相关性偏低")
        
        # 优化阶段 - 应用改进措施
        if quality_issues:
            logger.info(f"🔧 对通道 {search_result.channel} 应用质量优化: {quality_issues}")
            
            # 提升质量分数的优化逻辑
            optimization_bonus = 0.0
            
            # 如果是投资分析域，给投资相关结果加分
            if domain == "investment_analysis" and search_result.channel == "investment_discovery":
                optimization_bonus += 0.5
            
            # 根据结果多样性加分
            source_types = set(r.get("source_type", "") for r in search_result.results)
            if len(source_types) > 2:
                optimization_bonus += 0.3
            
            # 应用优化
            search_result.quality_score = min(10.0, search_result.quality_score + optimization_bonus)
        
        return search_result
    
    async def _record_learning_data(self, 
                                  user_query: str, 
                                  domain: str, 
                                  results: Dict[str, SearchResult]) -> None:
        """记录学习数据用于持续优化"""
        
        learning_data = {
            "timestamp": datetime.now().isoformat(),
            "user_query": user_query,
            "domain": domain,
            "channel_performance": {},
            "overall_quality": 0.0,
            "optimization_suggestions": []
        }
        
        total_quality = 0.0
        active_channels = 0
        
        for channel_name, search_result in results.items():
            learning_data["channel_performance"][channel_name] = {
                "quality_score": search_result.quality_score,
                "result_count": len(search_result.results),
                "source_count": search_result.source_count,
                "execution_time": "模拟时间"  # 实际环境中记录真实执行时间
            }
            
            total_quality += search_result.quality_score
            active_channels += 1
        
        learning_data["overall_quality"] = total_quality / max(active_channels, 1)
        
        # 生成优化建议
        if learning_data["overall_quality"] < 7.0:
            learning_data["optimization_suggestions"].append("整体搜索质量偏低，建议调整查询策略")
        
        if active_channels < 4:
            learning_data["optimization_suggestions"].append("活跃通道数量不足，建议优化通道配置")
        
        # 保存学习数据
        try:
            learning_file = "/tmp/5_channel_learning_data.json"
            with open(learning_file, "a", encoding="utf-8") as f:
                f.write(json.dumps(learning_data, ensure_ascii=False) + "\n")
            
            logger.info(f"📚 学习数据已记录: {learning_file}")
            
        except Exception as e:
            logger.error(f"学习数据记录失败: {e}")
    
    def generate_comprehensive_report(self, results: Dict[str, SearchResult], user_query: str) -> str:
        """生成综合分析报告"""
        
        report = f"""# 5通道并发搜索综合报告

## 📊 搜索概要
- **查询内容**: {user_query}
- **执行时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- **活跃通道**: {len(results)}个
- **总结果数量**: {sum(len(r.results) for r in results.values())}条

## 🔍 各通道分析结果

"""
        
        for channel_name, search_result in results.items():
            channel_config = self.channels[channel_name]
            
            report += f"""### {channel_config.name}
- **质量评分**: {search_result.quality_score:.1f}/10.0
- **结果数量**: {len(search_result.results)}条
- **信息源数**: {search_result.source_count}个
- **查询策略**: {search_result.query}

#### 关键发现:
"""
            
            for i, result in enumerate(search_result.results[:3], 1):  # 只显示前3个结果
                report += f"{i}. **{result.get('title', '无标题')}** (相关性: {result.get('relevance_score', 0):.2f})\n"
                report += f"   {result.get('content', '无内容')[:100]}...\n\n"
        
        # 综合洞察
        avg_quality = sum(r.quality_score for r in results.values()) / len(results)
        total_sources = sum(r.source_count for r in results.values())
        
        report += f"""## 💡 综合洞察

### 搜索效果评估
- **平均质量评分**: {avg_quality:.1f}/10.0
- **信息源覆盖**: {total_sources}个独立来源
- **数据完整性**: {'优秀' if avg_quality > 8.0 else '良好' if avg_quality > 7.0 else '一般'}

### 主要发现
"""
        
        # 提取关键洞察
        if avg_quality > 8.5:
            report += "- ✅ 搜索质量优秀，信息覆盖全面\n"
        elif avg_quality > 7.0:
            report += "- ✅ 搜索质量良好，获得了有价值的信息\n"
        else:
            report += "- ⚠️ 搜索质量有待提升，建议优化查询策略\n"
        
        if total_sources > 10:
            report += "- ✅ 信息源丰富，确保了信息的多样性和可靠性\n"
        
        report += f"""
### 建议行动
1. 重点关注质量评分最高的 {max(results.items(), key=lambda x: x[1].quality_score)[0]} 通道结果
2. 对于低质量通道，建议调整搜索策略或增加信息源
3. 将高价值发现整合到知识库中，供未来参考

---
*本报告由LayerX 5通道并发搜索引擎自动生成*
*生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}*
"""
        
        return report

# 主程序入口
async def main():
    """主程序演示"""
    
    print("🚀 LayerX 5通道并发生产引擎启动测试")
    
    # 初始化引擎
    engine = FiveChannelConcurrentEngine()
    
    # 测试查询
    test_queries = [
        ("AI视频生成技术的投资机会", "investment_analysis"),
        ("企业数字化转型解决方案", "enterprise_service"),
        ("2025年技术趋势预测", "knowledge_research")
    ]
    
    for query, domain in test_queries:
        print(f"\n" + "="*80)
        print(f"🔍 测试查询: {query}")
        print(f"🎯 业务域: {domain}")
        print("="*80)
        
        # 执行5通道并发搜索
        results = await engine.start_concurrent_search(query, domain)
        
        # 生成综合报告
        report = engine.generate_comprehensive_report(results, query)
        
        # 显示结果
        print("\n📊 搜索结果概要:")
        for channel_name, result in results.items():
            channel_desc = engine.channels[channel_name].name
            print(f"- {channel_desc}: {result.quality_score:.1f}/10.0 ({len(result.results)}条结果)")
        
        # 保存详细报告
        report_file = f"/tmp/5_channel_report_{int(time.time())}.md"
        with open(report_file, "w", encoding="utf-8") as f:
            f.write(report)
        
        print(f"📄 详细报告已保存: {report_file}")
        
        # 等待用户确认继续
        await asyncio.sleep(2)
    
    print("\n✅ 5通道并发引擎测试完成!")

if __name__ == "__main__":
    asyncio.run(main())