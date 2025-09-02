#!/bin/bash
# .claude/hooks/user-intervention-notifier.sh
# 需要用户介入时的停止提示Hook - 声音和视觉通知系统

set -euo pipefail

# 配置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
BLINK='\033[5m'
NC='\033[0m'

# 日志函数
log_alert() {
    echo -e "${RED}${BOLD}🚨 [USER-INTERVENTION]${NC} $1"
}

log_info() {
    echo -e "${BLUE}ℹ️  [INTERVENTION-INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ [INTERVENTION-SUCCESS]${NC} $1"
}

log_action() {
    echo -e "${CYAN}🎯 [REQUIRED-ACTION]${NC} $1"
}

# 检测介入需求的类型
detect_intervention_type() {
    local context="${1:-unknown}"
    local intervention_type="general"
    
    # 基于上下文检测介入类型
    if echo "$context" | grep -qi "error\|failed\|exception"; then
        intervention_type="error"
    elif echo "$context" | grep -qi "conflict\|merge\|resolution"; then
        intervention_type="conflict"
    elif echo "$context" | grep -qi "decision\|choice\|select"; then
        intervention_type="decision"
    elif echo "$context" | grep -qi "security\|permission\|auth"; then
        intervention_type="security"
    elif echo "$context" | grep -qi "deploy\|production\|release"; then
        intervention_type="deployment"
    elif echo "$context" | grep -qi "review\|approval\|check"; then
        intervention_type="review"
    fi
    
    echo "$intervention_type"
}

# 多层级声音通知系统
play_intervention_sounds() {
    local intervention_type="$1"
    local urgency_level="${2:-medium}"
    
    if [[ "${SOUND_NOTIFICATIONS:-true}" != "true" ]]; then
        return 0
    fi
    
    case "$intervention_type" in
        "error")
            # 错误类型 - 严重警告音
            for i in {1..3}; do
                afplay /System/Library/Sounds/Sosumi.aiff &
                sleep 0.8
            done
            ;;
        "security")
            # 安全类型 - 急促警告
            for i in {1..5}; do
                afplay /System/Library/Sounds/Funk.aiff &
                sleep 0.3
            done
            ;;
        "conflict")
            # 冲突类型 - 双音提示
            afplay /System/Library/Sounds/Glass.aiff &
            sleep 0.5
            afplay /System/Library/Sounds/Tink.aiff &
            sleep 0.5
            afplay /System/Library/Sounds/Glass.aiff &
            ;;
        "decision")
            # 决策类型 - 和谐提示音
            afplay /System/Library/Sounds/Ping.aiff &
            sleep 1
            afplay /System/Library/Sounds/Pop.aiff &
            ;;
        "deployment")
            # 部署类型 - 庄重提示
            afplay /System/Library/Sounds/Hero.aiff &
            ;;
        "review")
            # 审查类型 - 温和提示
            afplay /System/Library/Sounds/Purr.aiff &
            ;;
        *)
            # 通用类型 - 标准提示
            afplay /System/Library/Sounds/Glass.aiff &
            ;;
    esac
}

# 视觉通知横幅
display_intervention_banner() {
    local intervention_type="$1"
    local message="$2"
    local urgency_level="${3:-medium}"
    
    clear
    
    # 根据紧急程度选择颜色和样式
    local banner_color="$YELLOW"
    local icon="⚠️"
    
    case "$urgency_level" in
        "high"|"critical")
            banner_color="$RED"
            icon="🚨"
            ;;
        "medium")
            banner_color="$YELLOW"
            icon="⚠️"
            ;;
        "low")
            banner_color="$BLUE"
            icon="ℹ️"
            ;;
    esac
    
    # 打印横幅
    echo -e "${banner_color}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    🛑 需要用户介入 🛑                          ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║ $icon LaunchX AI协作系统暂停，等待您的决策...                    ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║ 介入类型: $(printf "%-20s" "$intervention_type") 紧急程度: $urgency_level          ║"
    echo "║ 时间: $(date '+%Y-%m-%d %H:%M:%S')                             ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # 显示具体消息
    echo -e "${CYAN}${BOLD}📋 详细信息:${NC}"
    echo -e "${WHITE}$message${NC}"
    echo ""
}

