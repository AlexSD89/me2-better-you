#!/bin/bash
# .claude/hooks/result-validator.sh  
# 结果验证Hook - PostToolUse阶段

# 日志配置
LOG_DIR=".claude/logs"
VALIDATOR_LOG="$LOG_DIR/result-validator.log"
PERFORMANCE_LOG="$LOG_DIR/performance-metrics.log"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 日志函数
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$VALIDATOR_LOG"
}

# 声音反馈
play_validation_sound() {
    local result="$1"
    if [ "${SOUND_NOTIFICATIONS:-true}" = "true" ]; then
        case "$result" in
            "success") echo -e "\a" ;;
            "warning") echo -e "\a\a" ;;
            "error") echo -e "\a\a\a" ;;
        esac
    fi
}

# 结果质量评估
assess_result_quality() {
    local tool_name="$1"
    local execution_time="$2"
    local result_size="$3"
    
    local quality_score=5.0  # 默认分数
    
    # 基于执行时间评估
    if [ "$execution_time" -lt 5 ]; then
        quality_score=$(echo "$quality_score + 1.0" | bc -l)
    elif [ "$execution_time" -gt 30 ]; then
        quality_score=$(echo "$quality_score - 1.0" | bc -l)
    fi
    
    # 基于结果大小评估
    if [ "$result_size" -gt 1000 ] && [ "$result_size" -lt 50000 ]; then
        quality_score=$(echo "$quality_score + 0.5" | bc -l)
    elif [ "$result_size" -lt 100 ]; then
        quality_score=$(echo "$quality_score - 0.5" | bc -l)
    fi
    
    # 基于工具类型调整
    case "$tool_name" in
        "Task") 
            # Task工具通常需要更长时间
            if [ "$execution_time" -lt 60 ]; then
                quality_score=$(echo "$quality_score + 0.5" | bc -l)
            fi
            ;;
        "WebSearch"|"WebFetch")
            # 搜索工具关注响应速度
            if [ "$execution_time" -lt 10 ]; then
                quality_score=$(echo "$quality_score + 1.0" | bc -l)
            fi
            ;;
    esac
    
    echo "$quality_score"
}

# 性能指标收集
collect_performance_metrics() {
    local tool_name="$1"
    local start_time="$2"
    local end_time="$3"
    local complexity="$4"
    
    local execution_time=$((end_time - start_time))
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 记录性能指标
    cat >> "$PERFORMANCE_LOG" << EOF
{
  "timestamp": "$timestamp",
  "tool_name": "$tool_name",
  "complexity": "$complexity",
  "execution_time": $execution_time,
  "start_time": $start_time,
  "end_time": $end_time
}
EOF
    
    echo "$execution_time"
}

# 错误模式检测
detect_error_patterns() {
    local tool_output="$1"
    local error_patterns=(
        "Error:"
        "Exception:"
        "Failed:"
        "timeout"
        "connection refused"
        "permission denied"
        "not found"
    )
    
    local error_count=0
    for pattern in "${error_patterns[@]}"; do
        if echo "$tool_output" | grep -qi "$pattern"; then
            error_count=$((error_count + 1))
            log_message "WARNING" "检测到错误模式: $pattern"
        fi
    done
    
    echo "$error_count"
}

# 成功模式检测
detect_success_patterns() {
    local tool_output="$1"
    local success_patterns=(
        "✅"
        "completed successfully"
        "finished"
        "done"
        "success"
    )
    
    local success_count=0
    for pattern in "${success_patterns[@]}"; do
        if echo "$tool_output" | grep -qi "$pattern"; then
            success_count=$((success_count + 1))
        fi
    done
    
    echo "$success_count"
}

