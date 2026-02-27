#!/bin/bash
# =============================================================================
# 生财有术自动抓取脚本 - 使用 web_fetch + jina.ai
# 说明：由于需要登录，此脚本用于辅助人工操作
# =============================================================================

set -e

DATE=$(date +%Y-%m-%d)
OUTPUT_DIR="/root/.openclaw/workspace/backup/outputs/shengcai"
mkdir -p "$OUTPUT_DIR"

echo "🦞 生财有术 OpenClaw 帖子抓取助手"
echo "=========================================="
echo ""
echo "由于生财有术需要登录，请按以下步骤操作:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "步骤 1: 在浏览器中打开并登录"
echo "  https://scys.com/"
echo ""
echo "步骤 2: 搜索 OpenClaw"
echo "  在搜索框输入：OpenClaw 或 小龙虾"
echo ""
echo "步骤 3: 复制帖子 URL"
echo "  右键点击帖子标题 → 复制链接地址"
echo ""
echo "步骤 4: 执行抓取 (对每个帖子)"
echo "  ./shengcai_auto_grab.sh https://scys.com/t/帖子 ID"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 如果提供了 URL 参数
if [ -n "$1" ]; then
    TARGET_URL="$1"
    OUTPUT_FILE="$OUTPUT_DIR/openclaw_$(date +%H%M%S).md"
    
    echo "📥 开始抓取："
    echo "URL: $TARGET_URL"
    echo "输出：$OUTPUT_FILE"
    echo ""
    
    # 尝试使用 jina.ai
    echo "尝试方法 1: jina.ai Reader..."
    JINA_URL="https://r.jina.ai/$TARGET_URL"
    
    if curl -s --connect-timeout 10 "$JINA_URL" > "$OUTPUT_FILE" 2>&1; then
        CONTENT_SIZE=$(wc -c < "$OUTPUT_FILE")
        if [ "$CONTENT_SIZE" -gt 500 ]; then
            echo "✅ 抓取成功！"
            echo "内容大小：$CONTENT_SIZE 字符"
            echo "保存位置：$OUTPUT_FILE"
            exit 0
        fi
    fi
    
    # 回退到 web_fetch
    echo "尝试方法 2: web_fetch..."
    if web_fetch --url="$TARGET_URL" --maxChars=8000 > "$OUTPUT_FILE" 2>&1; then
        CONTENT_SIZE=$(wc -c < "$OUTPUT_FILE")
        echo "✅ 抓取成功！"
        echo "内容大小：$CONTENT_SIZE 字符"
        echo "保存位置：$OUTPUT_FILE"
        exit 0
    fi
    
    echo "❌ 抓取失败，可能需要登录"
fi

echo "示例用法:"
echo "  ./shengcai_auto_grab.sh https://scys.com/t/12345"