# 生成介入请求详情
generate_intervention_details() {
    local intervention_type="$1"
    local context="$2"
    
    case "$intervention_type" in
        "error")
            cat << EOF
🔴 错误类型介入请求

**发生问题**: 系统遇到无法自动解决的错误
**需要操作**: 
  1. 检查错误日志和详细信息
  2. 分析根本原因
  3. 提供手动修复方案
  4. 确认是否继续自动化流程

**建议行动**:
  - 查看 .claude/logs/ 目录下的错误日志
  - 检查最近的代码变更
  - 验证开发环境配置
  - 考虑回滚到稳定版本
EOF
            ;;
        "security")
            cat << EOF
🔒 安全类型介入请求

**安全关注**: 检测到可能的安全风险或权限问题
**需要操作**:
  1. 验证权限请求的合理性
  2. 确认敏感操作的安全性
  3. 检查访问控制配置
  4. 审批安全相关变更

**建议行动**:
  - 审查权限申请详情
  - 验证用户身份和授权
  - 检查安全日志
  - 咨询安全团队意见
EOF
            ;;
        "conflict")
            cat << EOF
⚔️ 冲突类型介入请求

**冲突情况**: 发现代码冲突或配置冲突需要解决
**需要操作**:
  1. 分析冲突的具体内容
  2. 确定正确的解决方案
  3. 手动解决冲突
  4. 验证解决结果

**建议行动**:
  - 使用 git status 查看冲突文件
  - 比较不同版本的差异
  - 与相关开发者沟通
  - 测试合并结果
EOF
            ;;
        "decision")
            cat << EOF
🤔 决策类型介入请求

**决策需求**: 需要您做出重要的项目决策
**需要操作**:
  1. 评估可用选项
  2. 考虑影响和风险
  3. 做出明智决策
  4. 指导后续行动

**建议行动**:
  - 收集相关信息和数据
  - 咨询团队成员意见
  - 评估长期影响
  - 制定决策标准
EOF
            ;;
        "deployment")
            cat << EOF
🚀 部署类型介入请求

**部署关注**: 生产部署需要人工确认
**需要操作**:
  1. 验证部署前检查清单
  2. 确认变更影响范围
  3. 批准生产部署
  4. 监控部署结果

**建议行动**:
  - 检查所有测试是否通过
  - 验证数据库迁移脚本
  - 确认回滚方案
  - 通知相关团队
EOF
            ;;
        "review")
            cat << EOF
👀 审查类型介入请求

**审查需求**: 代码或配置需要人工审查
**需要操作**:
  1. 仔细审查变更内容
  2. 检查代码质量和规范
  3. 验证业务逻辑正确性
  4. 提供审查反馈

**建议行动**:
  - 逐行检查代码变更
  - 运行相关测试
  - 验证文档更新
  - 提供改进建议
EOF
            ;;
        *)
            cat << EOF
📋 通用介入请求

**一般情况**: 系统需要您的介入和指导
**需要操作**:
  1. 了解当前情况
  2. 分析可用选项
  3. 提供指导方案
  4. 确认后续步骤

**建议行动**:
  - 查看系统状态和日志
  - 检查相关文档
  - 考虑最佳实践
  - 制定行动计划
EOF
            ;;
    esac
}

