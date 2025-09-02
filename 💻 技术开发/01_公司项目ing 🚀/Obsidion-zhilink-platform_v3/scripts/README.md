# Git自动同步脚本使用指南

## 📋 概述

本目录包含了用于实现每小时自动上传到GitHub仓库的完整解决方案，包括：

- **Python自动同步脚本** - 核心同步逻辑
- **Shell启动脚本** - 服务管理
- **Crontab配置脚本** - 定时任务设置
- **配置文件** - 同步参数配置

## 🚀 快速开始

### 1. 安装依赖

确保系统已安装以下软件：
- Python 3.7+
- Git
- Crontab (系统自带)

### 2. 配置自动同步

```bash
# 进入脚本目录
cd scripts/

# 安装crontab定时任务
./crontab-setup.sh install

# 验证安装
./crontab-setup.sh verify
```

### 3. 测试执行

```bash
# 测试单次同步
./crontab-setup.sh test

# 或者直接运行Python脚本
python3 auto_git_sync.py --once
```

## 📁 文件说明

### 核心脚本

| 文件名 | 说明 | 用途 |
|--------|------|------|
| `auto_git_sync.py` | Python自动同步脚本 | 核心同步逻辑，支持单次执行和循环执行 |
| `auto-git-sync.sh` | Shell自动同步脚本 | Bash版本的同步脚本，适用于Linux/macOS |
| `start-auto-sync.sh` | 服务管理脚本 | 启动、停止、重启自动同步服务 |

### 配置和工具

| 文件名 | 说明 | 用途 |
|--------|------|------|
| `git-sync-config.json` | 配置文件 | 同步参数、排除模式、通知设置等 |
| `crontab-setup.sh` | Crontab配置脚本 | 安装、验证、管理定时任务 |

## ⚙️ 配置说明

### 配置文件 `git-sync-config.json`

```json
{
  "auto_sync": true,                    // 是否启用自动同步
  "sync_interval_hours": 1,             // 同步间隔（小时）
  "max_retries": 3,                     // 最大重试次数
  "retry_delay_seconds": 60,            // 重试延迟（秒）
  "exclude_patterns": [                 // 排除的文件模式
    "*.log",
    "node_modules/",
    ".next/"
  ],
  "include_patterns": [                 // 包含的文件模式
    "*.py",
    "*.ts",
    "*.md",
    "*.json"
  ]
}
```

### Crontab定时任务

安装后会自动创建以下定时任务：
```bash
# 每小时的第0分钟执行Git同步
0 * * * * cd /path/to/project && python3 scripts/auto_git_sync.py --once >> logs/cron-git-sync.log 2>&1
```

## 🎯 使用方法

### 方法1: Crontab定时任务（推荐）

```bash
# 安装定时任务
./crontab-setup.sh install

# 查看状态
./crontab-setup.sh status

# 移除定时任务
./crontab-setup.sh remove
```

### 方法2: 后台服务

```bash
# 启动服务
./start-auto-sync.sh start

# 查看状态
./start-auto-sync.sh status

# 停止服务
./start-auto-sync.sh stop

# 重启服务
./start-auto-sync.sh restart
```

### 方法3: 手动执行

```bash
# 执行单次同步
python3 auto_git_sync.py --once

# 运行同步循环（前台）
python3 auto_git_sync.py
```

## 📊 监控和日志

### 日志文件

- **自动同步日志**: `logs/git-sync.log`
- **Crontab执行日志**: `logs/cron-git-sync.log`
- **服务管理日志**: `logs/auto-sync-service.log`

### 查看日志

```bash
# 查看最近的日志
tail -f logs/git-sync.log

# 查看crontab执行日志
tail -f logs/cron-git-sync.log

# 查看服务状态
./start-auto-sync.sh logs
```

## 🔧 故障排除

### 常见问题

1. **权限问题**
   ```bash
   # 确保脚本有执行权限
   chmod +x scripts/*.sh
   ```

2. **Python路径问题**
   ```bash
   # 检查Python版本
   python3 --version
   
   # 使用完整路径
   /usr/bin/python3 auto_git_sync.py --once
   ```

3. **Git配置问题**
   ```bash
   # 检查Git配置
   git config --list
   
   # 设置用户信息
   git config user.name "Your Name"
   git config user.email "your.email@example.com"
   ```

### 调试模式

```bash
# 启用详细日志
export PYTHONPATH=.
python3 auto_git_sync.py --once --debug

# 查看Git状态
git status
git log --oneline -5
```

## 📈 性能优化

### 排除不必要的文件

在配置文件中添加排除模式，避免同步临时文件和构建产物：

```json
{
  "exclude_patterns": [
    "*.log",
    "*.tmp",
    "node_modules/",
    ".next/",
    "dist/",
    "build/",
    "coverage/",
    ".DS_Store"
  ]
}
```

### 批量提交

脚本会自动检测变更并批量提交，减少Git操作次数。

## 🔒 安全考虑

1. **SSH密钥**: 确保GitHub SSH密钥配置正确
2. **权限控制**: 脚本只操作当前项目目录
3. **日志记录**: 所有操作都有详细日志记录
4. **错误处理**: 包含完整的错误处理和重试机制

## 📞 技术支持

如果遇到问题，请检查：

1. 日志文件中的错误信息
2. Git仓库状态
3. 系统权限设置
4. Python环境配置

## 📝 更新日志

- **v1.0.0** (2025-08-13): 初始版本，支持基本自动同步功能
- 支持每小时自动同步
- 完整的错误处理和日志记录
- 多种部署方式（Crontab、服务、手动）
- 可配置的同步参数和排除模式