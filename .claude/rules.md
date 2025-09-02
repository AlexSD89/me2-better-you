# LaunchX AI协作规则体系 - Rules.md

> **核心定位**: 定义项目规则，指导自然语言规则转换为可执行Hook的标准规范  
> **更新时间**: 2025-08-15 21:50:00

---

## 🎯 规则体系核心理念

### 第一性原理
**LaunchX规则体系**基于第一性原理思维，从根本问题出发构建AI协作开发的规则框架：

```yaml
核心原理:
  用户中心: "一切规则围绕用户体验和开发效率设计"
  质量优先: "代码质量和系统稳定性是不可妥协的底线"
  智能自动: "能自动化的绝不手动，能预防的绝不修复"
  持续改进: "规则体系随着使用经验不断优化演进"
```

### 规则分层架构

```
┌─────────── 元规则层 (Meta Rules) ──────────────┐
│  定义规则如何制定、修改和执行的基本原则        │
├─────────── 系统规则层 (System Rules) ─────────┤
│  Hook系统、Agent协作、权限管理等技术规则      │
├─────────── 项目规则层 (Project Rules) ────────┤
│  代码规范、质量标准、流程控制等项目规则        │
├─────────── 业务规则层 (Business Rules) ──────┤
│  功能逻辑、数据验证、用户体验等业务规则        │
└─────────── 执行规则层 (Execution Rules) ─────┘
```

---

## 📜 元规则：规则制定的规则

### R001 - 规则创建原则

**规则描述**: 所有新规则必须满足SMART原则（Specific, Measurable, Achievable, Relevant, Time-bound）

**执行标准**:
- ✅ **明确性**: 规则描述清晰，不产生歧义
- ✅ **可测量**: 规则执行结果可以量化评估  
- ✅ **可实现**: 技术上可行，资源上可支持
- ✅ **相关性**: 与项目目标和用户价值对齐
- ✅ **时效性**: 明确规则生效和失效条件

**Hook实现**:
```bash
# 规则验证Hook
validate_rule_compliance() {
    local rule_description="$1"
    # SMART原则检查逻辑
    check_specificity "$rule_description"
    check_measurability "$rule_description" 
    check_achievability "$rule_description"
    check_relevance "$rule_description"
    check_time_bounds "$rule_description"
}
```

### R002 - 规则优先级管理

**规则描述**: 规则冲突时按照 元规则 > 安全规则 > 质量规则 > 效率规则 的优先级解决

**优先级矩阵**:
| 级别 | 类型 | 示例 | 不可妥协性 |
|------|------|------|------------|
| P1 | 安全规则 | 权限验证、敏感数据保护 | 绝对不可妥协 |
| P2 | 质量规则 | 代码规范、测试覆盖 | 高度不可妥协 |
| P3 | 效率规则 | 自动化流程、响应时间 | 可协商妥协 |
| P4 | 体验规则 | UI/UX改进、便利性 | 可灵活调整 |

### R003 - 规则演进机制

**规则描述**: 规则体系必须支持持续学习和改进，基于使用效果自动优化

**演进流程**:
```yaml
规则生命周期:
  1. 提案阶段: "自然语言描述新规则需求"
  2. 分析阶段: "AI分析规则可行性和影响"
  3. 实现阶段: "转换为Hook和Agent逻辑"
  4. 测试阶段: "验证规则执行效果"
  5. 部署阶段: "正式启用规则"
  6. 监控阶段: "持续监控规则效果"
  7. 优化阶段: "基于数据反馈优化规则"
```

---

## 🛡️ 系统规则：技术底层规范

### S001 - Hook执行规则

**规则描述**: Hook系统必须保证执行的可靠性、可追溯性和可恢复性

**执行要求**:
- 🔒 **幂等性**: 同样输入多次执行产生同样结果
- 📊 **可追溯**: 所有Hook执行都有完整日志记录
- ⏰ **超时控制**: 每个Hook都有明确的超时限制
- 🔄 **错误恢复**: 失败时能够自动恢复或回滚

**Hook模板**:
```bash
#!/bin/bash
# 标准Hook模板
set -euo pipefail

# 日志记录
log_hook_start() {
    echo "$(date -Iseconds): Hook started: $0 $*" >> .claude/logs/hooks.log
}

# 幂等性检查
check_idempotency() {
    local operation_id="$1"
    local lock_file=".claude/locks/${operation_id}.lock"
    [[ -f "$lock_file" ]] && return 1
    echo $$ > "$lock_file"
}

# 错误处理和清理
cleanup_on_error() {
    local operation_id="$1"
    rm -f ".claude/locks/${operation_id}.lock"
    log_hook_error "Hook failed: $0"
}

trap 'cleanup_on_error "$OPERATION_ID"' ERR
```

