#!/bin/bash

# Ultimate Intent Processor Hook
# LayerX 智能协作系统 - 用户意图智能识别和路由处理

# 1. 创建项目分析智能文件
create_project_analysis() {
    local user_input="$1"
    
    # 投资关键词密度计算
    investment_keywords=("投资" "分析" "评估" "收益" "风险" "回报" "估值" "独角兽" "融资" "股权")
    investment_score=0
    for keyword in "${investment_keywords[@]}"; do
        if echo "$user_input" | grep -q "$keyword"; then
            ((investment_score++))
        fi
    done
    investment_density=$(echo "scale=2; $investment_score / ${#investment_keywords[@]}" | bc -l)
    
    # 企业服务复杂度计算
    service_keywords=("企业" "客户" "服务" "解决方案" "需求" "交付" "AI能力" "咨询")
    service_score=0
    for keyword in "${service_keywords[@]}"; do
        if echo "$user_input" | grep -q "$keyword"; then
            ((service_score++))
        fi
    done
    service_complexity=$(echo "scale=2; $service_score / ${#service_keywords[@]}" | bc -l)
    
    # 技术开发深度计算
    tech_keywords=("开发" "创建" "实现" "功能" "系统" "平台" "代码" "架构")
    tech_score=0
    for keyword in "${tech_keywords[@]}"; do
        if echo "$user_input" | grep -q "$keyword"; then
            ((tech_score++))
        fi
    done
    tech_depth=$(echo "scale=2; $tech_score / ${#tech_keywords[@]}" | bc -l)
    
    # 学习研究意图计算
    learning_keywords=("学习" "研究" "趋势" "知识" "报告" "调研" "分析" "洞察")
    learning_score=0
    for keyword in "${learning_keywords[@]}"; do
        if echo "$user_input" | grep -q "$keyword"; then
            ((learning_score++))
        fi
    done
    learning_intent=$(echo "scale=2; $learning_score / ${#learning_keywords[@]}" | bc -l)
    
    # 生成项目分析JSON
    cat > /tmp/project_analysis.json << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "user_input": "$user_input",
    "analysis_scores": {
        "investment_density": $investment_density,
        "service_complexity": $service_complexity,
        "tech_depth": $tech_depth,
        "learning_intent": $learning_intent
    },
    "priority_domain": "$(determine_priority_domain $investment_density $service_complexity $tech_depth $learning_intent)",
    "confidence_level": "$(calculate_confidence $investment_density $service_complexity $tech_depth $learning_intent)",
    "recommended_context": "$(recommend_context $investment_density $service_complexity $tech_depth $learning_intent)"
}
EOF
}

# 确定优先业务域
determine_priority_domain() {
    local inv=$1 ser=$2 tech=$3 learn=$4
    
    if (( $(echo "$inv > 0.7" | bc -l) )); then
        echo "investment_analysis"
    elif (( $(echo "$ser > 0.6" | bc -l) )); then
        echo "enterprise_service"
    elif (( $(echo "$tech > 0.5" | bc -l) )); then
        echo "technical_development"
    elif (( $(echo "$learn > 0.4" | bc -l) )); then
        echo "knowledge_research"
    else
        echo "general_purpose"
    fi
}

# 计算确定性信心
calculate_confidence() {
    local inv=$1 ser=$2 tech=$3 learn=$4
    local max_score=$(echo "$inv $ser $tech $learn" | tr ' ' '\n' | sort -nr | head -1)
    
    if (( $(echo "$max_score > 0.8" | bc -l) )); then
        echo "high"
    elif (( $(echo "$max_score > 0.5" | bc -l) )); then
        echo "medium"
    else
        echo "low"
    fi
}

# 推荐上下文路径
recommend_context() {
    local inv=$1 ser=$2 tech=$3 learn=$4
    
    if (( $(echo "$inv > 0.7" | bc -l) )); then
        echo "/💻 技术开发/01_公司项目ing 🚀/pocketcorn v5/"
    elif (( $(echo "$ser > 0.6" | bc -l) )); then
        echo "/💻 技术开发/01_公司项目ing 🚀/Obsidion-zhilink-platform_v3/"
    elif (( $(echo "$tech > 0.5" | bc -l) )); then
        echo "/💻 技术开发/"
    elif (( $(echo "$learn > 0.4" | bc -l) )); then
        echo "/🟣 knowledge/"
    else
        echo "/"
    fi
}

