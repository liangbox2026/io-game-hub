#!/bin/bash
# =============================================================================
# 智能降级抓取脚本 - Smart Fetch with Fallback
# 功能：按 L0→L1→L2→L3 顺序自动尝试，直到成功
# 用法：./smart_fetch_fallback.sh <URL> [--verbose]
# =============================================================================

set -e

# 配置
LOG_DIR="/root/.openclaw/workspace/backup/logs"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
RESULT_FILE="$LOG_DIR/smart_fetch_result_$DATE.txt"

# 解析参数
VERBOSE=false
TARGET_URL=""
for arg in "$@"; do
    case $arg in
        --verbose) VERBOSE=true ;;
        *) TARGET_URL="$arg" ;;
    esac
done

# 检查 URL
if [ -z "$TARGET_URL" ]; then
    echo "❌ 请提供 URL"
    echo "用法：./smart_fetch_fallback.sh <URL> [--verbose]"
    exit 1
fi

# 创建目录
mkdir -p "$LOG_DIR"

# 结果记录
SUCCESS=false
METHOD_USED=""
CONTENT_LENGTH=0

echo "🔍 智能降级抓取"
echo "=========================================="
echo "目标 URL: $TARGET_URL"
echo "开始时间：$TIMESTAMP"
echo "=========================================="
echo ""

# 记录开始
{
    echo "智能抓取报告"
    echo "============"
    echo "URL: $TARGET_URL"
    echo "时间：$TIMESTAMP"
    echo ""
} > "$RESULT_FILE"

# =============================================================================
# L0: web_fetch (最快)
# =============================================================================
echo "1️⃣  尝试 L0: web_fetch (静态抓取)"
echo "----------------------------------------"

L0_START=$(date +%s%N)
L0_CONTENT=$(web_fetch --url="$TARGET_URL" --maxChars=8000 2>&1 || echo "")
L0_END=$(date +%s%N)
L0_DURATION=$(( (L0_END - L0_START) / 1000000 ))  # 毫秒

L0_LENGTH=${#L0_CONTENT}

if [ $L0_LENGTH -gt 500 ] && ! echo "$L0_CONTENT" | grep -q "404\|403\|Access denied"; then
    echo "✅ L0 成功！耗时：${L0_DURATION}ms, 内容：${L0_LENGTH} 字符"
    SUCCESS=true
    METHOD_USED="L0 - web_fetch"
    CONTENT_LENGTH=$L0_LENGTH
    echo "$L0_CONTENT" > "$LOG_DIR/smart_fetch_content_$DATE.txt"
else
    echo "❌ L0 失败 (内容过少或被拒绝)"
    echo "L0: 失败 (${L0_DURATION}ms, ${L0_LENGTH} chars)" >> "$RESULT_FILE"
fi

# =============================================================================
# L1: jina.ai Reader (绕过付费墙)
# =============================================================================
if [ "$SUCCESS" = false ]; then
    echo ""
    echo "2️⃣  尝试 L1: jina.ai Reader (付费墙绕过)"
    echo "----------------------------------------"
    
    JINA_URL="https://r.jina.ai/$TARGET_URL"
    L1_START=$(date +%s%N)
    L1_CONTENT=$(curl -s --connect-timeout 10 "$JINA_URL" 2>&1 || echo "")
    L1_END=$(date +%s%N)
    L1_DURATION=$(( (L1_END - L1_START) / 1000000 ))
    
    L1_LENGTH=${#L1_CONTENT}
    
    if [ $L1_LENGTH -gt 500 ] && ! echo "$L1_CONTENT" | grep -q "404\|403\|Access denied\|Blocked"; then
        echo "✅ L1 成功！耗时：${L1_DURATION}ms, 内容：${L1_LENGTH} 字符"
        SUCCESS=true
        METHOD_USED="L1 - jina.ai Reader"
        CONTENT_LENGTH=$L1_LENGTH
        echo "$L1_CONTENT" > "$LOG_DIR/smart_fetch_content_$DATE.txt"
    else
        echo "❌ L1 失败 (内容过少或被拒绝)"
        echo "L1: 失败 (${L1_DURATION}ms, ${L1_LENGTH} chars)" >> "$RESULT_FILE"
    fi
fi

# =============================================================================
# L2: browser 无头模式 (需要 browser 工具可用)
# =============================================================================
if [ "$SUCCESS" = false ]; then
    echo ""
    echo "3️⃣  尝试 L2: browser 无头模式 (动态渲染)"
    echo "----------------------------------------"
    
    # 检查 browser 是否可用
    if command -v browser &> /dev/null; then
        L2_START=$(date +%s%N)
        # 这里应该调用 browser 工具，但需要实际环境支持
        # 模拟调用
        L2_CONTENT=""
        L2_END=$(date +%s%N)
        L2_DURATION=$(( (L2_END - L2_START) / 1000000 ))
        
        if [ -n "$L2_CONTENT" ]; then
            echo "✅ L2 成功！耗时：${L2_DURATION}ms"
            SUCCESS=true
            METHOD_USED="L2 - browser (headless)"
            CONTENT_LENGTH=${#L2_CONTENT}
            echo "$L2_CONTENT" > "$LOG_DIR/smart_fetch_content_$DATE.txt"
        else
            echo "❌ L2 失败 (browser 不可用或内容为空)"
            echo "L2: 失败 (${L2_DURATION}ms, browser unavailable)" >> "$RESULT_FILE"
        fi
    else
        echo "⚠️  L2 跳过 (browser 工具未安装)"
        echo "L2: 跳过 (browser not available)" >> "$RESULT_FILE"
    fi
fi

# =============================================================================
# L3: browser 有头模式 + 登录 (需要账号)
# =============================================================================
if [ "$SUCCESS" = false ]; then
    echo ""
    echo "4️⃣  尝试 L3: browser 有头模式 + 登录"
    echo "----------------------------------------"
    echo "⚠️  L3 需要用户提供账号凭证"
    echo "⚠️  安全提示：不要提供重要账号 (银行、邮箱等)"
    echo ""
    echo "❌ L3 跳过 (需要人工介入)"
    echo "L3: 跳过 (requires manual login)" >> "$RESULT_FILE"
fi

# =============================================================================
# 最终结果
# =============================================================================
echo ""
echo "=========================================="
echo "📊 抓取结果"
echo "=========================================="

if [ "$SUCCESS" = true ]; then
    echo "✅ 抓取成功!"
    echo "使用方式：$METHOD_USED"
    echo "内容长度：$CONTENT_LENGTH 字符"
    echo "保存位置：$LOG_DIR/smart_fetch_content_$DATE.txt"
    
    {
        echo ""
        echo "结果：✅ 成功"
        echo "使用方式：$METHOD_USED"
        echo "内容长度：$CONTENT_LENGTH 字符"
    } >> "$RESULT_FILE"
    
    EXIT_CODE=0
else
    echo "❌ 所有方法都失败了"
    echo ""
    echo "建议:"
    echo "1. 检查 URL 是否正确"
    echo "2. 网站可能需要登录才能访问"
    echo "3. 网站可能有严格的反爬虫措施"
    echo "4. 考虑人工处理或寻找替代来源"
    
    {
        echo ""
        echo "结果：❌ 失败"
        echo "建议：人工介入或寻找替代来源"
    } >> "$RESULT_FILE"
    
    EXIT_CODE=1
fi

echo ""
echo "📄 完整报告：$RESULT_FILE"

exit $EXIT_CODE