### S002 - Agent协作规则

**规则描述**: Agent之间的协作必须遵循明确的协议和边界

**协作协议**:
- 🎯 **职责明确**: 每个Agent有明确的专业领域
- 🤝 **接口标准**: Agent间通信使用标准化接口
- 📊 **状态共享**: 关键状态信息在Agent间透明共享
- 🔀 **冲突解决**: 有明确的冲突检测和解决机制

**协作示例**:
```bash
# Agent协作接口
agent_handoff() {
    local from_agent="$1"
    local to_agent="$2"
    local context_data="$3"
    
    # 记录交接
    log_agent_handoff "$from_agent" "$to_agent" "$context_data"
    
    # 验证目标Agent能力
    validate_agent_capability "$to_agent" "$context_data"
    
    # 执行交接
    execute_agent_transition "$from_agent" "$to_agent" "$context_data"
}
```

### S003 - 权限管理规则

**规则描述**: 所有系统操作都必须经过权限验证，遵循最小权限原则

**权限层级**:
```json
{
  "permission_levels": {
    "read_only": {
      "description": "只读访问，无修改权限",
      "tools": ["Read", "Grep", "LS", "WebFetch"]
    },
    "safe_write": {
      "description": "安全写入，限制敏感操作",
      "tools": ["Edit", "Write", "MultiEdit"],
      "restrictions": ["no_env_files", "no_system_configs"]
    },
    "developer": {
      "description": "开发者权限，可执行开发工具",
      "tools": ["Bash(git:*)", "Bash(npm:*)", "Bash(python:*)"]
    },
    "admin": {
      "description": "管理员权限，可执行系统级操作",
      "tools": ["Bash(sudo:*)", "Bash(docker:*)"],
      "requires": "explicit_approval"
    }
  }
}
```

### S004 - 数据保护规则

**规则描述**: 敏感数据必须得到特殊保护，禁止意外泄露

**保护措施**:
- 🚫 **环境变量保护**: 禁止读写.env文件
- 🔐 **密钥管理**: API密钥和认证信息使用专用管理
- 📝 **日志脱敏**: 日志记录自动脱敏敏感信息
- 🗃️ **临时文件清理**: 自动清理临时文件中的敏感数据

**实现示例**:
```bash
# 敏感数据检测
detect_sensitive_data() {
    local content="$1"
    
    # 检测模式
    local patterns=(
        "password\s*[:=]\s*['\"]?[^'\"\\s]+"
        "api[_-]?key\s*[:=]\s*['\"]?[^'\"\\s]+"
        "secret\s*[:=]\s*['\"]?[^'\"\\s]+"
        "token\s*[:=]\s*['\"]?[^'\"\\s]+"
    )
    
    for pattern in "${patterns[@]}"; do
        if echo "$content" | grep -iE "$pattern" >/dev/null; then
            return 0  # 发现敏感数据
        fi
    done
    
    return 1  # 未发现敏感数据
}
```

---

## 💎 项目规则：代码质量标准

### P001 - 代码格式规则

**规则描述**: 所有代码必须遵循统一的格式标准，确保可读性和一致性

**语言标准**:
- **Swift**: SwiftFormat + Apple Swift Style Guide
- **Python**: Black + PEP 8 + isort
- **JavaScript/TypeScript**: Prettier + ESLint
- **Rust**: rustfmt + Clippy
- **Go**: gofmt + go vet
- **Java**: Google Java Format

**Hook实现**:
```bash
# 自动格式化规则
auto_format_on_edit() {
    local file_path="$1"
    local file_ext="${file_path##*.}"
    
    case "$file_ext" in
        "swift") swiftformat "$file_path" ;;
        "py") black "$file_path" && isort "$file_path" ;;
        "js"|"jsx"|"ts"|"tsx") prettier --write "$file_path" ;;
        "rs") rustfmt "$file_path" ;;
        "go") gofmt -w "$file_path" ;;
        "java") google-java-format --replace "$file_path" ;;
    esac
}
```

### P002 - 测试覆盖率规则

**规则描述**: 所有新代码必须有对应的测试，关键模块测试覆盖率不低于90%

**覆盖率要求**:
- 🎯 **核心业务逻辑**: 90%+ 覆盖率
- 🔧 **工具函数**: 80%+ 覆盖率  
- 🎨 **UI组件**: 70%+ 覆盖率
- 📝 **配置代码**: 50%+ 覆盖率

