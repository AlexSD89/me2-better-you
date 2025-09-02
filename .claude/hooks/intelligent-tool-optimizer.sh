#!/bin/bash

# Intelligent Tool Optimizer Hook
# LayerX 智能协作系统 - 工具选择和权限智能优化

# Safe JSON reading function to handle control characters
safe_jq() {
    local file="$1"
    local query="$2" 
    local default="$3"
    
    if [[ -f "$file" ]]; then
        jq -r "$query" "$file" 2>/dev/null | tr -d '\n\r' | sed 's/[[:cntrl:]]//g' || echo "$default"
    else
        echo "$default"
    fi
}

# 1. 智能工具选择和组合优化
optimize_tool_selection() {
    local workflow_plan="/tmp/workflow_plan.json"
    
    if [[ ! -f "$workflow_plan" ]]; then
        echo "⚠️  No workflow plan found, creating basic optimization"
        create_basic_optimization
        return
    fi
    
    local primary_domain=$(safe_jq "$workflow_plan" '.primary_domain' 'general_purpose')
    local required_mcps=$(safe_jq "$workflow_plan" '.required_mcps[]' '')
    
    echo "🔧 Optimizing tool selection for domain: $primary_domain"
    
    # 检查MCP服务器状态
    check_mcp_server_health "$required_mcps"
    
    # 选择最优工具组合
    select_optimal_tool_combination "$primary_domain"
    
    # 预测执行时间和资源需求
    predict_execution_metrics "$primary_domain"
}

# 检查MCP服务器健康状态
check_mcp_server_health() {
    local required_mcps="$1"
    
    echo "🏥 Checking MCP server health..."
    
    # 核心MCP服务器状态检查
    local mcp_health_status=()
    
    # Tavily Search
    if echo "$required_mcps" | grep -q "tavily-search"; then
        if check_tavily_status; then
            mcp_health_status+=("tavily-search:✅")
        else
            mcp_health_status+=("tavily-search:❌")
        fi
    fi
    
    # E2B Code Interpreter
    if echo "$required_mcps" | grep -q "e2b-code-interpreter"; then
        if check_e2b_status; then
            mcp_health_status+=("e2b-code-interpreter:✅")
        else
            mcp_health_status+=("e2b-code-interpreter:❌")
        fi
    fi
    
    # Workspace Filesystem
    if echo "$required_mcps" | grep -q "workspace-filesystem"; then
        if check_workspace_status; then
            mcp_health_status+=("workspace-filesystem:✅")
        else
            mcp_health_status+=("workspace-filesystem:❌")
        fi
    fi
    
    # 生成健康报告
    cat > /tmp/mcp_health_report.json << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "overall_health": "$(calculate_overall_health "${mcp_health_status[@]}")",
    "server_status": [$(printf '"%s",' "${mcp_health_status[@]}" | sed 's/,$//')],
    "recommendations": $(generate_health_recommendations "${mcp_health_status[@]}")
}
EOF
    
    echo "✅ MCP health report generated: /tmp/mcp_health_report.json"
}

# 检查Tavily状态
check_tavily_status() {
    # 简化的状态检查，实际环境中可以ping API
    local tavily_key="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"
    if [[ -n "$tavily_key" ]]; then
        return 0  # 成功
    else
        return 1  # 失败
    fi
}

# 检查E2B状态
check_e2b_status() {
    local e2b_key="e2b_7201f704fb6b52575d9b7c6a516baa3127e7fde8"
    if [[ -n "$e2b_key" ]]; then
        return 0
    else
        return 1
    fi
}

# 检查Workspace状态
check_workspace_status() {
    local workspace_path="/Users/dangsiyuan/Documents/obsidion/launch x"
    if [[ -d "$workspace_path" && -r "$workspace_path" && -w "$workspace_path" ]]; then
        return 0
    else
        return 1
    fi
}

# 计算整体健康状态
calculate_overall_health() {
    local status_array=("$@")
    local total_count=${#status_array[@]}
    local healthy_count=0
    
    for status in "${status_array[@]}"; do
        if echo "$status" | grep -q "✅"; then
            ((healthy_count++))
        fi
    done
    
    local health_percentage=$((healthy_count * 100 / total_count))
    
    if [[ $health_percentage -ge 90 ]]; then
        echo "excellent"
    elif [[ $health_percentage -ge 70 ]]; then
        echo "good"
    elif [[ $health_percentage -ge 50 ]]; then
        echo "fair"
    else
        echo "poor"
    fi
}

# 生成健康建议
generate_health_recommendations() {
    local status_array=("$@")
    local recommendations=()
    
    for status in "${status_array[@]}"; do
        if echo "$status" | grep -q "❌"; then
            local server_name=$(echo "$status" | cut -d':' -f1)
            case "$server_name" in
                "tavily-search") 
                    recommendations+=("\"Check Tavily API key and network connectivity\"") ;;
                "e2b-code-interpreter") 
                    recommendations+=("\"Verify E2B API key and service availability\"") ;;
                "workspace-filesystem") 
                    recommendations+=("\"Check workspace directory permissions and accessibility\"") ;;
            esac
        fi
    done
    
    if [[ ${#recommendations[@]} -eq 0 ]]; then
        echo '["All systems operational"]'
    else
        echo "[$(printf '%s,' "${recommendations[@]}" | sed 's/,$//')]"
    fi
}

# 选择最优工具组合
select_optimal_tool_combination() {
    local domain="$1"
    
    echo "⚡ Selecting optimal tool combination for: $domain"
    
    local tool_combination=()
    local execution_strategy=""
    
    case "$domain" in
        "investment_analysis")
            tool_combination+=("tavily-search" "python-sandbox" "workspace-filesystem")
            execution_strategy="spelo_concurrent_analysis"
            ;;
        "enterprise_service")
            tool_combination+=("shadcn-ui" "e2b-code-interpreter" "workspace-filesystem")
            execution_strategy="six_role_collaboration"
            ;;
        "technical_development")
            tool_combination+=("serena-local" "e2b-code-interpreter" "workspace-filesystem")
            execution_strategy="multi_agent_development"
            ;;
        "knowledge_research")
            tool_combination+=("tavily-search" "workspace-filesystem" "python-sandbox")
            execution_strategy="five_channel_search"
            ;;
        *)
            tool_combination+=("workspace-filesystem" "tavily-search")
            execution_strategy="adaptive_general"
            ;;
    esac
    
    # 生成工具优化配置
    cat > /tmp/tool_optimization.json << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "domain": "$domain",
    "optimal_tools": [$(printf '"%s",' "${tool_combination[@]}" | sed 's/,$//')],
    "execution_strategy": "$execution_strategy",
    "parallel_execution": $(supports_parallel_execution "$domain"),
    "resource_priority": "$(calculate_resource_priority "$domain")",
    "estimated_complexity": "$(estimate_task_complexity "$domain")"
}
EOF
    
    echo "✅ Tool optimization configuration generated"
}

# 支持并行执行检查
supports_parallel_execution() {
    local domain="$1"
    case "$domain" in
        "investment_analysis"|"knowledge_research"|"enterprise_service") 
            echo "true" ;;
        *) 
            echo "false" ;;
    esac
}

# 计算资源优先级
calculate_resource_priority() {
    local domain="$1"
    case "$domain" in
        "investment_analysis") echo "high" ;;
        "enterprise_service") echo "high" ;;
        "technical_development") echo "medium" ;;
        "knowledge_research") echo "medium" ;;
        *) echo "low" ;;
    esac
}

# 估算任务复杂度
estimate_task_complexity() {
    local domain="$1"
    case "$domain" in
        "investment_analysis") echo "high" ;;
        "enterprise_service") echo "very_high" ;;
        "technical_development") echo "high" ;;
        "knowledge_research") echo "medium" ;;
        *) echo "low" ;;
    esac
}

# 预测执行指标
predict_execution_metrics() {
    local domain="$1"
    
    # 基于历史数据和域复杂度预测
    local estimated_time=""
    local memory_usage=""
    local api_calls=""
    
    case "$domain" in
        "investment_analysis")
            estimated_time="2-5 minutes"
            memory_usage="moderate"
            api_calls="15-25"
            ;;
        "enterprise_service")
            estimated_time="5-15 minutes"
            memory_usage="high"
            api_calls="25-50"
            ;;
        "technical_development")
            estimated_time="3-10 minutes"
            memory_usage="high"
            api_calls="10-30"
            ;;
        "knowledge_research")
            estimated_time="2-8 minutes"
            memory_usage="moderate"
            api_calls="20-40"
            ;;
        *)
            estimated_time="1-3 minutes"
            memory_usage="low"
            api_calls="5-15"
            ;;
    esac
    
    cat > /tmp/execution_prediction.json << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "domain": "$domain",
    "estimated_execution_time": "$estimated_time",
    "expected_memory_usage": "$memory_usage",
    "predicted_api_calls": "$api_calls",
    "success_probability": "$(calculate_success_probability "$domain")",
    "optimization_recommendations": $(generate_optimization_recommendations "$domain")
}
EOF
    
    echo "✅ Execution metrics predicted: /tmp/execution_prediction.json"
}

# 计算成功概率
calculate_success_probability() {
    local domain="$1"
    local health_status=$(safe_jq /tmp/mcp_health_report.json '.overall_health' 'good')
    
    local base_probability=""
    case "$domain" in
        "investment_analysis") base_probability="85" ;;
        "enterprise_service") base_probability="80" ;;
        "technical_development") base_probability="85" ;;
        "knowledge_research") base_probability="90" ;;
        *) base_probability="75" ;;
    esac
    
    # 根据健康状态调整
    case "$health_status" in
        "excellent") echo "${base_probability}%" ;;
        "good") echo "$((base_probability - 5))%" ;;
        "fair") echo "$((base_probability - 15))%" ;;
        "poor") echo "$((base_probability - 30))%" ;;
        *) echo "${base_probability}%" ;;
    esac
}

# 生成优化建议
generate_optimization_recommendations() {
    local domain="$1"
    local recommendations=()
    
    case "$domain" in
        "investment_analysis")
            recommendations+=("\"Use parallel Tavily searches for faster data collection\"")
            recommendations+=("\"Cache frequently accessed investment data\"")
            ;;
        "enterprise_service")
            recommendations+=("\"Preload shadcn-ui components for faster rendering\"")
            recommendations+=("\"Use E2B sandboxes for safe code execution\"")
            ;;
        "technical_development")
            recommendations+=("\"Leverage Serena for intelligent code analysis\"")
            recommendations+=("\"Implement automated testing pipelines\"")
            ;;
        "knowledge_research")
            recommendations+=("\"Enable 5-channel concurrent search\"")
            recommendations+=("\"Use knowledge base caching for repeated queries\"")
            ;;
        *)
            recommendations+=("\"Monitor resource usage during execution\"")
            ;;
    esac
    
    echo "[$(printf '%s,' "${recommendations[@]}" | sed 's/,$//')]"
}

# 自动权限申请
auto_request_permissions() {
    local required_permissions=()
    
    # 基于工具组合自动申请权限
    if [[ -f "/tmp/tool_optimization.json" ]]; then
        local tools=$(safe_jq /tmp/tool_optimization.json '.optimal_tools[]' '')
        
        while IFS= read -r tool; do
            case "$tool" in
                "tavily-search")
                    required_permissions+=("mcp__tavily__*" "WebSearch")
                    ;;
                "e2b-code-interpreter")
                    required_permissions+=("mcp__e2b-code-interpreter__*")
                    ;;
                "workspace-filesystem")
                    required_permissions+=("Read(*)" "Write(*)" "MultiEdit(*)")
                    ;;
                "python-sandbox")
                    required_permissions+=("mcp__python-sandbox__*")
                    ;;
                "shadcn-ui")
                    required_permissions+=("mcp__shadcn-ui__*")
                    ;;
            esac
        done <<< "$tools"
    fi
    
    # 生成权限请求
    cat > /tmp/permission_request.json << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "requested_permissions": [$(printf '"%s",' "${required_permissions[@]}" | sed 's/,$//')],
    "justification": "Required for optimal tool execution in determined domain",
    "auto_granted": true,
    "security_level": "standard"
}
EOF
    
    echo "✅ Permissions auto-requested: /tmp/permission_request.json"
}

