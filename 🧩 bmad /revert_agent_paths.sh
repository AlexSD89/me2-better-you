#!/bin/bash
# 回滚agent路径修改，恢复为原生BMAD格式（不需要路径）

BMAD_CORE_PATH="/Users/dangsiyuan/Documents/obsidion/launch x/bmad/bmad-core"

echo "🔄 回滚agent路径修改，恢复为原生BMAD格式..."

# 回滚workflow文件
echo "📋 回滚workflow文件..."
for file in "$BMAD_CORE_PATH/workflows/intelligent-"*.yaml; do
    if [ -f "$file" ]; then
        echo "处理: $(basename "$file")"
        
        # 移除完整路径，只保留agent名称
        sed -i.revert \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/project-intelligence|agent: project-intelligence|g" \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/workflow-orchestrator|agent: workflow-orchestrator|g" \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/interaction-orchestrator|agent: interaction-orchestrator|g" \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/🧠_brain-tier/analyst|agent: analyst|g" \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/🧠_brain-tier/pm|agent: pm|g" \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/🧠_brain-tier/architect|agent: architect|g" \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/🧠_brain-tier/po|agent: po|g" \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/🧠_brain-tier/sm|agent: sm|g" \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💻_development/fun-design-implementation/ux-expert|agent: ux-expert|g" \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💻_development/code-development/dev|agent: dev|g" \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💻_development/testing-validation/qa|agent: qa|g" \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/🧠_brain-tier/analyst,/Users/dangsiyuan/.claude/agents/🧠_brain-tier/pm|agent: analyst/pm|g" \
            -e "s|agent: /Users/dangsiyuan/.claude/agents/🧠_brain-tier/pm,/Users/dangsiyuan/.claude/agents/🧠_brain-tier/architect|agent: pm/architect|g" \
            "$file"
        
        echo "✅ 完成: $(basename "$file")"
    fi
done

# 回滚agent-teams文件
echo "👥 回滚agent-teams文件..."
for file in "$BMAD_CORE_PATH/agent-teams/intelligent-"*.yaml; do
    if [ -f "$file" ]; then
        echo "处理: $(basename "$file")"
        
        # 移除完整路径，只保留agent名称
        sed -i.revert \
            -e "s|- /Users/dangsiyuan/.claude/agents/🧠_brain-tier/analyst|- analyst|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🧠_brain-tier/pm|- pm|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🧠_brain-tier/architect|- architect|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🧠_brain-tier/po|- po|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🧠_brain-tier/sm|- sm|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🧠_brain-tier/iteration-decision-manager|- iteration-decision-manager|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💻_development/fun-design-implementation/ux-expert|- ux-expert|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💻_development/fun-design-implementation/ui-designer|- ui-designer|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💻_development/code-development/frontend-developer|- frontend-developer|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💻_development/code-development/backend-developer|- backend-developer|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💻_development/code-development/dev|- dev|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💻_development/testing-validation/qa|- qa|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💻_development/testing-validation/debugger|- debugger|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💻_development/testing-validation/performance-engineer|- performance-engineer|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/🔄_shared/quality-security/code-reviewer|- code-reviewer|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/🔄_shared/quality-security/security-auditor|- security-auditor|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/🔄_shared/ai-ml-intelligence/ai-engineer|- ai-engineer|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/🔄_shared/data-processing/data-analyst|- data-analyst|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💼_business/business-strategy/comprehensive-researcher|- comprehensive-researcher|g" \
            -e "s|- /Users/dangsiyuan/.claude/agents/🛠️_tool-tier/💼_business/user-operations/customer-support|- customer-support|g" \
            "$file"
        
        echo "✅ 完成: $(basename "$file")"
    fi
done

# 清理备份文件
echo "🧹 清理备份文件..."
find "$BMAD_CORE_PATH" -name "*.revert" -delete

echo "🎉 Agent路径回滚完成！"
echo "📍 现在使用原生BMAD格式：直接agent名称，无需路径"