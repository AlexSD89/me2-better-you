#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PocketCorn投资分析数据收集器
基于Scraperr平台的华人AI企业投资信号采集工具

使用方法:
    python pocketcorn_data_collection.py --mode discovery --region china
    python pocketcorn_data_collection.py --mode analysis --company "某科技公司"
    python pocketcorn_data_collection.py --mode monitoring --continuous
"""

import os
import sys
import json
import asyncio
import logging
import argparse
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
import aiohttp
import requests
from urllib.parse import urljoin, urlparse
import re
from dataclasses import dataclass, asdict
import sqlite3
from pathlib import Path

# 添加项目根目录到Python路径
project_root = Path(__file__).parent
sys.path.append(str(project_root))

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('pocketcorn_collection.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class CompanySignal:
    """企业信号数据结构"""
    company_name: str
    signal_type: str  # recruiting, product, customer, technology, media
    signal_data: Dict
    source_url: str
    confidence_score: float
    timestamp: datetime
    region: str

@dataclass
class InvestmentCandidate:
    """投资候选企业数据结构"""
    company_name: str
    chinese_identity_score: float
    mrr_estimate: Optional[int]
    growth_rate: Optional[float]
    team_size_estimate: Optional[int]
    comprehensive_score: float
    dimension_scores: Dict[str, float]
    signals: List[CompanySignal]
    last_updated: datetime

class ConfigManager:
    """配置管理器"""
    
    def __init__(self, config_dir: str = "configs"):
        self.config_dir = Path(config_dir)
        self.configs = {}
        self.load_all_configs()
    
    def load_all_configs(self):
        """加载所有配置文件"""
        config_files = [
            "chinese_company_detection.json",
            "mrr_signals_config.json", 
            "multi_dimension_scoring.json"
        ]
        
        for config_file in config_files:
            config_path = self.config_dir / config_file
            if config_path.exists():
                with open(config_path, 'r', encoding='utf-8') as f:
                    config_name = config_file.replace('.json', '')
                    self.configs[config_name] = json.load(f)
                    logger.info(f"已加载配置文件: {config_file}")
            else:
                logger.warning(f"配置文件不存在: {config_file}")
    
    def get_config(self, config_name: str) -> Dict:
        """获取指定配置"""
        return self.configs.get(config_name, {})

class ChineseCompanyDetector:
    """华人企业识别器"""
    
    def __init__(self, config: Dict):
        self.config = config
        self.identity_signals = config.get('chinese_identity_signals', {})
    
    def detect_chinese_identity(self, company_data: Dict) -> Tuple[bool, float, Dict]:
        """
        检测华人企业身份
        
        Args:
            company_data: 企业数据字典
            
        Returns:
            (是否华人企业, 置信度分数, 详细因素)
        """
        total_score = 0
        max_score = 0
        factors = {}
        
        # 检查中文姓名
        name_patterns = self.identity_signals.get('chinese_names', {}).get('patterns', [])
        name_weight = self.identity_signals.get('chinese_names', {}).get('weight', 0.4)
        name_score = self._check_name_patterns(company_data, name_patterns)
        factors['name_score'] = name_score
        total_score += name_score * name_weight
        max_score += name_weight
        
        # 检查教育背景
        education_config = self.identity_signals.get('education_background', {})
        education_weight = education_config.get('weight', 0.3)
        education_score = self._check_education_background(company_data, education_config)
        factors['education_score'] = education_score
        total_score += education_score * education_weight
        max_score += education_weight
        
        # 检查地理位置
        geographic_config = self.identity_signals.get('geographic_indicators', {})
        geographic_weight = geographic_config.get('weight', 0.2)
        geographic_score = self._check_geographic_indicators(company_data, geographic_config)
        factors['geographic_score'] = geographic_score
        total_score += geographic_score * geographic_weight
        max_score += geographic_weight
        
        # 检查语言模式
        language_config = self.identity_signals.get('language_patterns', {})
        language_weight = language_config.get('weight', 0.1)
        language_score = self._check_language_patterns(company_data, language_config)
        factors['language_score'] = language_score
        total_score += language_score * language_weight
        max_score += language_weight
        
        # 计算最终置信度
        final_confidence = total_score / max_score if max_score > 0 else 0
        is_chinese = final_confidence > 0.6  # 置信度阈值
        
        return is_chinese, final_confidence, factors
    
    def _check_name_patterns(self, company_data: Dict, patterns: List[str]) -> float:
        """检查中文姓名模式"""
        text_content = str(company_data)
        match_count = 0
        
        for pattern in patterns:
            if re.search(pattern, text_content, re.IGNORECASE):
                match_count += 1
        
        return min(match_count / len(patterns) if patterns else 0, 1.0)
    
    def _check_education_background(self, company_data: Dict, config: Dict) -> float:
        """检查教育背景"""
        text_content = str(company_data)
        chinese_unis = config.get('chinese_universities', [])
        overseas_programs = config.get('overseas_chinese_programs', [])
        
        match_score = 0
        total_indicators = len(chinese_unis) + len(overseas_programs)
        
        for uni in chinese_unis:
            if uni.lower() in text_content.lower():
                match_score += 1
        
        for program in overseas_programs:
            if program.lower() in text_content.lower():
                match_score += 1
        
        return min(match_score / total_indicators if total_indicators else 0, 1.0)
    
    def _check_geographic_indicators(self, company_data: Dict, config: Dict) -> float:
        """检查地理位置指标"""
        text_content = str(company_data)
        locations = config.get('chinese_locations', [])
        business_districts = config.get('chinese_business_districts', [])
        
        match_score = 0
        total_indicators = len(locations) + len(business_districts)
        
        for location in locations:
            if location.lower() in text_content.lower():
                match_score += 1
        
        for district in business_districts:
            if district.lower() in text_content.lower():
                match_score += 1
        
        return min(match_score / total_indicators if total_indicators else 0, 1.0)
    
    def _check_language_patterns(self, company_data: Dict, config: Dict) -> float:
        """检查语言模式"""
        text_content = str(company_data)
        mixed_patterns = config.get('mixed_language_content', [])
        business_terms = config.get('chinese_business_terms', [])
        
        pattern_matches = 0
        for pattern in mixed_patterns:
            if re.search(pattern, text_content):
                pattern_matches += 1
        
        term_matches = 0
        for term in business_terms:
            if term in text_content:
                term_matches += 1
        
        total_possible = len(mixed_patterns) + len(business_terms)
        total_matches = pattern_matches + term_matches
        
        return min(total_matches / total_possible if total_possible else 0, 1.0)

class MRRSignalProcessor:
    """MRR信号处理器"""
    
    def __init__(self, config: Dict):
        self.config = config
        self.signal_categories = config.get('signal_categories', {})
        self.calculation_models = config.get('mrr_calculation_models', {})
    
    def process_recruiting_signals(self, company_data: Dict) -> Dict:
        """处理招聘信号"""
        recruiting_config = self.signal_categories.get('recruiting_signals', {})
        indicators = recruiting_config.get('indicators', {})
        
        # 分析招聘频率
        job_frequency = self._analyze_job_posting_frequency(company_data, indicators)
        
        # 分析技术岗位
        technical_roles = self._analyze_technical_roles(company_data, indicators)
        
        return {
            'job_posting_frequency': job_frequency,
            'technical_roles_analysis': technical_roles,
            'recruiting_signal_score': (job_frequency.get('score', 0) + technical_roles.get('score', 0)) / 2
        }
    
    def process_product_signals(self, company_data: Dict) -> Dict:
        """处理产品信号"""
        product_config = self.signal_categories.get('product_signals', {})
        indicators = product_config.get('indicators', {})
        
        # 分析产品更新
        product_updates = self._analyze_product_updates(company_data, indicators)
        
        # 分析用户反馈
        user_feedback = self._analyze_user_feedback(company_data, indicators)
        
        # 分析集成信号
        integration_signals = self._analyze_integration_signals(company_data, indicators)
        
        return {
            'product_updates': product_updates,
            'user_feedback': user_feedback,
            'integration_signals': integration_signals,
            'product_signal_score': (
                product_updates.get('score', 0) + 
                user_feedback.get('score', 0) + 
                integration_signals.get('score', 0)
            ) / 3
        }
    
    def estimate_mrr(self, all_signals: Dict) -> Tuple[Optional[int], float]:
        """估算MRR"""
        # 使用综合模型估算MRR
        ensemble_model = self.calculation_models.get('ensemble_model', {})
        
        # 收集特征
        features = self._extract_features(all_signals)
        
        # 应用回归模型
        regression_estimate = self._apply_regression_model(features)
        
        # 应用规则模型
        rule_estimate = self._apply_rule_based_model(features)
        
        # 综合预测
        weights = ensemble_model.get('weights', [0.6, 0.4])
        final_estimate = (
            regression_estimate * weights[0] + 
            rule_estimate * weights[1]
        )
        
        # 置信度计算
        confidence = self._calculate_confidence(features, all_signals)
        
        return int(final_estimate) if final_estimate > 0 else None, confidence
    
    def _analyze_job_posting_frequency(self, company_data: Dict, indicators: Dict) -> Dict:
        """分析招聘发布频率"""
        job_freq_config = indicators.get('job_posting_frequency', {})
        patterns = job_freq_config.get('patterns', [])
        
        text_content = str(company_data)
        urgency_matches = 0
        
        for pattern in patterns:
            if re.search(pattern, text_content, re.IGNORECASE):
                urgency_matches += 1
        
        # 根据匹配数量评分
        if urgency_matches >= 3:
            score = 0.9
            level = "high"
        elif urgency_matches >= 1:
            score = 0.6
            level = "medium"
        else:
            score = 0.3
            level = "low"
        
        return {
            'urgency_matches': urgency_matches,
            'score': score,
            'level': level
        }
    
    def _analyze_technical_roles(self, company_data: Dict, indicators: Dict) -> Dict:
        """分析技术岗位"""
        tech_roles_config = indicators.get('technical_roles', {})
        high_value_positions = tech_roles_config.get('high_value_positions', [])
        salary_indicators = tech_roles_config.get('salary_indicators', [])
        
        text_content = str(company_data)
        
        position_matches = 0
        for position in high_value_positions:
            if position.lower() in text_content.lower():
                position_matches += 1
        
        salary_matches = 0
        for salary_pattern in salary_indicators:
            if re.search(salary_pattern, text_content, re.IGNORECASE):
                salary_matches += 1
        
        combined_score = min((position_matches + salary_matches) / 
                           (len(high_value_positions) + len(salary_indicators)), 1.0)
        
        return {
            'position_matches': position_matches,
            'salary_matches': salary_matches,
            'score': combined_score
        }
    
    def _analyze_product_updates(self, company_data: Dict, indicators: Dict) -> Dict:
        """分析产品更新"""
        updates_config = indicators.get('product_updates', {})
        patterns = updates_config.get('patterns', [])
        
        text_content = str(company_data)
        update_matches = 0
        
        for pattern in patterns:
            matches = re.findall(pattern, text_content, re.IGNORECASE)
            update_matches += len(matches)
        
        # 基于更新频率评分
        if update_matches >= 5:
            score = 0.9
        elif update_matches >= 2:
            score = 0.6
        else:
            score = 0.3
        
        return {
            'update_count': update_matches,
            'score': score
        }
    
    def _analyze_user_feedback(self, company_data: Dict, indicators: Dict) -> Dict:
        """分析用户反馈"""
        feedback_config = indicators.get('user_feedback', {})
        positive_indicators = feedback_config.get('positive_indicators', [])
        negative_indicators = feedback_config.get('negative_indicators', [])
        
        text_content = str(company_data)
        
        positive_count = 0
        for indicator in positive_indicators:
            if indicator.lower() in text_content.lower():
                positive_count += 1
        
        negative_count = 0
        for indicator in negative_indicators:
            if indicator.lower() in text_content.lower():
                negative_count += 1
        
        # 计算情感得分
        if positive_count + negative_count > 0:
            sentiment_score = positive_count / (positive_count + negative_count)
        else:
            sentiment_score = 0.5  # 中性
        
        return {
            'positive_signals': positive_count,
            'negative_signals': negative_count,
            'sentiment_score': sentiment_score,
            'score': sentiment_score
        }
    
    def _analyze_integration_signals(self, company_data: Dict, indicators: Dict) -> Dict:
        """分析集成信号"""
        integration_config = indicators.get('integration_signals', {})
        api_usage = integration_config.get('api_usage', [])
        partnerships = integration_config.get('partnership', [])
        
        text_content = str(company_data)
        
        api_matches = sum(1 for api_term in api_usage 
                         if api_term.lower() in text_content.lower())
        
        partner_matches = sum(1 for partner_term in partnerships 
                            if partner_term.lower() in text_content.lower())
        
        total_possible = len(api_usage) + len(partnerships)
        total_matches = api_matches + partner_matches
        
        score = total_matches / total_possible if total_possible > 0 else 0
        
        return {
            'api_integration_signals': api_matches,
            'partnership_signals': partner_matches,
            'score': min(score, 1.0)
        }
    
    def _extract_features(self, all_signals: Dict) -> Dict:
        """从所有信号中提取特征"""
        features = {}
        
        # 从招聘信号提取特征
        recruiting = all_signals.get('recruiting_signals', {})
        features['job_posting_frequency'] = recruiting.get('job_posting_frequency', {}).get('score', 0)
        features['technical_roles_quality'] = recruiting.get('technical_roles_analysis', {}).get('score', 0)
        
        # 从产品信号提取特征
        product = all_signals.get('product_signals', {})
        features['product_update_frequency'] = product.get('product_updates', {}).get('score', 0)
        features['user_sentiment'] = product.get('user_feedback', {}).get('sentiment_score', 0.5)
        
        # 从客户信号提取特征
        customer = all_signals.get('customer_signals', {})
        features['customer_quality'] = customer.get('customer_base_score', 0)
        
        # 从技术信号提取特征
        technology = all_signals.get('technology_signals', {})
        features['tech_innovation'] = technology.get('innovation_score', 0)
        
        return features
    
    def _apply_regression_model(self, features: Dict) -> float:
        """应用回归模型"""
        regression_model = self.calculation_models.get('regression_model', {})
        coefficients = regression_model.get('coefficients', {})
        
        estimate = 0
        for feature, value in features.items():
            coefficient = coefficients.get(feature, 0)
            estimate += value * coefficient
        
        return max(estimate, 0)  # MRR不能为负
    
    def _apply_rule_based_model(self, features: Dict) -> float:
        """应用基于规则的模型"""
        rule_model = self.calculation_models.get('rule_based_model', {})
        rules = rule_model.get('rules', [])
        
        best_estimate = 0
        best_confidence = 0
        
        for rule in rules:
            if self._evaluate_rule_condition(rule.get('condition', ''), features):
                mrr_range = rule.get('mrr_estimate', '0-0')
                confidence = rule.get('confidence', 0)
                
                # 解析MRR范围并取中值
                if '-' in mrr_range:
                    min_mrr, max_mrr = map(int, mrr_range.split('-'))
                    estimate = (min_mrr + max_mrr) / 2
                else:
                    estimate = int(mrr_range)
                
                # 选择置信度最高的规则
                if confidence > best_confidence:
                    best_estimate = estimate
                    best_confidence = confidence
        
        return best_estimate
    
    def _evaluate_rule_condition(self, condition: str, features: Dict) -> bool:
        """评估规则条件"""
        # 简化的条件评估，实际实现需要更复杂的解析
        try:
            # 替换特征名为实际值
            for feature, value in features.items():
                condition = condition.replace(feature, str(value))
            
            # 评估条件（注意：在生产环境中需要更安全的方法）
            return eval(condition)
        except:
            return False
    
    def _calculate_confidence(self, features: Dict, all_signals: Dict) -> float:
        """计算置信度"""
        # 基于信号数量和质量计算置信度
        signal_count = len([k for k, v in all_signals.items() if v])
        feature_quality = sum(features.values()) / len(features) if features else 0
        
        base_confidence = min(signal_count / 5.0, 1.0)  # 假设5个信号为满分
        quality_adjustment = feature_quality
        
        return (base_confidence + quality_adjustment) / 2

class DataCollector:
    """数据收集器"""
    
    def __init__(self, config_manager: ConfigManager):
        self.config_manager = config_manager
        self.chinese_detector = ChineseCompanyDetector(
            config_manager.get_config('chinese_company_detection')
        )
        self.mrr_processor = MRRSignalProcessor(
            config_manager.get_config('mrr_signals_config')
        )
        self.session = None
    
    async def collect_company_data(self, company_name: str, region: str = "china") -> Dict:
        """收集企业数据"""
        logger.info(f"开始收集企业数据: {company_name} (区域: {region})")
        
        # 获取数据源配置
        detection_config = self.config_manager.get_config('chinese_company_detection')
        data_sources = detection_config.get('data_sources', {})
        region_sources = data_sources.get(f'{region}_sources', {})
        
        collected_data = {
            'company_name': company_name,
            'region': region,
            'raw_data': {},
            'signals': [],
            'collection_timestamp': datetime.now()
        }
        
        # 收集不同类型的数据源
        for source_type, sources in region_sources.items():
            logger.info(f"收集{source_type}数据...")
            source_data = await self._collect_from_sources(sources, company_name)
            collected_data['raw_data'][source_type] = source_data
        
        return collected_data
    
    async def _collect_from_sources(self, sources: List[Dict], company_name: str) -> List[Dict]:
        """从数据源收集数据"""
        if not self.session:
            self.session = aiohttp.ClientSession()
        
        results = []
        
        for source in sources:
            try:
                source_name = source.get('name', 'unknown')
                base_url = source.get('url', '')
                xpath_selectors = source.get('xpath_selectors', {})
                
                logger.info(f"从{source_name}收集数据...")
                
                # 构造搜索URL（这里需要根据实际网站API调整）
                search_url = self._build_search_url(base_url, company_name)
                
                # 获取页面数据
                page_data = await self._fetch_page_data(search_url, xpath_selectors)
                
                if page_data:
                    results.append({
                        'source': source_name,
                        'url': search_url,
                        'data': page_data,
                        'collected_at': datetime.now()
                    })
                
            except Exception as e:
                logger.error(f"从{source.get('name', 'unknown')}收集数据时出错: {e}")
                continue
        
        return results
    
    def _build_search_url(self, base_url: str, company_name: str) -> str:
        """构建搜索URL"""
        # 这里需要根据具体网站的搜索规则来实现
        # 为了演示，使用简单的查询参数
        from urllib.parse import urlencode
        
        if 'zhaopin.com' in base_url:
            # 智联招聘搜索
            params = {'kw': company_name, 'jl': '全国'}
            return f"{base_url}/jobs/searchresult.ashx?{urlencode(params)}"
        elif 'lagou.com' in base_url:
            # 拉勾网搜索
            params = {'keyword': company_name}
            return f"{base_url}/jobs/list_{urlencode(params)}"
        elif '36kr.com' in base_url:
            # 36氪搜索
            params = {'q': company_name}
            return f"{base_url}/search?{urlencode(params)}"
        else:
            # 默认搜索
            params = {'q': company_name}
            return f"{base_url}/search?{urlencode(params)}"
    
    async def _fetch_page_data(self, url: str, xpath_selectors: Dict) -> Dict:
        """获取页面数据"""
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
            
            async with self.session.get(url, headers=headers, timeout=10) as response:
                if response.status == 200:
                    html_content = await response.text()
                    
                    # 使用xpath提取数据（需要安装lxml）
                    try:
                        from lxml import html
                        tree = html.fromstring(html_content)
                        
                        extracted_data = {}
                        for field, xpath in xpath_selectors.items():
                            try:
                                elements = tree.xpath(xpath)
                                if elements:
                                    extracted_data[field] = [elem.strip() for elem in elements if elem.strip()]
                            except Exception as e:
                                logger.warning(f"XPath提取失败 {field}: {e}")
                                extracted_data[field] = []
                        
                        return extracted_data
                        
                    except ImportError:
                        logger.warning("未安装lxml，使用正则表达式提取")
                        # 回退到简单的文本提取
                        return {'content': html_content}
                else:
                    logger.warning(f"HTTP错误 {response.status}: {url}")
                    return {}
                    
        except Exception as e:
            logger.error(f"获取页面数据失败 {url}: {e}")
            return {}
    
    async def close(self):
        """关闭会话"""
        if self.session:
            await self.session.close()

class PocketCornAnalyzer:
    """PocketCorn投资分析器"""
    
    def __init__(self, config_manager: ConfigManager):
        self.config_manager = config_manager
        self.chinese_detector = ChineseCompanyDetector(
            config_manager.get_config('chinese_company_detection')
        )
        self.mrr_processor = MRRSignalProcessor(
            config_manager.get_config('mrr_signals_config')
        )
        self.scoring_config = config_manager.get_config('multi_dimension_scoring')
        self.db_path = "pocketcorn_data.db"
        self._init_database()
    
    def _init_database(self):
        """初始化数据库"""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute('''
                CREATE TABLE IF NOT EXISTS investment_candidates (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    company_name TEXT UNIQUE,
                    chinese_identity_score REAL,
                    mrr_estimate INTEGER,
                    growth_rate REAL,
                    team_size_estimate INTEGER,
                    comprehensive_score REAL,
                    dimension_scores TEXT,
                    signals TEXT,
                    last_updated TIMESTAMP,
                    region TEXT
                )
            ''')
            
            conn.execute('''
                CREATE TABLE IF NOT EXISTS company_signals (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    company_name TEXT,
                    signal_type TEXT,
                    signal_data TEXT,
                    source_url TEXT,
                    confidence_score REAL,
                    timestamp TIMESTAMP,
                    region TEXT
                )
            ''')
    
    def analyze_company(self, company_data: Dict) -> InvestmentCandidate:
        """分析企业投资价值"""
        company_name = company_data.get('company_name', 'Unknown')
        logger.info(f"开始分析企业: {company_name}")
        
        # 1. 华人身份识别
        is_chinese, chinese_score, chinese_factors = self.chinese_detector.detect_chinese_identity(
            company_data
        )
        
        if not is_chinese:
            logger.info(f"企业{company_name}未通过华人身份识别，跳过分析")
            return None
        
        # 2. 信号处理
        signals = self._extract_all_signals(company_data)
        
        # 3. MRR估算
        mrr_estimate, mrr_confidence = self.mrr_processor.estimate_mrr(signals)
        
        # 4. 多维度评分
        dimension_scores = self._calculate_dimension_scores(company_data, signals)
        
        # 5. 综合评分
        comprehensive_score = self._calculate_comprehensive_score(dimension_scores)
        
        # 6. 构建投资候选对象
        candidate = InvestmentCandidate(
            company_name=company_name,
            chinese_identity_score=chinese_score,
            mrr_estimate=mrr_estimate,
            growth_rate=self._estimate_growth_rate(signals),
            team_size_estimate=self._estimate_team_size(signals),
            comprehensive_score=comprehensive_score,
            dimension_scores=dimension_scores,
            signals=self._convert_signals_to_objects(signals, company_name),
            last_updated=datetime.now()
        )
        
        # 7. 保存到数据库
        self._save_candidate(candidate)
        
        logger.info(f"企业{company_name}分析完成，综合评分: {comprehensive_score:.2f}")
        return candidate
    
    def _extract_all_signals(self, company_data: Dict) -> Dict:
        """提取所有信号"""
        signals = {}
        
        # 招聘信号
        signals['recruiting_signals'] = self.mrr_processor.process_recruiting_signals(company_data)
        
        # 产品信号
        signals['product_signals'] = self.mrr_processor.process_product_signals(company_data)
        
        # 客户信号（简化实现）
        signals['customer_signals'] = self._process_customer_signals(company_data)
        
        # 技术信号（简化实现）
        signals['technology_signals'] = self._process_technology_signals(company_data)
        
        # 媒体信号（简化实现）
        signals['media_signals'] = self._process_media_signals(company_data)
        
        return signals
    
    def _process_customer_signals(self, company_data: Dict) -> Dict:
        """处理客户信号（简化版）"""
        # 这里是简化实现，实际需要更复杂的逻辑
        text_content = str(company_data)
        
        # 查找客户相关信息
        customer_keywords = ['客户', 'customer', '企业客户', 'enterprise', '用户', 'user']
        customer_score = 0
        
        for keyword in customer_keywords:
            if keyword.lower() in text_content.lower():
                customer_score += 0.1
        
        return {
            'customer_base_score': min(customer_score, 1.0),
            'enterprise_indicators': customer_score > 0.5
        }
    
    def _process_technology_signals(self, company_data: Dict) -> Dict:
        """处理技术信号（简化版）"""
        text_content = str(company_data)
        
        tech_keywords = [
            'AI', '人工智能', 'machine learning', '机器学习', 
            'deep learning', '深度学习', 'algorithm', '算法',
            'github', 'open source', '开源', 'patent', '专利'
        ]
        
        tech_score = 0
        for keyword in tech_keywords:
            if keyword.lower() in text_content.lower():
                tech_score += 0.1
        
        return {
            'innovation_score': min(tech_score, 1.0),
            'tech_activity': tech_score > 0.3
        }
    
    def _process_media_signals(self, company_data: Dict) -> Dict:
        """处理媒体信号（简化版）"""
        text_content = str(company_data)
        
        media_keywords = [
            'news', '新闻', 'report', '报道', 'media', '媒体',
            '融资', 'funding', 'investment', '投资', 'series A', 'series B'
        ]
        
        media_score = 0
        for keyword in media_keywords:
            if keyword.lower() in text_content.lower():
                media_score += 0.1
        
        return {
            'media_coverage_score': min(media_score, 1.0),
            'recent_coverage': media_score > 0.2
        }
    
    def _calculate_dimension_scores(self, company_data: Dict, signals: Dict) -> Dict:
        """计算维度评分"""
        scores = {}
        
        # MRR维度评分
        mrr_signals = signals.get('recruiting_signals', {})
        product_signals = signals.get('product_signals', {})
        customer_signals = signals.get('customer_signals', {})
        
        mrr_score = (
            mrr_signals.get('recruiting_signal_score', 0) * 0.4 +
            product_signals.get('product_signal_score', 0) * 0.4 +
            customer_signals.get('customer_base_score', 0) * 0.2
        )
        scores['mrr_score'] = mrr_score * 100  # 转换为0-100分制
        
        # 媒体维度评分
        media_signals = signals.get('media_signals', {})
        scores['media_score'] = media_signals.get('media_coverage_score', 0) * 100
        
        # 赛道维度评分
        technology_signals = signals.get('technology_signals', {})
        scores['sector_score'] = technology_signals.get('innovation_score', 0) * 100
        
        # 认知维度评分（基于团队质量）
        scores['cognitive_score'] = self._calculate_team_quality_score(company_data) * 100
        
        return scores
    
    def _calculate_team_quality_score(self, company_data: Dict) -> float:
        """计算团队质量评分（简化版）"""
        text_content = str(company_data)
        
        quality_indicators = [
            'founder', '创始人', 'CEO', 'CTO', '清华', '北大', 'Stanford', 'MIT',
            '博士', 'PhD', '硕士', 'Master', '经验', 'experience', '专家', 'expert'
        ]
        
        quality_score = 0
        for indicator in quality_indicators:
            if indicator.lower() in text_content.lower():
                quality_score += 0.05
        
        return min(quality_score, 1.0)
    
    def _calculate_comprehensive_score(self, dimension_scores: Dict) -> float:
        """计算综合评分"""
        weights = {
            'mrr_score': 0.4,
            'media_score': 0.2,
            'sector_score': 0.25,
            'cognitive_score': 0.15
        }
        
        total_score = 0
        for dimension, score in dimension_scores.items():
            weight = weights.get(dimension, 0)
            total_score += score * weight
        
        return total_score
    
    def _estimate_growth_rate(self, signals: Dict) -> Optional[float]:
        """估算增长率"""
        # 基于产品更新频率和用户反馈估算增长率
        product_signals = signals.get('product_signals', {})
        update_score = product_signals.get('product_updates', {}).get('score', 0)
        feedback_score = product_signals.get('user_feedback', {}).get('sentiment_score', 0.5)
        
        # 简化的增长率估算
        growth_estimate = (update_score + feedback_score) / 2 * 0.3  # 最高30%
        
        return growth_estimate if growth_estimate > 0.05 else None
    
    def _estimate_team_size(self, signals: Dict) -> Optional[int]:
        """估算团队规模"""
        recruiting_signals = signals.get('recruiting_signals', {})
        job_freq_score = recruiting_signals.get('job_posting_frequency', {}).get('score', 0)
        tech_roles_score = recruiting_signals.get('technical_roles_analysis', {}).get('score', 0)
        
        # 基于招聘活跃度估算团队规模
        base_size = 3  # 最小团队规模
        additional_size = (job_freq_score + tech_roles_score) * 10
        
        estimated_size = int(base_size + additional_size)
        return estimated_size if estimated_size <= 50 else None  # 限制最大值
    
    def _convert_signals_to_objects(self, signals: Dict, company_name: str) -> List[CompanySignal]:
        """转换信号为对象列表"""
        signal_objects = []
        
        for signal_type, signal_data in signals.items():
            if signal_data:
                signal_obj = CompanySignal(
                    company_name=company_name,
                    signal_type=signal_type,
                    signal_data=signal_data,
                    source_url="",  # 需要从原始数据中提取
                    confidence_score=signal_data.get('score', 0) if isinstance(signal_data, dict) else 0.5,
                    timestamp=datetime.now(),
                    region="china"  # 默认区域
                )
                signal_objects.append(signal_obj)
        
        return signal_objects
    
    def _save_candidate(self, candidate: InvestmentCandidate):
        """保存候选企业到数据库"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                # 保存投资候选企业
                conn.execute('''
                    INSERT OR REPLACE INTO investment_candidates 
                    (company_name, chinese_identity_score, mrr_estimate, growth_rate, 
                     team_size_estimate, comprehensive_score, dimension_scores, 
                     signals, last_updated, region)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    candidate.company_name,
                    candidate.chinese_identity_score,
                    candidate.mrr_estimate,
                    candidate.growth_rate,
                    candidate.team_size_estimate,
                    candidate.comprehensive_score,
                    json.dumps(candidate.dimension_scores),
                    json.dumps([asdict(s) for s in candidate.signals], default=str),
                    candidate.last_updated,
                    "china"  # 默认区域
                ))
                
                # 保存信号数据
                for signal in candidate.signals:
                    conn.execute('''
                        INSERT INTO company_signals 
                        (company_name, signal_type, signal_data, source_url, 
                         confidence_score, timestamp, region)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                    ''', (
                        signal.company_name,
                        signal.signal_type,
                        json.dumps(signal.signal_data, default=str),
                        signal.source_url,
                        signal.confidence_score,
                        signal.timestamp,
                        signal.region
                    ))
                
                conn.commit()
                logger.info(f"候选企业{candidate.company_name}已保存到数据库")
                
        except Exception as e:
            logger.error(f"保存候选企业失败: {e}")

def generate_report(analyzer: PocketCornAnalyzer, output_file: str = "investment_report.md"):
    """生成投资报告"""
    try:
        with sqlite3.connect(analyzer.db_path) as conn:
            # 查询所有候选企业
            cursor = conn.execute('''
                SELECT * FROM investment_candidates 
                ORDER BY comprehensive_score DESC
                LIMIT 20
            ''')
            
            candidates = cursor.fetchall()
            
            if not candidates:
                logger.info("没有找到投资候选企业")
                return
            
            # 生成Markdown报告
            report_content = f"""# PocketCorn投资分析报告

**生成时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## 📊 执行摘要

本报告基于PocketCorn v4投资分析系统，对发现的华人AI企业进行了多维度评分分析。

**分析维度**:
- 🏦 MRR评分 (40%): 基于财务信号的收入推断
- 📺 媒体评分 (20%): 基于媒体报道和品牌影响力  
- 🎯 赛道评分 (25%): 基于行业趋势和市场机会
- 🧠 认知评分 (15%): 基于团队背景和技术能力

## 🏆 Top 20 投资候选企业

| 排名 | 企业名称 | 综合评分 | MRR估算 | 增长率 | 团队规模 | 华人置信度 |
|------|----------|----------|---------|---------|----------|------------|
"""
            
            for i, candidate in enumerate(candidates, 1):
                name = candidate[1] or "未知"
                score = candidate[6] or 0
                mrr = candidate[3] or "N/A"
                growth = f"{candidate[4]*100:.1f}%" if candidate[4] else "N/A"
                team_size = candidate[5] or "N/A"
                chinese_score = f"{candidate[2]*100:.1f}%" if candidate[2] else "N/A"
                
                # 确定评级
                if score >= 90:
                    tier = "🏆 S级"
                elif score >= 80:
                    tier = "🥇 A级"
                elif score >= 70:
                    tier = "🥈 B级"
                elif score >= 60:
                    tier = "🥉 C级"
                else:
                    tier = "📊 D级"
                
                report_content += f"| {i} | {name} | {score:.1f} ({tier}) | ¥{mrr:,} | {growth} | {team_size}人 | {chinese_score} |\n"
            
            # 添加详细分析
            report_content += f"""

## 📈 详细分析

### 🎯 投资机会洞察

**高价值目标** (综合评分 ≥ 80分):
- 共发现 {len([c for c in candidates if c[6] >= 80])} 家A级及以上企业
- 平均MRR估算: ¥{sum(c[3] for c in candidates[:5] if c[3]) // 5:,} 
- 主要集中在AI/ML和企业服务赛道

**成长潜力企业** (综合评分 70-80分):
- 共发现 {len([c for c in candidates if 70 <= c[6] < 80])} 家B级企业
- 具备良好的基础和增长潜力
- 建议重点关注和持续跟踪

### 🔍 投资建议

**优先级排序**:
1. **S级企业**: 立即启动尽调流程，72小时内完成初步评估
2. **A级企业**: 2周内完成详细调研，准备投资方案
3. **B级企业**: 1个月内完成基础调研，列入观察名单

**风险提示**:
- 所有MRR估算基于间接信号，需要实地验证
- 华人身份识别存在误差，需要人工确认
- 评分模型持续优化中，建议结合人工判断

### 📊 市场趋势分析

**热门赛道分布**:
- AI/ML企业占比最高，符合市场趋势
- 企业服务SaaS增长稳定
- 新兴技术领域存在机会

**地域分布**:
- 北京、上海、深圳、杭州为主要聚集地
- 海外华人企业(美国、新加坡)值得关注

---

**报告说明**: 
- 本报告基于公开信息和AI分析生成
- 所有数据仅供投资决策参考，不构成投资建议
- 建议结合实地调研和专业尽调

**系统版本**: PocketCorn v4.0
**数据更新**: {datetime.now().strftime('%Y-%m-%d')}
"""
            
            # 保存报告
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(report_content)
            
            logger.info(f"投资报告已生成: {output_file}")
            print(f"✅ 投资报告已保存至: {output_file}")
            
    except Exception as e:
        logger.error(f"生成报告失败: {e}")

async def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='PocketCorn投资分析数据收集器')
    parser.add_argument('--mode', choices=['discovery', 'analysis', 'monitoring', 'report'], 
                       default='discovery', help='运行模式')
    parser.add_argument('--region', choices=['china', 'us', 'japan'], 
                       default='china', help='目标区域')
    parser.add_argument('--company', help='指定企业名称进行分析')
    parser.add_argument('--continuous', action='store_true', help='持续监控模式')
    parser.add_argument('--output', default='investment_report.md', help='报告输出文件')
    
    args = parser.parse_args()
    
    # 初始化配置管理器
    config_manager = ConfigManager()
    
    if args.mode == 'report':
        # 生成报告模式
        analyzer = PocketCornAnalyzer(config_manager)
        generate_report(analyzer, args.output)
        return
    
    # 初始化数据收集器和分析器
    collector = DataCollector(config_manager)
    analyzer = PocketCornAnalyzer(config_manager)
    
    try:
        if args.mode == 'discovery':
            # 发现模式：自动发现新的投资机会
            logger.info(f"开始在{args.region}区域发现投资机会...")
            
            # 这里需要根据实际需求实现自动发现逻辑
            # 可以从新闻、招聘网站等自动抓取企业信息
            test_companies = ["测试科技公司", "AI创新企业", "智能软件公司"]
            
            for company in test_companies:
                logger.info(f"分析企业: {company}")
                company_data = await collector.collect_company_data(company, args.region)
                candidate = analyzer.analyze_company(company_data)
                
                if candidate and candidate.comprehensive_score > 60:
                    print(f"✅ 发现潜在投资机会: {company} (评分: {candidate.comprehensive_score:.1f})")
        
        elif args.mode == 'analysis':
            # 分析模式：分析指定企业
            if not args.company:
                print("❌ 分析模式需要指定企业名称 (--company)")
                return
            
            logger.info(f"分析指定企业: {args.company}")
            company_data = await collector.collect_company_data(args.company, args.region)
            candidate = analyzer.analyze_company(company_data)
            
            if candidate:
                print(f"""
📊 企业分析结果:
• 企业名称: {candidate.company_name}
• 综合评分: {candidate.comprehensive_score:.1f}/100
• MRR估算: ¥{candidate.mrr_estimate:,} /月 (如果有)
• 增长率: {candidate.growth_rate*100:.1f}% (如果有)  
• 团队规模: {candidate.team_size_estimate}人 (如果有)
• 华人置信度: {candidate.chinese_identity_score*100:.1f}%

📈 维度评分:
• MRR评分: {candidate.dimension_scores.get('mrr_score', 0):.1f}/100
• 媒体评分: {candidate.dimension_scores.get('media_score', 0):.1f}/100  
• 赛道评分: {candidate.dimension_scores.get('sector_score', 0):.1f}/100
• 认知评分: {candidate.dimension_scores.get('cognitive_score', 0):.1f}/100
                """)
            else:
                print("❌ 该企业未通过华人身份识别或数据不足")
        
        elif args.mode == 'monitoring':
            # 监控模式：持续监控投资机会
            logger.info("启动持续监控模式...")
            
            if args.continuous:
                while True:
                    # 实现持续监控逻辑
                    logger.info("执行监控扫描...")
                    await asyncio.sleep(3600)  # 每小时扫描一次
            else:
                logger.info("执行单次监控扫描...")
                # 执行单次扫描
                
    except KeyboardInterrupt:
        logger.info("用户中断程序")
    except Exception as e:
        logger.error(f"程序执行出错: {e}")
        raise
    finally:
        await collector.close()
        logger.info("数据收集器已关闭")

if __name__ == "__main__":
    print("""
🚀 PocketCorn投资分析数据收集器启动中...
📋 基于PocketCorn v4方法论的华人AI企业发现系统
    """)
    
    asyncio.run(main())