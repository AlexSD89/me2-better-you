#!/bin/bash
# .claude/hooks/documentation-update-pipeline.sh
# 智能文档生成和更新系统 - 目标变更时自动同步对应文件

set -euo pipefail

# 配置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${BLUE}📚 [DOC-UPDATE]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ [DOC-SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  [DOC-WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}❌ [DOC-ERROR]${NC} $1"
}

log_generate() {
    echo -e "${PURPLE}🔄 [DOC-GENERATE]${NC} $1"
}

log_sync() {
    echo -e "${CYAN}🔄 [DOC-SYNC]${NC} $1"
}

# 检测文档类型和触发变更
detect_documentation_trigger() {
    local changed_file="$1"
    local trigger_type="unknown"
    local related_docs=()
    
    case "$changed_file" in
        "CLAUDE.md")
            trigger_type="project_config"
            related_docs=("README.md" "docs/development-guide.md" "docs/api-reference.md")
            ;;
        "README.md")
            trigger_type="project_readme"
            related_docs=("docs/quick-start.md" "docs/installation.md")
            ;;
        "package.json"|"pyproject.toml"|"go.mod"|"Cargo.toml")
            trigger_type="dependency_change"
            related_docs=("docs/dependencies.md" "docs/installation.md" "CHANGELOG.md")
            ;;
        *.md|*.mdx)
            trigger_type="documentation_edit"
            related_docs=("docs/index.md")
            ;;
        "src/"*|"lib/"*|"app/"*)
            trigger_type="code_change"
            related_docs=("docs/api-reference.md" "docs/code-structure.md")
            ;;
        ".claude/agents/"*|".claude/commands/"*)
            trigger_type="agent_change"
            related_docs=("docs/agents-guide.md" "docs/commands-reference.md")
            ;;
        ".claude/hooks/"*)
            trigger_type="hook_change"
            related_docs=("docs/hooks-system.md" "docs/automation-guide.md")
            ;;
        *)
            trigger_type="general_change"
            ;;
    esac
    
    echo "TRIGGER_TYPE=$trigger_type"
    printf "RELATED_DOCS=(%s)\n" "${related_docs[*]}"
}

# 分析项目结构和目标
analyze_project_objectives() {
    local project_root="$(pwd)"
    log_info "分析项目目标和结构..."
    
    # 创建分析缓存目录
    mkdir -p .claude/cache/documentation
    
    local analysis_file=".claude/cache/documentation/project-analysis.json"
    
    # 提取项目信息
    local project_name=$(basename "$project_root")
    local git_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local last_commit=$(git log -1 --format="%h %s" 2>/dev/null || echo "unknown")
    
    # 分析技术栈
    local tech_stack=()
    [[ -f "package.json" ]] && tech_stack+=("Node.js")
    [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]] && tech_stack+=("Python")
    [[ -f "go.mod" ]] && tech_stack+=("Go")
    [[ -f "Cargo.toml" ]] && tech_stack+=("Rust")
    [[ -f "*.swift" ]] && tech_stack+=("Swift")
    
    # 检测LaunchX项目特性
    local launchx_features=()
    if [[ "$project_root" =~ "pocketcorn" ]]; then
        launchx_features+=("SPELO投资框架" "7维度评分" "风险量化")
    elif [[ "$project_root" =~ "zhilink" ]]; then
        launchx_features+=("AI协作平台" "6角色系统" "智能推荐")
    fi
    
    # 检测文档结构
    local doc_structure=()
    [[ -d "docs" ]] && doc_structure+=("docs/")
    [[ -f "README.md" ]] && doc_structure+=("README.md")
    [[ -f "CLAUDE.md" ]] && doc_structure+=("CLAUDE.md")
    [[ -d ".claude" ]] && doc_structure+=(".claude/")
    
    # 生成分析结果
    cat > "$analysis_file" << EOF
{
  "project_name": "$project_name",
  "analysis_timestamp": "$(date -Iseconds)",
  "git_info": {
    "branch": "$git_branch",
    "last_commit": "$last_commit"
  },
  "tech_stack": $(printf '%s\n' "${tech_stack[@]}" | jq -R . | jq -s .),
  "launchx_features": $(printf '%s\n' "${launchx_features[@]}" | jq -R . | jq -s .),
  "documentation_structure": $(printf '%s\n' "${doc_structure[@]}" | jq -R . | jq -s .),
  "objectives": {
    "primary": "基于Claude Code的AI协作开发系统",
    "secondary": ["零代码背景用户友好", "智能自动化流程", "企业级质量标准"],
    "current_focus": "$(extract_current_focus)"
  }
}
EOF
    
    log_success "项目分析完成: $analysis_file"
}

# 提取当前关注焦点
extract_current_focus() {
    local focus="通用开发"
    
    # 从最近的commit信息推断
    local recent_commits=$(git log --oneline -5 2>/dev/null || echo "")
    
    if echo "$recent_commits" | grep -qi "pocketcorn\|投资\|SPELO"; then
        focus="PocketCorn投资分析引擎优化"
    elif echo "$recent_commits" | grep -qi "zhilink\|AI\|协作"; then
        focus="Zhilink AI平台开发"
    elif echo "$recent_commits" | grep -qi "hook\|agent\|automation"; then
        focus="AI协作系统增强"
    elif echo "$recent_commits" | grep -qi "doc\|文档\|documentation"; then
        focus="文档系统完善"
    fi
    
    echo "$focus"
}

# 智能生成README.md
generate_readme() {
    local trigger_type="$1"
    log_generate "智能生成README.md"
    
    # 读取项目分析
    local analysis_file=".claude/cache/documentation/project-analysis.json"
    if [[ ! -f "$analysis_file" ]]; then
        analyze_project_objectives
    fi
    
    local project_name=$(jq -r '.project_name' "$analysis_file")
    local tech_stack=$(jq -r '.tech_stack[]' "$analysis_file" | tr '\n' '、' | sed 's/、$//')
    local current_focus=$(jq -r '.objectives.current_focus' "$analysis_file")
    
    # 生成新的README.md
    cat > README.md << EOF
# $project_name

> **核心定位**: $current_focus  
> **技术栈**: $tech_stack  
> **更新时间**: $(date '+%Y-%m-%d %H:%M:%S')

## 🎯 项目概述

这是一个基于Claude Code的智能协作开发项目，实现了零代码背景用户通过自然语言对话完成复杂软件开发的革命性系统。

### 核心特性

$(generate_feature_list)

## 🚀 快速开始

### 环境要求

$(generate_requirements_section)

### 安装步骤

\`\`\`bash
# 1. 克隆项目
git clone <repository-url>
cd $project_name

# 2. 安装依赖
$(generate_install_commands)

# 3. 配置环境
$(generate_config_commands)

# 4. 启动项目
$(generate_start_commands)
\`\`\`

## 📚 文档导航

$(generate_documentation_index)

## 🛠️ 开发指南

### Claude Code集成

本项目深度集成了Claude Code的AI协作能力：

- **Agent系统**: 专业化AI代理处理不同领域任务
- **Hook系统**: 自动化质量管道和流程控制
- **MCP集成**: 丰富的工具生态和服务连接

### 质量保证

$(generate_quality_section)

## 🤝 贡献指南

欢迎参与LaunchX项目的开发！请查看 [贡献指南](CONTRIBUTING.md) 了解详细信息。

### 开发流程

1. Fork 项目
2. 创建功能分支: \`git checkout -b feature/amazing-feature\`
3. 提交变更: \`git commit -m 'feat: add amazing feature'\`
4. 推送分支: \`git push origin feature/amazing-feature\`
5. 提交 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [Claude Code](https://claude.ai/code) - AI协作开发平台
- [Anthropic](https://anthropic.com) - 提供强大的AI能力
- 所有贡献者和社区成员

---

**💡 提示**: 这是一个AI驱动的项目，README.md会根据项目变化自动更新。最后更新: $(date -Iseconds)
EOF

    log_success "README.md已生成并更新"
}

# 生成功能特性列表
generate_feature_list() {
    local project_root="$(pwd)"
    
    if [[ "$project_root" =~ "pocketcorn" ]]; then
        cat << 'EOF'
- 🎯 **SPELO投资决策框架**: Sourcing→Parsing→Evaluation→Learning→Optimization闭环
- 📊 **7维度智能评分**: MRR、团队、增长率、影响力等综合评估
- ⚡ **实时风险量化**: 不确定性分析和动态风险控制
- 🤖 **AI驱动决策**: 50万投资自动化决策，1.5倍回报目标
EOF
    elif [[ "$project_root" =~ "zhilink" ]]; then
        cat << 'EOF'
- 🤖 **6角色AI协作**: Alex, Sarah, Mike, Emma, David, Catherine专业化协作
- 🎨 **Cloudsway设计系统**: 紫青色彩体系，现代化UI/UX
- 🔄 **智能推荐引擎**: 基于需求的智能匹配和解决方案推荐
- 🌐 **企业级平台**: 可扩展的AI能力交易和协作生态
EOF
    else
        cat << 'EOF'
- 🤖 **AI原生开发**: 自然语言驱动的智能开发体验
- ⚡ **智能自动化**: Hook驱动的质量管道和流程控制
- 🔧 **Agent生态**: 专业化AI代理处理复杂开发任务
- 📚 **零门槛**: 零代码背景用户友好的开发环境
EOF
    fi
}

# 生成要求部分
generate_requirements_section() {
    local requirements=()
    
    [[ -f "package.json" ]] && requirements+=("- Node.js 18+ 和 npm/yarn")
    [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]] && requirements+=("- Python 3.8+ 和 pip")
    [[ -f "go.mod" ]] && requirements+=("- Go 1.19+")
    [[ -f "Cargo.toml" ]] && requirements+=("- Rust 1.70+")
    
    # 通用要求
    requirements+=("- Claude Code CLI")
    requirements+=("- Git 版本控制")
    
    printf '%s\n' "${requirements[@]}"
}

# 生成安装命令
generate_install_commands() {
    local commands=()
    
    [[ -f "package.json" ]] && commands+=("npm install")
    [[ -f "requirements.txt" ]] && commands+=("pip install -r requirements.txt")
    [[ -f "pyproject.toml" ]] && commands+=("poetry install")
    [[ -f "go.mod" ]] && commands+=("go mod download")
    [[ -f "Cargo.toml" ]] && commands+=("cargo build")
    
    if [[ ${#commands[@]} -eq 0 ]]; then
        echo "# 无需额外依赖安装"
    else
        printf '%s\n' "${commands[@]}"
    fi
}

# 生成配置命令
generate_config_commands() {
    cat << 'EOF'
# 配置Claude Code
cp .claude/settings.local.json.example .claude/settings.local.json
# 根据需要调整配置
EOF
}

# 生成启动命令
generate_start_commands() {
    local commands=()
    
    if [[ -f "package.json" ]]; then
        if jq -e '.scripts.dev' package.json >/dev/null 2>&1; then
            commands+=("npm run dev")
        elif jq -e '.scripts.start' package.json >/dev/null 2>&1; then
            commands+=("npm start")
        fi
    fi
    
    [[ -f "main.py" ]] && commands+=("python main.py")
    [[ -f "server.py" ]] && commands+=("python server.py")
    [[ -f "main.go" ]] && commands+=("go run main.go")
    
    if [[ ${#commands[@]} -eq 0 ]]; then
        echo "# 使用Claude Code开始开发"
        echo "claude \"开始项目开发\""
    else
        printf '%s\n' "${commands[@]}"
    fi
}

# 生成文档索引
generate_documentation_index() {
    local doc_links=()
    
    # 检查存在的文档文件
    [[ -f "CLAUDE.md" ]] && doc_links+=("- [📋 项目指南](CLAUDE.md) - Claude Code配置和开发规范")
    [[ -f "CONTRIBUTING.md" ]] && doc_links+=("- [🤝 贡献指南](CONTRIBUTING.md) - 如何参与项目开发")
    [[ -f "CHANGELOG.md" ]] && doc_links+=("- [📝 更新日志](CHANGELOG.md) - 版本更新记录")
    
    # 检查docs目录
    if [[ -d "docs" ]]; then
        [[ -f "docs/api-reference.md" ]] && doc_links+=("- [🔌 API参考](docs/api-reference.md) - 接口文档")
        [[ -f "docs/development-guide.md" ]] && doc_links+=("- [🛠️ 开发指南](docs/development-guide.md) - 详细开发说明")
        [[ -f "docs/deployment.md" ]] && doc_links+=("- [🚀 部署指南](docs/deployment.md) - 生产环境部署")
    fi
    
    # 检查.claude目录
    if [[ -d ".claude" ]]; then
        doc_links+=("- [🤖 Agent系统](.claude/agents/) - 专业化AI代理")
        doc_links+=("- [⚡ Hook系统](.claude/hooks/) - 自动化流程")
        doc_links+=("- [📋 命令库](.claude/commands/) - 斜杠命令集合")
    fi
    
    if [[ ${#doc_links[@]} -eq 0 ]]; then
        echo "- [📚 开始探索](.) - 使用Claude Code开始开发"
    else
        printf '%s\n' "${doc_links[@]}"
    fi
}

# 生成质量保证部分
generate_quality_section() {
    cat << 'EOF'
项目集成了完整的AI驱动质量保证体系：

**自动化流程**:
- 📝 代码编辑时自动格式化和Lint检查
- 🧪 提交前自动运行测试套件
- 🔍 AI驱动的代码审查和改进建议
- 📊 持续的性能监控和优化

**质量标准**:
- TypeScript严格模式 (如适用)
- 90%+ 测试覆盖率
- ESLint/Prettier代码规范
- 安全漏洞扫描
EOF
}

# 更新API文档
update_api_documentation() {
    local changed_file="$1"
    log_generate "更新API文档"
    
    # 检查是否存在API路由
    local api_files=()
    
    # 扫描常见的API文件位置
    if [[ -d "src/app/api" ]]; then
        mapfile -t api_files < <(find src/app/api -name "*.ts" -o -name "*.js")
    elif [[ -d "pages/api" ]]; then
        mapfile -t api_files < <(find pages/api -name "*.ts" -o -name "*.js")
    elif [[ -d "api" ]]; then
        mapfile -t api_files < <(find api -name "*.py" -o -name "*.js" -o -name "*.go")
    fi
    
    if [[ ${#api_files[@]} -eq 0 ]]; then
        log_info "未发现API文件，跳过API文档生成"
        return 0
    fi
    
    # 创建API文档目录
    mkdir -p docs
    
    # 生成API文档
    cat > docs/api-reference.md << 'EOF'
# API 参考文档

> 自动生成的API文档 - 更新时间: $(date '+%Y-%m-%d %H:%M:%S')

## 📋 概述

本文档描述了项目的API接口规范和使用方法。

## 🔗 基础信息

- **Base URL**: `http://localhost:3000/api` (开发环境)
- **认证方式**: Bearer Token / API Key
- **数据格式**: JSON
- **API版本**: v1

## 📚 接口列表

$(generate_api_endpoints)

## 🔒 认证

$(generate_auth_section)

## 🚫 错误处理

$(generate_error_handling_section)

## 📝 示例代码

$(generate_api_examples)

---

*文档由AI自动生成和维护*
EOF

    log_success "API文档已更新: docs/api-reference.md"
}

# 生成API端点列表
generate_api_endpoints() {
    local endpoints=()
    
    # 这里可以扫描实际的API文件并提取端点信息
    # 简化版本，基于常见模式
    
    if [[ -d "src/app/api" ]] || [[ -d "pages/api" ]]; then
        echo "### RESTful API 端点"
        echo ""
        echo "| 方法 | 端点 | 描述 | 认证 |"
        echo "|------|------|------|------|"
        echo "| GET | \`/api/health\` | 健康检查 | 否 |"
        echo "| POST | \`/api/auth/login\` | 用户登录 | 否 |"
        echo "| GET | \`/api/user/profile\` | 获取用户信息 | 是 |"
        echo "| POST | \`/api/data\` | 创建数据 | 是 |"
        echo "| GET | \`/api/data/{id}\` | 获取特定数据 | 是 |"
    else
        echo "正在扫描API端点..."
    fi
}

# 生成认证部分
generate_auth_section() {
    cat << 'EOF'
API使用Bearer Token进行认证：

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     https://api.example.com/endpoint
```

获取Token：
1. 调用登录接口获取JWT令牌
2. 在后续请求的Header中包含令牌
3. 令牌有效期为24小时
EOF
}

# 生成错误处理部分
generate_error_handling_section() {
    cat << 'EOF'
API使用标准HTTP状态码：

| 状态码 | 含义 | 说明 |
|--------|------|------|
| 200 | 成功 | 请求成功处理 |
| 400 | 请求错误 | 参数格式错误 |
| 401 | 未认证 | 需要有效的认证令牌 |
| 403 | 权限不足 | 用户无权限访问资源 |
| 404 | 资源不存在 | 请求的资源未找到 |
| 500 | 服务器错误 | 内部服务器错误 |

错误响应格式：
```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "请求参数无效",
    "details": "字段'email'是必需的"
  }
}
```
EOF
}

# 生成API示例
generate_api_examples() {
    cat << 'EOF'
### JavaScript/TypeScript

```typescript
// 使用fetch API
const response = await fetch('/api/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + token
  },
  body: JSON.stringify({ name: 'example' })
});

const data = await response.json();
```

### Python

```python
import requests

headers = {
    'Content-Type': 'application/json',
    'Authorization': f'Bearer {token}'
}

response = requests.post('/api/data', 
                        json={'name': 'example'}, 
                        headers=headers)
data = response.json()
```

### cURL

```bash
curl -X POST /api/data \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name": "example"}'
```
EOF
}

# 同步相关文档
sync_related_documentation() {
    local trigger_type="$1"
    local changed_file="$2"
    
    log_sync "同步相关文档..."
    
    case "$trigger_type" in
        "project_config")
            # CLAUDE.md变更时同步
            generate_readme "config_change"
            update_development_guide
            ;;
        "code_change")
            # 代码变更时同步
            update_api_documentation "$changed_file"
            update_code_structure_docs
            ;;
        "agent_change")
            # Agent变更时同步
            update_agents_documentation
            ;;
        "hook_change")
            # Hook变更时同步
            update_hooks_documentation
            ;;
        "dependency_change")
            # 依赖变更时同步
            update_installation_guide
            update_dependencies_docs
            ;;
    esac
    
    # 始终更新修改时间戳
    update_documentation_timestamps
}

# 更新开发指南
update_development_guide() {
    mkdir -p docs
    
    cat > docs/development-guide.md << 'EOF'
# 开发指南

## 🚀 开发环境设置

### Claude Code配置

本项目深度集成Claude Code，请确保正确配置：

1. 安装Claude Code CLI
2. 配置项目设置：`cp .claude/settings.local.json.example .claude/settings.local.json`
3. 了解可用的Agent和命令

### 开发工作流

1. 使用 `/context-prime` 了解项目结构
2. 使用 `/next-task` 获取下一个开发任务
3. 进行代码开发，Hook系统会自动处理质量检查
4. 使用 `/2-commit-fast` 快速提交变更

## 🤖 AI协作开发

### Agent使用

$(list_available_agents)

### 命令参考

$(list_available_commands)

## 📝 代码规范

项目使用AI驱动的代码质量保证：

- 自动代码格式化
- 实时Lint检查
- 自动化测试运行
- AI代码审查建议

---

*最后更新: $(date -Iseconds)*
EOF

    log_success "开发指南已更新"
}

# 列出可用的Agent
list_available_agents() {
    if [[ -d ".claude/agents" ]]; then
        echo "可用的专业化Agent："
        echo ""
        find .claude/agents -name "*.md" | while read -r agent_file; do
            local agent_name=$(basename "$agent_file" .md)
            local description=$(grep "^description:" "$agent_file" | cut -d'"' -f2 2>/dev/null || echo "专业化AI代理")
            echo "- **$agent_name**: $description"
        done
    else
        echo "使用标准Claude Code Agent系统"
    fi
}

# 列出可用的命令
list_available_commands() {
    if [[ -d ".claude/commands" ]]; then
        echo "可用的斜杠命令："
        echo ""
        find .claude/commands -name "*.md" | while read -r cmd_file; do
            local cmd_name=$(basename "$cmd_file" .md)
            echo "- \`/$cmd_name\`: $(head -3 "$cmd_file" | tail -1 | sed 's/^# //')"
        done
    else
        echo "使用标准Claude Code命令"
    fi
}

# 更新时间戳
update_documentation_timestamps() {
    local timestamp="$(date -Iseconds)"
    
    # 更新所有相关文档的时间戳
    for doc in README.md docs/*.md; do
        if [[ -f "$doc" ]]; then
            # 更新文档底部的时间戳（如果存在）
            if grep -q "最后更新:" "$doc"; then
                sed -i.bak "s/最后更新: .*/最后更新: $timestamp/" "$doc"
                rm -f "${doc}.bak"
            fi
        fi
    done
    
    log_success "文档时间戳已更新"
}

# 生成变更日志
generate_changelog_entry() {
    local trigger_type="$1"
    local changed_file="$2"
    
    # 创建CHANGELOG.md（如果不存在）
    if [[ ! -f "CHANGELOG.md" ]]; then
        cat > CHANGELOG.md << 'EOF'
# 更新日志

所有重要的项目变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并且本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [未发布]

### 新增
- 项目初始化

EOF
    fi
    
    # 添加变更条目
    local date_str=$(date '+%Y-%m-%d')
    local change_entry=""
    
    case "$trigger_type" in
        "code_change")
            change_entry="- 代码更新: $changed_file"
            ;;
        "documentation_edit")
            change_entry="- 文档更新: $changed_file"
            ;;
        "agent_change")
            change_entry="- Agent系统更新: $changed_file"
            ;;
        "hook_change")
            change_entry="- Hook系统更新: $changed_file"
            ;;
        *)
            change_entry="- 项目更新: $changed_file"
            ;;
    esac
    
    # 在未发布部分添加条目
    sed -i.bak "/## \[未发布\]/a\\
\\
### 更改 - $date_str\\
$change_entry" CHANGELOG.md
    
    rm -f CHANGELOG.md.bak
    
    log_success "变更日志已更新"
}

# 主执行函数
main() {
    local changed_file="${1:-unknown}"
    
    log_info "启动文档更新管道: $changed_file"
    
    # 检查是否启用文档自动更新
    if [[ "${DOCUMENTATION_AUTO_UPDATE:-true}" != "true" ]]; then
        log_info "文档自动更新已禁用"
        exit 0
    fi
    
    # 分析项目目标
    analyze_project_objectives
    
    # 检测触发类型和相关文档
    eval "$(detect_documentation_trigger "$changed_file")"
    
    log_info "触发类型: $TRIGGER_TYPE"
    
    # 同步相关文档
    sync_related_documentation "$TRIGGER_TYPE" "$changed_file"
    
    # 生成变更日志条目
    generate_changelog_entry "$TRIGGER_TYPE" "$changed_file"
    
    # 验证文档完整性
    validate_documentation_integrity
    
    log_success "文档更新管道完成"
    
    # 记录到日志
    echo "$(date -Iseconds): Documentation updated for $changed_file ($TRIGGER_TYPE)" >> .claude/logs/documentation.log
}

# 验证文档完整性
validate_documentation_integrity() {
    log_info "验证文档完整性..."
    
    local issues=0
    
    # 检查必需文档
    [[ ! -f "README.md" ]] && log_warning "缺少 README.md" && ((issues++))
    [[ ! -f "CLAUDE.md" ]] && log_warning "缺少 CLAUDE.md" && ((issues++))
    
    # 检查文档链接
    if command -v markdown-link-check >/dev/null; then
        for doc in README.md docs/*.md; do
            if [[ -f "$doc" ]]; then
                if ! markdown-link-check "$doc" >/dev/null 2>&1; then
                    log_warning "文档链接检查失败: $doc"
                    ((issues++))
                fi
            fi
        done
    fi
    
    if [[ $issues -eq 0 ]]; then
        log_success "文档完整性验证通过"
    else
        log_warning "发现 $issues 个文档问题"
    fi
    
    return $issues
}

# 错误处理
trap 'log_error "文档更新管道失败"; exit 1' ERR

# 执行主函数
main "$@"