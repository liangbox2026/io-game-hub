#!/bin/bash
# =============================================================================
# GitHub Trending 抓取脚本
# 功能：每日抓取 GitHub Trending 项目，生成结构化报告
# 用法：./github_trends_fetcher.sh [--verbose] [--output=md|json]
# =============================================================================

set -e

# 配置
OUTPUT_DIR="/root/.openclaw/workspace/backup/logs"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
OUTPUT_FILE="$OUTPUT_DIR/github_trends_$DATE.md"

# 解析参数
VERBOSE=false
OUTPUT_FORMAT="md"
for arg in "$@"; do
    case $arg in
        --verbose) VERBOSE=true ;;
        --output=md) OUTPUT_FORMAT="md" ;;
        --output=json) OUTPUT_FORMAT="json" ;;
    esac
done

# 创建目录
mkdir -p "$OUTPUT_DIR"

echo "📊 GitHub Trending 抓取 ($DATE)"
echo "=========================================="

# 使用 web_fetch 抓取
echo "正在抓取 GitHub Trending..."
FETCH_RESULT=$(web_fetch --url="https://github.com/trending" --maxChars=8000 2>&1)

# 提取内容 (简化版，实际应该用 Python 解析)
echo "解析抓取结果..."

# 生成 Markdown 报告
cat > "$OUTPUT_FILE" << 'EOF'
# 📈 GitHub Trending 每日报告

EOF

echo "**日期**: $DATE" >> "$OUTPUT_FILE"
echo "**生成时间**: $TIMESTAMP" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 添加抓取的内容 (简化处理)
echo "## 🔥 今日热门项目" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 从 web_fetch 结果中提取项目信息
echo "$FETCH_RESULT" | grep -E "^## \[" | head -10 | while read line; do
    echo "$line" >> "$OUTPUT_FILE"
done

echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 统计信息
PROJECT_COUNT=$(echo "$FETCH_RESULT" | grep -c "^## \[" || echo 0)
RUST_COUNT=$(echo "$FETCH_RESULT" | grep -c "Rust" || echo 0)
PYTHON_COUNT=$(echo "$FETCH_RESULT" | grep -c "Python" || echo 0)
TS_COUNT=$(echo "$FETCH_RESULT" | grep -c "TypeScript" || echo 0)

cat >> "$OUTPUT_FILE" << EOF
## 📊 统计

| 指标 | 数值 |
|------|------|
| 总项目数 | $PROJECT_COUNT |
| Rust 项目 | $RUST_COUNT |
| Python 项目 | $PYTHON_COUNT |
| TypeScript 项目 | $TS_COUNT |

---

*报告生成于 $TIMESTAMP*
*数据源：https://github.com/trending*
EOF

echo ""
echo "=========================================="
echo "✅ 抓取完成：$OUTPUT_FILE"
echo "=========================================="
echo ""
echo "📊 统计:"
echo "• 总项目数：$PROJECT_COUNT"
echo "• Rust 项目：$RUST_COUNT"
echo "• Python 项目：$PYTHON_COUNT"
echo "• TypeScript 项目：$TS_COUNT"

# 如果启用详细模式，显示报告
if [ "$VERBOSE" = true ]; then
    echo ""
    echo "📋 报告内容:"
    echo "=========================================="
    cat "$OUTPUT_FILE"
fi
