import type { NextApiRequest, NextApiResponse } from 'next';
import fs from 'fs';
import path from 'path';

type Job = {
  id: string;
  name: string;
  type: string;
  status: string;
  created_at: string;
  targets: string[];
  sources: number;
  expected_completion: string;
};

type ApiResponse = {
  success: boolean;
  data?: Job[];
  error?: string;
};

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<ApiResponse>
) {
  if (req.method === 'GET') {
    try {
      // 读取data目录中的任务文件
      const dataDir = path.join(process.cwd(), 'data');
      const files = fs.readdirSync(dataDir).filter(file => 
        file.startsWith('scraperr_task_') && file.endsWith('.json')
      );

      const jobs: Job[] = [];
      
      files.forEach(file => {
        try {
          const filePath = path.join(dataDir, file);
          const fileContent = fs.readFileSync(filePath, 'utf8');
          const taskData = JSON.parse(fileContent);
          
          jobs.push({
            id: taskData.task_id,
            name: taskData.name,
            type: taskData.type,
            status: taskData.status,
            created_at: taskData.created_at,
            targets: taskData.targets || [],
            sources: taskData.sources || 0,
            expected_completion: taskData.expected_completion || 'Unknown'
          });
        } catch (error) {
          console.error(`Error reading file ${file}:`, error);
        }
      });

      // 按创建时间降序排列
      jobs.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());

      res.status(200).json({ success: true, data: jobs });
    } catch (error) {
      console.error('Error fetching PocketCorn jobs:', error);
      res.status(500).json({ 
        success: false, 
        error: 'Failed to fetch jobs' 
      });
    }
  } else if (req.method === 'POST') {
    // 创建新的PocketCorn投资分析任务
    try {
      const { targets, config } = req.body;
      
      const taskId = `pocketcorn_investment_${Date.now()}`;
      const taskData = {
        task_id: taskId,
        name: "PocketCorn华人AI企业投资分析",
        type: "investment_analysis",
        status: "pending",
        created_at: new Date().toISOString(),
        config: config || {
          target_companies: targets || [
            "智谱AI", "月之暗面", "零一万物", "DeepSeek", 
            "面壁智能", "MiniMax", "百川智能", "商汤科技", 
            "旷视科技", "字节跳动AI实验室"
          ],
          data_sources: 6,
          scoring_dimensions: ["MRR", "媒体", "赛道", "认知"]
        },
        targets: targets || [
          "智谱AI", "月之暗面", "零一万物", "DeepSeek", 
          "面壁智能", "MiniMax", "百川智能", "商汤科技", 
          "旷视科技", "字节跳动AI实验室"
        ],
        sources: 6,
        expected_completion: "2-4 hours"
      };

      // 保存到data目录
      const dataDir = path.join(process.cwd(), 'data');
      if (!fs.existsSync(dataDir)) {
        fs.mkdirSync(dataDir, { recursive: true });
      }
      
      const filePath = path.join(dataDir, `scraperr_task_${taskId}.json`);
      fs.writeFileSync(filePath, JSON.stringify(taskData, null, 2));

      res.status(201).json({ 
        success: true, 
        data: [taskData as Job]
      });
    } catch (error) {
      console.error('Error creating PocketCorn job:', error);
      res.status(500).json({ 
        success: false, 
        error: 'Failed to create job' 
      });
    }
  } else {
    res.setHeader('Allow', ['GET', 'POST']);
    res.status(405).json({ 
      success: false, 
      error: `Method ${req.method} Not Allowed` 
    });
  }
}