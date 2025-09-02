#!/bin/bash

# 临时文件自动清理Hook
# 在工作完成后自动清理临时文件，保持项目目录整洁

# 函数: 清理指定目录的临时文件
cleanup_temp_files() {
    local project_dir="$1"
    
    if [ -d "$project_dir" ] && [ -f "$project_dir/temp_file_manager.py" ]; then
        echo "🧹 自动清理临时文件: $project_dir"
        
        cd "$project_dir" || return 1
        
        # 执行自动清理
        python temp_file_manager.py auto 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "✅ 临时文件清理完成"
        else
            echo "⚠️ 临时文件清理失败，请手动执行"
        fi
    fi
}

# 主要项目目录列表
PROJECT_DIRS=(
    "/Users/dangsiyuan/Documents/obsidion/launch x/💻 技术开发/04_成熟项目 ✅/pocketcorn_v4.1_bmad"
    "/Users/dangsiyuan/Documents/obsidion/launch x/💻 技术开发/01_公司项目ing 🚀/pocketcorn v5"
    "/Users/dangsiyuan/Documents/obsidion/launch x/💻 技术开发/01_公司项目ing 🚀/Obsidion-zhilink-platform_v3"
)

echo "🔄 开始执行临时文件清理Hook..."

# 遍历所有项目目录
for dir in "${PROJECT_DIRS[@]}"; do
    cleanup_temp_files "$dir"
done

echo "🎉 临时文件清理Hook执行完成"

# 清理超过7天的旧会话
echo "🗑️ 清理过期会话目录..."
for dir in "${PROJECT_DIRS[@]}"; do
    if [ -d "$dir" ] && [ -f "$dir/temp_file_manager.py" ]; then
        cd "$dir" || continue
        python temp_file_manager.py clean-old 7 2>/dev/null
    fi
done

exit 0