# 2. 生成工作流编排计划
create_workflow_plan() {
    local analysis_file="/tmp/project_analysis.json"
    if [[ ! -f "$analysis_file" ]]; then
        echo "❌ Project analysis file not found!"
        return 1
    fi
    
    local priority_domain=$(jq -r '.priority_domain' "$analysis_file")
    local confidence=$(jq -r '.confidence_level' "$analysis_file")
    
    cat > /tmp/workflow_plan.json << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "primary_domain": "$priority_domain",
    "confidence_level": "$confidence",
    "execution_strategy": "$(get_execution_strategy $priority_domain)",
    "required_mcps": $(get_required_mcps $priority_domain),
    "suggested_agents": $(get_suggested_agents $priority_domain),
    "parallel_domains": $(get_parallel_domains $priority_domain)
}
EOF
}

# 获取执行策略
get_execution_strategy() {
    local domain=$1
    case "$domain" in
        "investment_analysis") echo "spelo_framework_analysis" ;;
        "enterprise_service") echo "six_role_collaboration" ;;
        "technical_development") echo "multi_agent_development" ;;
        "knowledge_research") echo "five_channel_concurrent_search" ;;
        *) echo "adaptive_general_purpose" ;;
    esac
}

# 获取必需MCP服务
get_required_mcps() {
    local domain=$1
    case "$domain" in
        "investment_analysis") 
            echo '["tavily-search", "pocketcorn-data", "python-sandbox", "workspace-filesystem"]' ;;
        "enterprise_service") 
            echo '["shadcn-ui", "zhilink-platform", "workspace-filesystem", "e2b-code-interpreter"]' ;;
        "technical_development") 
            echo '["serena-local", "e2b-code-interpreter", "workspace-filesystem", "shadcn-ui"]' ;;
        "knowledge_research") 
            echo '["tavily-search", "knowledge-base", "methodology-library", "workspace-filesystem"]' ;;
        *) 
            echo '["workspace-filesystem", "tavily-search"]' ;;
    esac
}

# 获取建议的智能代理
get_suggested_agents() {
    local domain=$1
    case "$domain" in
        "investment_analysis") 
            echo '["investment-analyst", "market-researcher", "due-diligence-specialist", "portfolio-manager"]' ;;
        "enterprise_service") 
            echo '["architect", "frontend-developer", "backend-architect", "ux-expert", "project-shipper", "qa"]' ;;
        "technical_development") 
            echo '["dev", "architect", "test-writer-fixer", "code-reviewer", "security-auditor"]' ;;
        "knowledge_research") 
            echo '["trend-researcher", "market-intelligence", "academic-researcher", "insight-synthesizer"]' ;;
        *) 
            echo '["general-purpose", "analyst"]' ;;
    esac
}

# 获取并行业务域
get_parallel_domains() {
    local domain=$1
    case "$domain" in
        "investment_analysis") 
            echo '["knowledge_research"]' ;;
        "enterprise_service") 
            echo '["technical_development", "knowledge_research"]' ;;
        "technical_development") 
            echo '["enterprise_service"]' ;;
        "knowledge_research") 
            echo '["investment_analysis", "enterprise_service"]' ;;
        *) 
            echo '[]' ;;
    esac
}

# 3. 生成交互策略
create_interaction_strategy() {
    local confidence=$(jq -r '.confidence_level' /tmp/workflow_plan.json 2>/dev/null || echo "medium")
    
    cat > /tmp/interaction_strategy.json << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "confidence_level": "$confidence",
    "interaction_mode": "$(get_interaction_mode $confidence)",
    "auto_execution": $(get_auto_execution_flag $confidence),
    "user_confirmation_required": $(get_confirmation_required $confidence),
    "explanation_depth": "$(get_explanation_depth $confidence)"
}
EOF
}

# 获取交互模式
get_interaction_mode() {
    local confidence=$1
    case "$confidence" in
        "high") echo "direct_execution" ;;
        "medium") echo "confirm_and_execute" ;;
        "low") echo "clarify_and_plan" ;;
        *) echo "adaptive" ;;
    esac
}