# 智能反馈生成
generate_feedback() {
    local tool_name="$1"
    local execution_time="$2"
    local quality_score="$3"
    local error_count="$4"
    local success_count="$5"
    
    echo "📊 执行反馈:"
    echo "   工具: $tool_name"
    echo "   耗时: ${execution_time}秒"
    echo "   质量评分: $quality_score/10"
    
    if [ "$error_count" -gt 0 ]; then
        echo "   ⚠️ 检测到 $error_count 个潜在问题"
        play_validation_sound "warning"
    elif [ "$success_count" -gt 0 ]; then
        echo "   ✅ 执行成功 ($success_count 个成功指标)"
        play_validation_sound "success"
    fi
    
    # 性能建议
    if [ "$execution_time" -gt 30 ]; then
        echo "   💡 建议: 考虑优化执行策略或增加缓存"
    fi
    
    if (( $(echo "$quality_score < 4.0" | bc -l) )); then
        echo "   💡 建议: 结果质量较低，建议重新执行或调整参数"
    fi
}

# 学习和优化建议
generate_optimization_suggestions() {
    local tool_name="$1"
    local complexity="$2"
    local execution_time="$3"
    
    # 基于历史数据生成优化建议
    local avg_time_file=".claude/cache/avg_execution_times.json"
    
    if [ -f "$avg_time_file" ]; then
        local avg_time=$(jq -r ".\"$tool_name\" // 0" "$avg_time_file")
        
        if [ "$avg_time" != "0" ] && [ "$execution_time" -gt $((avg_time * 2)) ]; then
            echo "📈 优化建议: $tool_name 执行时间异常 (当前: ${execution_time}s, 平均: ${avg_time}s)"
            echo "   建议检查网络状况或MCP服务健康状态"
        fi
    fi
    
    # 更新平均执行时间
    if [ ! -f "$avg_time_file" ]; then
        echo '{}' > "$avg_time_file"
    fi
    
    local new_avg=$(jq ".\"$tool_name\" = ((.\"$tool_name\" // 0) * 0.8 + $execution_time * 0.2)" "$avg_time_file")
    echo "$new_avg" > "$avg_time_file"
}

# 上下文保存
save_execution_context() {
    local tool_name="$1"
    local quality_score="$2"
    local execution_time="$3"
    local complexity="$4"
    
    local context_file=".claude/cache/execution_context.json"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 保存执行上下文用于后续分析
    local context_entry=$(cat << EOF
{
  "timestamp": "$timestamp",
  "tool_name": "$tool_name",
  "quality_score": $quality_score,
  "execution_time": $execution_time,
  "complexity": "$complexity",
  "session_id": "${CLAUDE_SESSION_ID:-unknown}"
}
EOF
)
    
    if [ ! -f "$context_file" ]; then
        echo '[]' > "$context_file"
    fi
    
    jq ". += [$context_entry]" "$context_file" > "${context_file}.tmp" && mv "${context_file}.tmp" "$context_file"
}

# 主验证流程
main() {
    local tool_name="${TOOL_NAME:-unknown}"
    local start_time="${EXECUTION_START_TIME:-$(date +%s)}"
    local end_time="$(date +%s)"
    local complexity="${EXECUTION_COMPLEXITY:-B级}"
    local tool_output="${TOOL_OUTPUT:-}"
    
    log_message "INFO" "开始结果验证: $tool_name"
    
    # 性能指标收集
    local execution_time=$(collect_performance_metrics "$tool_name" "$start_time" "$end_time" "$complexity")
    
    # 结果大小估算
    local result_size=$(echo "$tool_output" | wc -c)
    
    # 质量评估
    local quality_score=$(assess_result_quality "$tool_name" "$execution_time" "$result_size")
    
    # 模式检测
    local error_count=$(detect_error_patterns "$tool_output")
    local success_count=$(detect_success_patterns "$tool_output")
    
    # 生成反馈
    if [ "${PERFORMANCE_MONITORING:-true}" = "true" ]; then
        generate_feedback "$tool_name" "$execution_time" "$quality_score" "$error_count" "$success_count"
    fi
    
    # 优化建议
    generate_optimization_suggestions "$tool_name" "$complexity" "$execution_time"
    
    # 保存执行上下文
    save_execution_context "$tool_name" "$quality_score" "$execution_time" "$complexity"
    
    log_message "INFO" "结果验证完成: $tool_name (评分: $quality_score)"
}

# 错误处理
trap 'log_message "ERROR" "结果验证过程出错"; play_validation_sound "error"' ERR

# 后台执行主函数
main "$@" &