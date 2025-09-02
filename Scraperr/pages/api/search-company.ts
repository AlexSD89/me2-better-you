import type { NextApiRequest, NextApiResponse } from 'next';
import fs from 'fs';
import path from 'path';

type CompanyData = {
  company: string;
  funding_info: string;
  team_size: string;
  recruitment_info: string;
  market_presence: string;
  technical_strength: string;
  collected_at: string;
};

type ApiResponse = {
  success: boolean;
  data?: CompanyData;
  error?: string;
};

// 模拟的企业数据 - 基于之前WebSearch收集的信息
const mockCompanyData: { [key: string]: CompanyData } = {
  "智谱AI": {
    company: "智谱AI",
    funding_info: "最新融资30亿人民币，投资方包括红杉中国、高瓴、顺为资本、腾讯、阿里、美团、小米等，估值超过200亿人民币",
    team_size: "招聘54个职位，分布在北京、上海、深圳，主要为技术岗位",
    recruitment_info: "大量招聘AI工程师、算法工程师、前端开发、运维开发等，提供弹性工作、全额公积金等福利",
    market_presence: "2024年商业化收入增长100%以上，API年收入同比增长超过30倍，C端用户超过2500万",
    technical_strength: "清华系技术团队，27年AI技术积累，拥有GLM系列大模型",
    collected_at: new Date().toISOString()
  },
  "月之暗面": {
    company: "月之暗面",
    funding_info: "最新3亿美元融资，估值33亿美元(约236亿人民币)，投资方包括阿里、红杉中国、真格基金等20+知名机构",
    team_size: "团队由清华、CMU、Google Brain、Facebook AI等顶尖人才组成",
    recruitment_info: "积极招聘中，专注长文本处理技术人才",
    market_presence: "Kimi App Store免费版应用第5名，月访问量1218万次，仅次于百度文心一言",
    technical_strength: "全球首个支持200万字长文本的AI助手，技术世界领先",
    collected_at: new Date().toISOString()
  },
  "零一万物": {
    company: "零一万物",
    funding_info: "阿里云领投，估值超10亿美元，成为AI 2.0独角兽",
    team_size: "核心团队来自Google、微软、阿里、百度、字节、腾讯等顶级企业",
    recruitment_info: "李开复亲自号召世界级人才，技术副总裁为Google Bard早期核心成员",
    market_presence: "Yi-34B模型在Hugging Face排名全球第一(70.72分)",
    technical_strength: "Yi系列开源模型，技术实力强劲但面临大厂竞争压力",
    collected_at: new Date().toISOString()
  }
};

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<ApiResponse>
) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST']);
    return res.status(405).json({ 
      success: false, 
      error: `Method ${req.method} Not Allowed` 
    });
  }

  try {
    const { company, jobId } = req.body;

    if (!company) {
      return res.status(400).json({
        success: false,
        error: 'Company name is required'
      });
    }

    // 获取企业数据（这里使用模拟数据，实际环境中会调用真实的搜索API）
    const companyData = mockCompanyData[company] || {
      company: company,
      funding_info: "暂无融资信息",
      team_size: "团队规模未知",
      recruitment_info: "招聘信息待收集",
      market_presence: "市场表现待分析",
      technical_strength: "技术实力评估中",
      collected_at: new Date().toISOString()
    };

    // 保存收集的数据到results目录
    const resultsDir = path.join(process.cwd(), 'data', 'results');
    if (!fs.existsSync(resultsDir)) {
      fs.mkdirSync(resultsDir, { recursive: true });
    }

    const resultFile = path.join(resultsDir, `${company}_${Date.now()}.json`);
    fs.writeFileSync(resultFile, JSON.stringify({
      jobId,
      ...companyData,
      mrr_estimate: estimateMRR(companyData),
      investment_score: calculateInvestmentScore(companyData)
    }, null, 2));

    console.log(`✅ 已收集企业数据: ${company}`);

    res.status(200).json({
      success: true,
      data: companyData
    });

  } catch (error) {
    console.error('搜索企业数据失败:', error);
    res.status(500).json({
      success: false,
      error: '搜索企业数据失败'
    });
  }
}

// 简单的MRR估算函数
function estimateMRR(data: CompanyData): number {
  let estimate = 50000; // 基础估算

  // 基于融资信息调整
  if (data.funding_info.includes('亿') || data.funding_info.includes('billion')) {
    estimate *= 5;
  }
  
  // 基于团队规模调整
  if (data.team_size.includes('54') || data.team_size.includes('大量')) {
    estimate *= 2;
  }

  // 基于市场表现调整
  if (data.market_presence.includes('增长') || data.market_presence.includes('第一')) {
    estimate *= 3;
  }

  return Math.round(estimate);
}

// 简单的投资评分函数
function calculateInvestmentScore(data: CompanyData): number {
  let score = 60; // 基础分

  // MRR维度 (40%)
  const mrr = estimateMRR(data);
  if (mrr > 500000) score += 16;
  else if (mrr > 200000) score += 12;
  else if (mrr > 100000) score += 8;

  // 媒体维度 (20%)
  if (data.market_presence.includes('第一') || data.market_presence.includes('领先')) {
    score += 8;
  }

  // 赛道维度 (25%)
  if (data.technical_strength.includes('世界领先') || data.technical_strength.includes('全球第一')) {
    score += 10;
  }

  // 认知维度 (15%)
  if (data.team_size.includes('清华') || data.team_size.includes('Google') || data.team_size.includes('顶尖')) {
    score += 6;
  }

  return Math.min(100, Math.max(0, score));
}