# 获取自动执行标志
get_auto_execution_flag() {
    local confidence=$1
    case "$confidence" in
        "high") echo "true" ;;
        *) echo "false" ;;
    esac
}

# 获取确认需求
get_confirmation_required() {
    local confidence=$1
    case "$confidence" in
        "high") echo "false" ;;
        *) echo "true" ;;
    esac
}

# 获取解释深度
get_explanation_depth() {
    local confidence=$1
    case "$confidence" in
        "high") echo "minimal" ;;
        "medium") echo "moderate" ;;
        "low") echo "detailed" ;;
        *) echo "adaptive" ;;
    esac
}

# 4. 学习记录和优化
record_learning_data() {
    local user_input="$1"
    local learning_file="/Users/dangsiyuan/Documents/obsidion/launch x/.claude/learning/user_interaction_patterns.json"
    
    # 确保学习目录存在
    mkdir -p "$(dirname "$learning_file")"
    
    # 如果学习文件不存在，创建初始结构
    if [[ ! -f "$learning_file" ]]; then
        echo '{"interactions": [], "patterns": {}, "optimization_history": []}' > "$learning_file"
    fi
    
    # 记录当前交互
    local current_interaction=$(cat << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "user_input": "$user_input",
    "analysis_result": $(cat /tmp/project_analysis.json 2>/dev/null || echo '{}'),
    "workflow_plan": $(cat /tmp/workflow_plan.json 2>/dev/null || echo '{}'),
    "interaction_strategy": $(cat /tmp/interaction_strategy.json 2>/dev/null || echo '{}')
}
EOF
)
    
    # 将交互记录添加到学习文件
    jq --argjson interaction "$current_interaction" '.interactions += [$interaction]' "$learning_file" > /tmp/updated_learning.json && mv /tmp/updated_learning.json "$learning_file"
}

# 5. 性能优化建议
generate_optimization_suggestions() {
    echo "- User input analyzed with 4-dimensional scoring"
    echo "- Workflow orchestration plan generated"
    echo "- Interaction strategy adapted to confidence level"
    echo "- Learning data accumulated for future optimization"
    
    # 提供具体的优化建议
    if [[ -f "/tmp/project_analysis.json" ]]; then
        local max_score=$(jq -r '[.analysis_scores[]] | max' /tmp/project_analysis.json)
        echo "- Primary domain confidence: $max_score"
        if (( $(echo "$max_score < 0.5" | bc -l) )); then
            echo "⚠️  Low confidence detected - consider clarification questions"
        fi
    fi
}

# 主执行流程
main() {
    local user_input="$1"
    
    echo "🚀 Ultimate Intent Processor activated..."
    echo "📝 Analyzing user input: "
    
    # Step 1: 项目分析
    create_project_analysis "$user_input"
    echo "✅ Project analysis generated: /tmp/project_analysis.json"
    
    # Step 2: 工作流编排
    create_workflow_plan
    echo "✅ Workflow plan generated: /tmp/workflow_plan.json"
    
    # Step 3: 交互策略
    create_interaction_strategy
    echo "✅ Interaction strategy generated: /tmp/interaction_strategy.json"
    
    # Step 4: 学习记录
    record_learning_data "$user_input"
    echo "✅ Learning data recorded: /Users/dangsiyuan/Documents/obsidion/launch x/.claude/learning/user_interaction_patterns.json"
    
    # Step 5: 优化建议
    generate_optimization_suggestions > /tmp/optimization_summary.txt 2>/dev/null
    if [[ -f "/tmp/optimization_summary.txt" && -s "/tmp/optimization_summary.txt" ]]; then
        echo "📊 Intent Processor Optimization Analysis:"
        cat /tmp/optimization_summary.txt
    fi
    
    echo "✅ Intent processing completed successfully!"
}

# 检查bc命令是否可用，如果没有则安装
if ! command -v bc &> /dev/null; then
    echo "Installing bc for calculations..."
    if command -v brew &> /dev/null; then
        brew install bc
    else
        echo "⚠️  Please install 'bc' manually for calculations"
    fi
fi

# 检查jq命令是否可用
if ! command -v jq &> /dev/null; then
    echo "Installing jq for JSON processing..."
    if command -v brew &> /dev/null; then
        brew install jq
    else
        echo "⚠️  Please install 'jq' manually for JSON processing"
    fi
fi

# 执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi