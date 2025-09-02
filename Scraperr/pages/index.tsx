import React, { useState, useEffect } from 'react';

export default function Home() {
  const [jobs, setJobs] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isCreating, setIsCreating] = useState(false);

  const loadPocketCornJobs = async () => {
    try {
      const response = await fetch('/api/pocketcorn-jobs');
      const result = await response.json();
      if (result.success) {
        setJobs(result.data || []);
      }
    } catch (error) {
      console.error('Failed to load PocketCorn jobs:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const createNewTask = async () => {
    setIsCreating(true);
    try {
      const response = await fetch('/api/pocketcorn-jobs', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          targets: [
            "智谱AI", "月之暗面", "零一万物", "DeepSeek", 
            "面壁智能", "MiniMax", "百川智能", "商汤科技"
          ]
        })
      });
      const result = await response.json();
      if (result.success) {
        await loadPocketCornJobs(); // 重新加载任务列表
      }
    } catch (error) {
      console.error('Failed to create task:', error);
    } finally {
      setIsCreating(false);
    }
  };

  const startCollection = async (jobId: string, targets: string[]) => {
    try {
      const response = await fetch('/api/start-collection', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ jobId, targets })
      });
      const result = await response.json();
      if (result.success) {
        console.log('数据收集已启动:', result.message);
        // 每5秒刷新一次任务状态
        const interval = setInterval(async () => {
          await loadPocketCornJobs();
          const currentJob = jobs.find((job: any) => job.id === jobId);
          if (currentJob && currentJob.status !== 'running') {
            clearInterval(interval);
          }
        }, 5000);
      }
    } catch (error) {
      console.error('启动数据收集失败:', error);
    }
  };

  useEffect(() => {
    loadPocketCornJobs();
  }, []);

  return (
    <div className="min-h-screen bg-gray-100">
      <div className="container mx-auto px-4 py-8">
        <header className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-2">Scraperr</h1>
          <p className="text-xl text-gray-600">PocketCorn Investment Analysis Platform</p>
        </header>

        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-2xl font-semibold mb-4">投资分析任务</h2>
          
          {isLoading ? (
            <div className="text-center">
              <p>加载中...</p>
            </div>
          ) : (
            <div className="grid gap-4">
              {jobs.length > 0 ? (
                jobs.map((job: any, index) => (
                  <div key={index} className="border rounded-lg p-4 hover:shadow-lg transition-shadow">
                    <h3 className="font-medium text-lg">{job.name || `任务 ${index + 1}`}</h3>
                    <p className="text-gray-600">{job.description || '暂无描述'}</p>
                    <div className="mt-2 flex justify-between items-center">
                      <span className={`px-2 py-1 rounded text-sm ${
                        job.status === 'completed' ? 'bg-green-100 text-green-800' :
                        job.status === 'running' ? 'bg-blue-100 text-blue-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {job.status || 'pending'}
                      </span>
                      <div className="flex gap-2">
                        <button 
                          onClick={() => startCollection(job.id, job.targets)}
                          disabled={job.status === 'running'}
                          className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 disabled:opacity-50"
                        >
                          {job.status === 'running' ? '收集中...' : '开始收集'}
                        </button>
                        <button className="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600">
                          查看详情
                        </button>
                      </div>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8">
                  <p className="text-gray-500 mb-4">暂无任务</p>
                  <button 
                    onClick={createNewTask}
                    disabled={isCreating}
                    className="bg-green-500 text-white px-6 py-2 rounded hover:bg-green-600 disabled:opacity-50"
                  >
                    {isCreating ? '创建中...' : '创建PocketCorn投资分析任务'}
                  </button>
                </div>
              )}
            </div>
          )}
        </div>

        <div className="mt-8 grid md:grid-cols-2 gap-6">
          <div className="bg-white rounded-lg shadow-md p-6">
            <h3 className="text-xl font-semibold mb-3">PocketCorn 配置</h3>
            <p className="text-gray-600 mb-4">华人AI企业投资分析配置已加载</p>
            <ul className="text-sm text-gray-600 space-y-1">
              <li>• 目标企业: 10家华人AI公司</li>
              <li>• 数据源: 6个中文网站</li>
              <li>• 评分维度: MRR+媒体+赛道+认知</li>
            </ul>
          </div>
          
          <div className="bg-white rounded-lg shadow-md p-6">
            <h3 className="text-xl font-semibold mb-3">系统状态</h3>
            <div className="space-y-2 text-sm">
              <div className="flex justify-between">
                <span>配置文件状态:</span>
                <span className="text-green-600">✓ 已加载</span>
              </div>
              <div className="flex justify-between">
                <span>数据库连接:</span>
                <span className="text-green-600">✓ 正常</span>
              </div>
              <div className="flex justify-between">
                <span>API服务:</span>
                <span className="text-yellow-600">⚠ 需要启动</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}