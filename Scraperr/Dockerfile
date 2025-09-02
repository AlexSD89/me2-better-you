# Scraperr - PocketCorn早期项目发现器 Docker镜像
FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 复制Python依赖文件
COPY requirements.txt* ./

# 安装Python依赖（如果requirements.txt存在）
RUN pip install --no-cache-dir \
    aiohttp \
    requests \
    lxml \
    beautifulsoup4 \
    asyncio \
    sqlite3 \
    || echo "使用基础依赖包"

# 复制应用文件
COPY . .

# 创建数据目录
RUN mkdir -p /app/data /app/results

# 设置环境变量
ENV PYTHONPATH=/app
ENV SCRAPERR_MODE=docker
ENV POCKETCORN_TARGET_MRR=50000

# 暴露端口（如果需要）
EXPOSE 8080

# 默认运行早期项目发现器
CMD ["python3", "pocketcorn_early_stage_scraper.py"]