# 等待用户响应
wait_for_user_response() {
    local intervention_type="$1"
    local timeout_seconds="${2:-300}"  # 5分钟默认超时
    
    echo -e "${YELLOW}${BOLD}⏰ 等待您的响应...${NC}"
    echo -e "${CYAN}可用操作:${NC}"
    echo "  [c] 继续 (Continue)"
    echo "  [a] 中止 (Abort)" 
    echo "  [r] 重试 (Retry)"
    echo "  [i] 更多信息 (More Info)"
    echo "  [h] 帮助 (Help)"
    echo ""
    
    local response=""
    local elapsed=0
    
    while [[ $elapsed -lt $timeout_seconds ]]; do
        echo -ne "${PURPLE}请选择操作 [c/a/r/i/h]: ${NC}"
        
        # 等待1秒或用户输入
        if read -t 1 response 2>/dev/null; then
            break
        fi
        
        ((elapsed++))
        
        # 每30秒提醒一次
        if [[ $((elapsed % 30)) -eq 0 ]]; then
            echo -e "\n${YELLOW}⏰ 已等待 ${elapsed}s/${timeout_seconds}s${NC}"
            play_intervention_sounds "$intervention_type" "low"
        fi
    done
    
    # 处理超时
    if [[ $elapsed -ge $timeout_seconds ]]; then
        echo -e "\n${RED}⏰ 响应超时，默认中止操作${NC}"
        response="a"
    fi
    
    echo ""
    
    case "${response,,}" in
        "c"|"continue")
            log_success "用户选择继续操作"
            return 0
            ;;
        "a"|"abort")
            log_alert "用户选择中止操作"
            return 1
            ;;
        "r"|"retry")
            log_info "用户选择重试操作"
            return 2
            ;;
        "i"|"info")
            log_info "用户请求更多信息"
            return 3
            ;;
        "h"|"help")
            log_info "用户请求帮助"
            return 4
            ;;
        *)
            log_alert "无效选择，默认中止操作"
            return 1
            ;;
    esac
}

# 显示帮助信息
show_help() {
    echo -e "${BLUE}${BOLD}📚 LaunchX用户介入帮助${NC}"
    echo ""
    echo -e "${CYAN}命令说明:${NC}"
    echo "  c/continue  - 继续当前操作，跳过当前问题"
    echo "  a/abort     - 中止当前操作，停止自动化流程"
    echo "  r/retry     - 重试当前操作，再次尝试解决问题"
    echo "  i/info      - 显示更多详细信息和建议"
    echo "  h/help      - 显示此帮助信息"
    echo ""
    echo -e "${CYAN}常见介入场景:${NC}"
    echo "  🔴 错误     - 系统遇到无法自动解决的错误"
    echo "  🔒 安全     - 涉及权限或安全的敏感操作"
    echo "  ⚔️ 冲突     - 代码或配置冲突需要手动解决"
    echo "  🤔 决策     - 需要业务决策或技术选择"
    echo "  🚀 部署     - 生产环境部署需要确认"
    echo "  👀 审查     - 代码审查或质量检查"
    echo ""
    echo -e "${CYAN}相关资源:${NC}"
    echo "  📂 日志目录: .claude/logs/"
    echo "  📊 报告目录: .claude/reports/"
    echo "  ⚙️ 配置文件: .claude/settings.local.json"
    echo "  📋 任务列表: .claude/tasks/"
    echo ""
}

# 记录介入日志
log_intervention() {
    local intervention_type="$1"
    local context="$2"
    local user_response="$3"
    local duration="$4"
    
    # 创建介入日志目录
    mkdir -p .claude/logs/interventions
    
    local log_file=".claude/logs/interventions/$(date +%Y-%m-%d).log"
    
    cat >> "$log_file" << EOF
$(date -Iseconds) | $intervention_type | $user_response | ${duration}s | $context
EOF
    
    # 创建详细JSON日志
    local json_log=".claude/logs/interventions/intervention-$(date +%s).json"
    
    cat > "$json_log" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "intervention_type": "$intervention_type",
  "context": "$context",
  "user_response": "$user_response",
  "duration_seconds": $duration,
  "session_id": "${CLAUDE_SESSION_ID:-unknown}",
  "project_path": "$(pwd)",
  "git_branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
  "git_commit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')"
}
EOF
    
    log_info "介入记录已保存: $json_log"
}