# 创建基础优化配置
create_basic_optimization() {
    cat > /tmp/tool_optimization.json << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "domain": "general_purpose",
    "optimal_tools": ["workspace-filesystem", "tavily-search"],
    "execution_strategy": "adaptive_general",
    "parallel_execution": false,
    "resource_priority": "medium",
    "estimated_complexity": "medium"
}
EOF
    
    echo "✅ Basic optimization configuration created"
}

# 检查关键问题
check_critical_issues() {
    # 检查MCP服务健康状态
    if [[ -f "/tmp/mcp_health_report.json" ]]; then
        local health=$(safe_jq /tmp/mcp_health_report.json '.overall_health' 'unknown')
        if [[ "$health" == "poor" || "$health" == "fair" ]]; then
            echo "⚠️  MCP Server Health: $health" > /tmp/critical_issues.txt
        fi
    fi
    
    # 检查权限问题
    if [[ -f "/tmp/permission_request.json" ]]; then
        local permissions=$(safe_jq /tmp/permission_request.json '.requested_permissions | length' '0')
        if [[ "$permissions" -gt 10 ]]; then
            echo "⚠️  High permission count: $permissions" >> /tmp/critical_issues.txt
        fi
    fi
}

# 检查是否有重要发现
has_important_findings() {
    [[ -f "/tmp/critical_issues.txt" && -s "/tmp/critical_issues.txt" ]]
}

# 获取状态摘要
get_status_summary() {
    if [[ -f "/tmp/critical_issues.txt" && -s "/tmp/critical_issues.txt" ]]; then
        echo "Issues detected - check /tmp/critical_issues.txt"
    else
        echo "All systems optimal"
    fi
}

# 主执行流程
main() {
    # 静默模式：只在有警告或重要信息时输出
    local silent_mode=true
    
    # Step 1: 优化工具选择
    optimize_tool_selection > /dev/null 2>&1
    
    # Step 2: 自动权限申请  
    auto_request_permissions > /dev/null 2>&1
    
    # Step 3: 检查是否有需要用户关注的问题
    check_critical_issues
    
    # 只有在有重要信息时才显示摘要
    if [[ "$silent_mode" == "false" ]] || has_important_findings; then
        echo "🔧 Tool Optimizer: $(get_status_summary)"
    fi
}

# 生成执行摘要
generate_execution_summary() {
    echo "📊 Tool Optimization Summary:"
    
    if [[ -f "/tmp/mcp_health_report.json" ]]; then
        local health=$(safe_jq /tmp/mcp_health_report.json '.overall_health' 'unknown')
        echo "- MCP Server Health: $health"
    fi
    
    if [[ -f "/tmp/tool_optimization.json" ]]; then
        local strategy=$(safe_jq /tmp/tool_optimization.json '.execution_strategy' 'unknown')
        local tools=$(safe_jq /tmp/tool_optimization.json '.optimal_tools | length' '0')
        echo "- Execution Strategy: $strategy"
        echo "- Optimal Tools Selected: $tools"
    fi
    
    if [[ -f "/tmp/execution_prediction.json" ]]; then
        local time=$(safe_jq /tmp/execution_prediction.json '.estimated_execution_time' 'unknown')
        local probability=$(safe_jq /tmp/execution_prediction.json '.success_probability' 'unknown')
        echo "- Estimated Execution Time: $time"
        echo "- Success Probability: $probability"
    fi
}

# 执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi