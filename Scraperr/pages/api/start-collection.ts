import type { NextApiRequest, NextApiResponse } from 'next';
import { spawn } from 'child_process';
import fs from 'fs';
import path from 'path';

type ApiResponse = {
  success: boolean;
  message?: string;
  jobId?: string;
  error?: string;
};

export default async function handler(
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
    const { jobId, targets } = req.body;

    if (!jobId) {
      return res.status(400).json({
        success: false,
        error: 'Job ID is required'
      });
    }

    // 更新任务状态为运行中
    const dataDir = path.join(process.cwd(), 'data');
    const taskFile = path.join(dataDir, `scraperr_task_${jobId}.json`);
    
    if (fs.existsSync(taskFile)) {
      const taskData = JSON.parse(fs.readFileSync(taskFile, 'utf8'));
      taskData.status = 'running';
      taskData.started_at = new Date().toISOString();
      fs.writeFileSync(taskFile, JSON.stringify(taskData, null, 2));
    }

    // 启动数据收集进程 - 使用我们已有的PocketCorn脚本
    const pythonScript = path.join(process.cwd(), 'pocketcorn_data_collection.py');
    
    // 为每个目标企业启动收集任务
    const targetCompanies = targets || [
      "智谱AI", "月之暗面", "零一万物", "DeepSeek", 
      "面壁智能", "MiniMax", "百川智能", "商汤科技"
    ];

    // 异步执行数据收集
    setTimeout(async () => {
      try {
        for (const company of targetCompanies) {
          console.log(`开始收集企业数据: ${company}`);
          
          // 使用现有的Web搜索API收集数据
          const searchResult = await fetch(`http://localhost:3000/api/search-company`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
              company: company,
              jobId: jobId 
            })
          }).catch(err => {
            console.error(`搜索${company}失败:`, err);
            return null;
          });

          // 等待一段时间避免请求过于频繁
          await new Promise(resolve => setTimeout(resolve, 2000));
        }

        // 更新任务状态为完成
        if (fs.existsSync(taskFile)) {
          const taskData = JSON.parse(fs.readFileSync(taskFile, 'utf8'));
          taskData.status = 'completed';
          taskData.completed_at = new Date().toISOString();
          fs.writeFileSync(taskFile, JSON.stringify(taskData, null, 2));
        }
      } catch (error) {
        console.error('数据收集过程中出错:', error);
        
        // 更新任务状态为失败
        if (fs.existsSync(taskFile)) {
          const taskData = JSON.parse(fs.readFileSync(taskFile, 'utf8'));
          taskData.status = 'failed';
          taskData.error = error.message;
          fs.writeFileSync(taskFile, JSON.stringify(taskData, null, 2));
        }
      }
    }, 100); // 立即开始异步执行

    res.status(200).json({
      success: true,
      message: '数据收集任务已启动',
      jobId: jobId
    });

  } catch (error) {
    console.error('启动数据收集失败:', error);
    res.status(500).json({
      success: false,
      error: '启动数据收集失败'
    });
  }
}