**自动检查**:
```bash
# 测试覆盖率检查
check_test_coverage() {
    local file_path="$1"
    local coverage_threshold="$2"
    
    # 根据文件类型运行测试
    case "$file_path" in
        *.py) coverage run -m pytest && coverage report ;;
        *.js|*.ts) npm run test:coverage ;;
        *.swift) xcodebuild test -enableCodeCoverage YES ;;
        *.rs) cargo tarpaulin ;;
    esac
    
    # 检查覆盖率是否达标
    validate_coverage_threshold "$coverage_threshold"
}
```

### P003 - 性能标准规则

**规则描述**: 代码必须满足性能基准，避免性能回归

**性能指标**:
- ⚡ **页面加载时间**: < 200ms (首次渲染)
- 🔄 **API响应时间**: < 100ms (平均响应)
- 💾 **内存使用**: < 基线的110%
- 📊 **CPU占用**: < 80% (峰值)

**性能监控**:
```bash
# 性能基准检查
check_performance_benchmark() {
    local test_target="$1"
    
    # 运行性能测试
    run_performance_tests "$test_target"
    
    # 与基线对比
    compare_with_baseline "$test_target"
    
    # 检查是否有性能回归
    detect_performance_regression "$test_target"
}
```

### P004 - 安全编码规则

**规则描述**: 代码必须遵循安全编码最佳实践，防范常见漏洞

**安全检查项**:
- 🛡️ **输入验证**: 所有外部输入必须验证和净化
- 🔐 **权限检查**: 敏感操作必须验证用户权限
- 💉 **注入防护**: 防范SQL注入、XSS等攻击
- 🔒 **密码安全**: 密码存储使用强哈希算法

**安全扫描**:
```bash
# 安全代码扫描
security_code_scan() {
    local file_path="$1"
    
    # 静态安全分析
    run_security_linter "$file_path"
    
    # 依赖漏洞扫描
    scan_dependency_vulnerabilities
    
    # 敏感信息泄露检查
    check_sensitive_data_leak "$file_path"
}
```

---

## 🏢 业务规则：功能逻辑规范

### B001 - API设计规则

**规则描述**: API必须遵循RESTful设计原则，提供一致的用户体验

**设计标准**:
- 🌐 **RESTful规范**: 使用标准HTTP方法和状态码
- 📄 **JSON格式**: 统一使用JSON格式交换数据
- 🔢 **版本控制**: API支持版本控制，保持向后兼容
- 📚 **文档完整**: 自动生成和更新API文档

**API验证**:
```bash
# API规范检查
validate_api_design() {
    local api_file="$1"
    
    # 检查RESTful规范
    check_restful_compliance "$api_file"
    
    # 验证数据格式
    validate_json_schema "$api_file"
    
    # 检查版本兼容性
    check_version_compatibility "$api_file"
    
    # 更新API文档
    update_api_documentation "$api_file"
}
```

### B002 - 数据验证规则

**规则描述**: 所有数据输入输出都必须经过严格验证和类型检查

**验证层级**:
- 🔍 **前端验证**: 即时用户输入验证
- 🛡️ **API验证**: 服务端接口参数验证
- 🗄️ **数据库验证**: 数据持久化前的最终验证
- 📋 **业务验证**: 符合业务逻辑的规则验证

**验证实现**:
```bash
# 数据验证管道
data_validation_pipeline() {
    local data="$1"
    local schema="$2"
    
    # 类型验证
    validate_data_types "$data" "$schema"
    
    # 范围验证
    validate_data_ranges "$data" "$schema"
    
    # 业务规则验证
    validate_business_rules "$data" "$schema"
    
    # 安全验证
    validate_security_constraints "$data" "$schema"
}
```

### B003 - 用户体验规则

**规则描述**: 所有功能都必须提供优秀的用户体验，遵循可用性原则

**UX标准**:
- ♿ **可访问性**: 支持屏幕阅读器和键盘导航
- 📱 **响应式设计**: 适配不同设备和屏幕尺寸
- ⚡ **性能优化**: 快速响应和流畅交互
- 🎨 **视觉一致**: 遵循统一的设计系统

**UX检查**:
```bash
# 用户体验审计
audit_user_experience() {
    local component="$1"
    
    # 可访问性检查
    check_accessibility_compliance "$component"
    
    # 响应式测试
    test_responsive_design "$component"
    
    # 性能测试
    measure_interaction_performance "$component"
    
    # 设计一致性检查
    validate_design_system_compliance "$component"
}
```

---

## ⚡ 执行规则：自动化流程

### E001 - 自然语言规则转换

**规则描述**: 提供标准流程将自然语言描述的规则转换为可执行Hook

**转换流程**:
```yaml
自然语言→可执行Hook转换:
  步骤1_语义分析: "理解自然语言规则的意图和条件"
  步骤2_结构提取: "提取触发条件、执行逻辑、验证标准"
  步骤3_技术映射: "映射到具体的工具和命令"
  步骤4_Hook生成: "生成可执行的Hook脚本"
  步骤5_测试验证: "验证Hook的正确性和效果"
  步骤6_部署集成: "集成到Hook系统中"
```

**转换示例**:

**自然语言**: "当Swift文件被编辑时，自动运行SwiftFormat格式化，然后运行SwiftLint检查，如果有错误就通知用户"

**转换结果**:
```bash
#!/bin/bash
# Auto-generated Hook from natural language rule

# 触发条件: Edit(*.swift)
handle_swift_edit() {
    local file_path="$1"
    
    # 步骤1: SwiftFormat格式化
    if swiftformat "$file_path"; then
        log_success "SwiftFormat formatting completed"
    else
        log_error "SwiftFormat formatting failed"
        return 1
    fi
    
    # 步骤2: SwiftLint检查
    if swiftlint lint "$file_path"; then
        log_success "SwiftLint check passed"
    else
        log_warning "SwiftLint found issues"
        # 通知用户
        .claude/hooks/user-intervention-notifier.sh "SwiftLint发现代码质量问题"
    fi
}

main "$@"
```

### E002 - 规则冲突解决

**规则描述**: 当多个规则发生冲突时，按照预定义的优先级和策略自动解决

**冲突解决策略**:
- 🎯 **优先级排序**: 高优先级规则覆盖低优先级规则
- 🤝 **规则合并**: 兼容的规则尝试合并执行
- ⏰ **时序管理**: 按照依赖关系安排执行顺序
- 🚫 **规则禁用**: 冲突严重时暂时禁用低优先级规则

**冲突检测**:
```bash
# 规则冲突检测和解决
resolve_rule_conflicts() {
    local rules=("$@")
    
    # 检测冲突
    local conflicts=$(detect_rule_conflicts "${rules[@]}")
    
    if [[ -n "$conflicts" ]]; then
        # 按优先级排序
        local sorted_rules=$(sort_rules_by_priority "${rules[@]}")
        
        # 解决冲突
        resolve_conflicts "$sorted_rules" "$conflicts"
    fi
    
    # 返回最终规则集
    echo "$resolved_rules"
}
```

### E003 - 规则效果监控

**规则描述**: 持续监控规则执行效果，基于数据反馈优化规则

**监控指标**:
- 📊 **执行成功率**: 规则执行成功的比例
- ⏱️ **执行时间**: 规则执行的平均时间
- 🎯 **目标达成率**: 规则预期目标的实现程度
- 👥 **用户满意度**: 用户对规则效果的反馈

**监控实现**:
```bash
# 规则效果监控
monitor_rule_effectiveness() {
    local rule_id="$1"
    
    # 收集执行数据
    collect_execution_metrics "$rule_id"
    
    # 分析效果趋势
    analyze_effectiveness_trends "$rule_id"
    
    # 生成优化建议
    generate_optimization_suggestions "$rule_id"
    
    # 自动调优
    auto_tune_rule_parameters "$rule_id"
}
```

---

## 🎪 规则应用实例

### 实例1: 代码提交质量门禁

**自然语言规则**:
"每次代码提交前，必须通过格式检查、代码质量检查、单元测试和安全扫描，任何一项失败都不允许提交"

**转换为Hook配置**:
```json
{
  "PreToolUse": [
    {
      "matcher": "Bash(git commit:*)",
      "hooks": [
        {
          "type": "command",
          "command": ".claude/hooks/pre-commit-quality-gate.sh",
          "background": false,
          "fail_on_error": true
        }
      ]
    }
  ]
}
```

**Hook实现**:
```bash
#!/bin/bash
# .claude/hooks/pre-commit-quality-gate.sh

# 质量门禁检查
quality_gate_check() {
    local changed_files=$(git diff --cached --name-only)
    
    for file in $changed_files; do
        # 格式检查
        run_format_check "$file" || return 1
        
        # 代码质量检查
        run_quality_check "$file" || return 1
        
        # 单元测试
        run_related_tests "$file" || return 1
        
        # 安全扫描
        run_security_scan "$file" || return 1
    done
    
    log_success "所有质量门禁检查通过，允许提交"
}

main "$@"
```

### 实例2: 性能回归预警

