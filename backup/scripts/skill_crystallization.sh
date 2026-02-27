#!/bin/bash
# =============================================================================
# 技能沉淀助手 - Skill Crystallization Assistant
# 功能：帮助将学到的知识快速沉淀为可复用技能
# =============================================================================

set -e

# 配置
SKILLS_DIR="/root/.openclaw/workspace/skills"
DOCS_DIR="/root/.openclaw/workspace/backup/docs"
SCRIPTS_DIR="/root/.openclaw/workspace/backup/scripts"
DATE=$(date +%Y-%m-%d)

# 颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# 创建目录
mkdir -p "$SKILLS_DIR" "$DOCS_DIR" "$SCRIPTS_DIR"

# 显示技能列表
list_skills() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     技能列表                              ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo "📁 技能文档:"
    ls -1 "$SKILLS_DIR"/*.md 2>/dev/null | while read file; do
        echo "  • $(basename $file .md)"
    done
    
    echo ""
    echo "🔧 技能脚本:"
    local script_count=$(ls -1 "$SCRIPTS_DIR"/*.sh 2>/dev/null | wc -l)
    echo "  共 $script_count 个"
    
    echo ""
    echo "📖 使用指南:"
    local doc_count=$(ls -1 "$DOCS_DIR"/*_guide.md 2>/dev/null | wc -l)
    echo "  共 $doc_count 个"
}

# 回顾技能
review_skills() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     技能回顾                              ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo "📊 本周创建的技能:"
    find "$SKILLS_DIR" -name "*.md" -mtime -7 2>/dev/null | while read file; do
        echo "  • $(basename $file .md)"
    done
    
    echo ""
    echo "💡 改进建议:"
    echo "  1. 检查技能文档是否完整"
    echo "  2. 测试脚本是否正常工作"
    echo "  3. 更新使用指南"
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        echo "🧠 技能沉淀助手"
        echo "用法：$0 [list|review|help]"
        echo ""
        echo "命令:"
        echo "  list    列出已有技能"
        echo "  review  回顾技能使用情况"
        echo "  help    显示帮助"
        exit 0
    fi
    
    case "$1" in
        list)
            list_skills
            ;;
        review)
            review_skills
            ;;
        help|--help|-h)
            main
            ;;
        *)
            echo "❌ 未知命令：$1"
            main
            exit 1
            ;;
    esac
}

main "$@"
