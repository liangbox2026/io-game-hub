#!/bin/bash
# =============================================================================
# 技能沉淀助手 - Skill Crystallization Assistant
# 功能：帮助将学到的知识快速沉淀为可复用技能
# 用法：./skill_crystallization.sh [技能名称] [来源]
# =============================================================================

set -e

# 配置
SKILLS_DIR="/root/.openclaw/workspace/skills"
DOCS_DIR="/root/.openclaw/workspace/backup/docs"
SCRIPTS_DIR="/root/.openclaw/workspace/backup/scripts"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 创建目录
mkdir -p "$SKILLS_DIR" "$DOCS_DIR" "$SCRIPTS_DIR"

# =============================================================================
# 帮助信息
# =============================================================================
show_help() {
    cat << EOF
🧠 技能沉淀助手

用法：$0 [命令] [选项]

命令:
  create     创建新技能模板
  list       列出已有技能
  review     回顾技能使用情况
  help       显示帮助

示例:
  $0 create "智能抓取" "夙愿学长文章"
  $0 list
  $0 review

EOF
}

# =============================================================================
# 创建技能模板
# =============================================================================
create_skill() {
    local skill_name="$1"
    local source="$2"
    
    if [ -z "$skill_name" ]; then
        echo -e "${RED}❌ 请提供技能名称${NC}"
        echo "用法：$0 create \"技能名称\" \"来源\""
        exit 1
    fi
    
    # 生成文件名
    local skill_file="$SKILLS_DIR/${skill_name// /_}.md"
    local script_file="$SCRIPTS_DIR/${skill_name// /_}.sh"
    local doc_file="$DOCS_DIR/${skill_name// /_}_guide.md"
    
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     技能沉淀 - $skill_name                ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # 创建技能文档模板
    cat > "$skill_file" << EOF
# 🧠 $skill_name

**来源**: $source  
**创建时间**: $DATE  
**当前等级**: L1 入门 ⚪

---

## 📋 技能描述

[一句话描述这个技能的作用]

---

## 🎯 适用场景

- [ ] 场景 1
- [ ] 场景 2
- [ ] 场景 3

---

## 🔧 使用方法

\`\`\`bash
# 基本用法
[命令示例]

# 高级用法
[命令示例]
\`\`\`

---

## 📊 决策逻辑

\`\`\`
条件 1 → 方法 A
条件 2 → 方法 B
\`\`\`

---

## 💡 最佳实践

1. [实践 1]
2. [实践 2]
3. [实践 3]

---

## ⚠️ 注意事项

- [注意 1]
- [注意 2]

---

## 📚 相关资源

- [相关文档 1]()
- [相关文档 2]()

---

## 📈 技能进化

| 日期 | 等级 | 改进内容 |
|------|------|----------|
| $DATE | L1 | 初始创建 | |

---

_最后更新：$DATE_
_EOF

    echo -e "${BLUE}📄 已创建技能文档：$skill_file${NC}"
    
    # 创建脚本模板
    cat > "$script_file" << 'EOF'
#!/bin/bash
# [技能名称]
# 功能：...
# 用法：...

set -e

# 配置
DATE=$(date +%Y-%m-%d)

# 主函数
main() {
    echo "技能脚本模板"
    echo "请根据实际需求实现功能"
}

main "$@"
EOF

    chmod +x "$script_file"
    echo -e "${BLUE}🔧 已创建脚本模板：$script_file${NC}"
    
    # 创建使用指南模板
    cat > "$doc_file" << EOF
# 📖 $skill_name 使用指南

_快速上手指南_

---

## 🎯 快速开始

\`\`\`bash
# 基本用法
[命令]

# 示例
[命令] --option value
\`\`\`

---

## 📋 使用场景

### 场景 1: [场景名称]

**问题**: [描述问题]

**解决方案**:
\`\`\`bash
[命令]
\`\`\`

---

## 🔧 配置选项

| 选项 | 说明 | 默认值 |
|------|------|--------|
| --option | 说明 | value |

---

## 📊 输出说明

[描述输出格式和内容]

---

## ⚠️ 注意事项

1. [注意 1]
2. [注意 2]

---

## 🔍 故障排查

### 问题 1: [问题描述]

**原因**: [原因]

**解决**: [解决方案]

---

## 📚 相关资源

- [技能文档]()
- [相关工具]()

---

_创建时间：$DATE_
_EOF

    echo -e "${BLUE}📖 已创建使用指南：$doc_file${NC}"
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ 技能沉淀完成!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "下一步:"
    echo "1. 编辑技能文档，补充具体内容"
    echo "2. 实现脚本功能"
    echo "3. 完善使用指南"
    echo "4. 测试并优化"
    echo ""
    echo "文件位置:"
    echo "  技能文档：$skill_file"
    echo "  脚本模板：$script_file"
    echo "  使用指南：$doc_file"
    echo ""
}

# =============================================================================
# 列出技能
# =============================================================================
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
    ls -1 "$SCRIPTS_DIR"/*.sh 2>/dev/null | wc -l | xargs echo "  共"
    
    echo ""
    echo "📖 使用指南:"
    ls -1 "$DOCS_DIR"/*_guide.md 2>/dev/null | wc -l | xargs echo "  共"
}

# =============================================================================
# 回顾技能
# =============================================================================
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
    echo "📈 技能使用情况:"
    echo "  [待实现：统计脚本执行次数]"
    
    echo ""
    echo "💡 改进建议:"
    echo "  1. 检查技能文档是否完整"
    echo "  2. 测试脚本是否正常工作"
    echo "  3. 更新使用指南"
}

# =============================================================================
# 主函数
# =============================================================================
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    case "$1" in
        create)
            shift
            create_skill "$@"
            ;;
        list)
            list_skills
            ;;
        review)
            review_skills
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}❌ 未知命令：$1${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"