**自然语言规则**:
"当检测到性能指标相比基线下降超过5%时，立即通知团队并暂停相关部署"

**转换为监控规则**:
```bash
#!/bin/bash
# .claude/hooks/performance-regression-monitor.sh

monitor_performance_regression() {
    local current_metrics="$1"
    local baseline_metrics="$2"
    
    # 计算性能变化
    local performance_change=$(calculate_performance_change "$current_metrics" "$baseline_metrics")
    
    if (( $(echo "$performance_change < -5.0" | bc -l) )); then
        # 触发警报
        .claude/hooks/user-intervention-notifier.sh "检测到性能回归超过5%！" "critical"
        
        # 暂停部署
        pause_deployment_pipeline
        
        # 通知团队
        notify_team "Performance regression detected: ${performance_change}%"
    fi
}
```

### 实例3: 依赖安全自动更新

**自然语言规则**:
"每周检查项目依赖的安全漏洞，发现高危漏洞时自动更新到安全版本，中低危漏洞创建更新提醒"

**转换为定时任务**:
```bash
#!/bin/bash
# .claude/hooks/dependency-security-updater.sh

weekly_dependency_security_check() {
    # 扫描依赖漏洞
    local vulnerabilities=$(scan_dependency_vulnerabilities)
    
    # 处理高危漏洞
    local critical_vulns=$(echo "$vulnerabilities" | jq '.[] | select(.severity == "critical")')
    for vuln in $critical_vulns; do
        auto_update_dependency "$vuln"
    done
    
    # 处理中低危漏洞
    local medium_low_vulns=$(echo "$vulnerabilities" | jq '.[] | select(.severity != "critical")')
    for vuln in $medium_low_vulns; do
        create_update_reminder "$vuln"
    done
}

# 设置为每周执行
schedule_weekly_execution "weekly_dependency_security_check"
```

---

## 🔄 规则演进和优化

### 规则版本管理

**版本控制策略**:
- 📝 **语义化版本**: 使用MAJOR.MINOR.PATCH版本号
- 📊 **变更记录**: 详细记录每次规则变更的原因和影响
- 🔄 **回滚机制**: 支持快速回滚到前一个稳定版本
- 🧪 **A/B测试**: 新规则先在小范围测试验证效果

### 规则学习机制

**自动学习流程**:
```yaml
学习循环:
  数据收集: "收集规则执行数据和用户反馈"
  模式识别: "识别规则执行中的模式和异常"
  效果分析: "分析规则对项目目标的实际影响"
  优化建议: "基于数据生成规则优化建议"
  实验验证: "在安全环境中验证优化效果"
  渐进部署: "逐步部署优化后的规则"
```

### 规则社区治理

**治理机制**:
- 🗳️ **民主决策**: 重要规则变更通过社区投票决定
- 👥 **专家评审**: 技术专家评审规则的技术可行性
- 📈 **数据驱动**: 基于客观数据而非主观意见制定规则
- 🔄 **持续改进**: 建立规则持续改进的反馈循环

---

## 🎯 规则应用指南

### 新项目规则配置

**快速开始清单**:
1. ✅ **复制标准配置**: 从模板项目复制基础规则配置
2. ✅ **自定义业务规则**: 根据项目特点添加特定规则
3. ✅ **验证规则有效性**: 运行规则测试套件
4. ✅ **培训团队成员**: 确保团队理解和遵循规则
5. ✅ **建立监控机制**: 设置规则执行效果监控

### 规则调试和故障排除

**常见问题解决**:
- 🐛 **Hook执行失败**: 检查权限配置和依赖安装
- ⚔️ **规则冲突**: 使用hook-coordination-manager解决
- ⏰ **执行超时**: 优化规则逻辑或增加超时时间
- 📊 **效果不佳**: 分析监控数据并调整规则参数

### 规则文档维护

**文档更新策略**:
- 🔄 **自动更新**: 规则变更时自动更新相关文档
- 📋 **示例维护**: 保持规则示例的准确性和时效性
- 🌐 **多语言支持**: 提供中英文双语规则文档
- 👥 **用户反馈**: 收集用户反馈改进文档质量

---

**🎯 目标**: 通过完整的规则体系，实现AI驱动的智能开发环境，让规则成为提升效率和质量的助力而非阻力。

**🔄 持续改进**: 规则体系本身也遵循持续改进原则，基于使用数据和用户反馈不断优化。

**👥 社区驱动**: 欢迎社区贡献新规则和改进建议，共同构建更好的AI协作开发生态。

---

*文档由LaunchX AI协作系统自动维护 | 最后更新: 2025-08-15 21:50:00*