# 生成介入统计报告
generate_intervention_stats() {
    local log_dir=".claude/logs/interventions"
    
    if [[ ! -d "$log_dir" ]]; then
        return 0
    fi
    
    local today=$(date +%Y-%m-%d)
    local total_today=0
    local total_week=0
    
    # 统计今日介入次数
    if [[ -f "$log_dir/$today.log" ]]; then
        total_today=$(wc -l < "$log_dir/$today.log")
    fi
    
    # 统计本周介入次数
    local week_start=$(date -v-$(($(date +%u)-1))d +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)
    for file in "$log_dir"/*.log; do
        if [[ -f "$file" ]]; then
            local file_date=$(basename "$file" .log)
            # 简化日期比较
            if [[ "$file_date" > "$week_start" ]] || [[ "$file_date" == "$week_start" ]]; then
                total_week=$((total_week + $(wc -l < "$file" 2>/dev/null || echo 0)))
            fi
        fi
    done
    
    echo -e "${BLUE}📊 介入统计:${NC}"
    echo "  今日介入: $total_today 次"
    echo "  本周介入: $total_week 次"
    echo ""
}

# 主执行函数
main() {
    local context="${1:-LaunchX系统需要用户介入}"
    local urgency_level="${2:-medium}"
    
    # 检测介入类型
    local intervention_type=$(detect_intervention_type "$context")
    
    # 记录开始时间
    local start_time=$(date +%s)
    
    # 播放声音通知
    play_intervention_sounds "$intervention_type" "$urgency_level"
    
    # 显示视觉通知
    display_intervention_banner "$intervention_type" "$context" "$urgency_level"
    
    # 显示统计信息
    generate_intervention_stats
    
    # 等待用户响应
    local response_code=0
    local max_retries=3
    local retry_count=0
    
    while [[ $retry_count -lt $max_retries ]]; do
        wait_for_user_response "$intervention_type" 300
        response_code=$?
        
        case $response_code in
            0)  # 继续
                log_success "用户确认继续操作"
                break
                ;;
            1)  # 中止
                log_alert "用户选择中止，系统将停止当前操作"
                break
                ;;
            2)  # 重试
                log_info "用户选择重试，重新发起介入请求"
                ((retry_count++))
                continue
                ;;
            3)  # 更多信息
                echo ""
                generate_intervention_details "$intervention_type" "$context"
                echo ""
                continue
                ;;
            4)  # 帮助
                echo ""
                show_help
                echo ""
                continue
                ;;
            *)
                log_alert "未知响应，中止操作"
                response_code=1
                break
                ;;
        esac
    done
    
    # 如果重试次数用尽
    if [[ $retry_count -ge $max_retries ]]; then
        log_alert "重试次数超限，自动中止操作"
        response_code=1
    fi
    
    # 计算持续时间
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # 记录介入日志
    local response_text=""
    case $response_code in
        0) response_text="continue" ;;
        1) response_text="abort" ;;
        2) response_text="retry" ;;
        *) response_text="unknown" ;;
    esac
    
    log_intervention "$intervention_type" "$context" "$response_text" "$duration"
    
    # 最终通知
    if [[ $response_code -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✅ 操作已确认，系统将继续执行${NC}"
        afplay /System/Library/Sounds/Glass.aiff &
    else
        echo -e "${RED}${BOLD}🛑 操作已中止，系统将停止执行${NC}"
        afplay /System/Library/Sounds/Basso.aiff &
    fi
    
    echo ""
    echo -e "${CYAN}感谢您的配合，LaunchX将根据您的决策继续工作！${NC}"
    
    # 等待3秒让用户看到最终消息
    sleep 3
    
    exit $response_code
}

# 错误处理
trap 'echo -e "\n${RED}介入处理被中断${NC}"; exit 1' INT TERM

# 执行主函数
main "$@"