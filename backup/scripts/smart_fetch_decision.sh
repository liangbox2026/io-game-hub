#!/bin/bash
# =============================================================================
# 智能抓取决策树 - Smart Fetch Decision Tree
# 功能：根据 URL 和需求自动选择最优抓取方式 (L0-L3)
# 用法：./smart_fetch_decision.sh <URL> [选项]
# =============================================================================

set -e

# 配置
LOG_DIR="/root/.openclaw/workspace/backup/logs"
OUTPUT_DIR="/root/.openclaw/workspace/backup/outputs"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 创建目录
mkdir -p "$LOG_DIR" "$OUTPUT_DIR"

# =============================================================================
# 决策树核心逻辑
# =============================================================================

# 检测是否需要登录
needs_login() {
    local url="$1"
    # 检查 URL 是否包含登录相关关键词
    if echo "$url" | grep -qiE "(login|member|premium|subscribe|paywall)"; then
        return 0  # 需要登录
    fi
    return 1  # 不需要登录
}

# 检测是否是付费内容
is_paywalled() {
    local url="$1"
    # 检查已知付费网站
    if echo "$url" | grep -qiE "(medium\.com|wsj\.com|nytimes\.com|bloomberg\.com|every\.to|substack\.com)"; then
        return 0  # 是付费内容
    fi
    return 1  # 不是付费内容
}

# 检测是否需要 JS 渲染
needs_js() {
    local url="$1"
    # 检查是否是 SPA 或动态网站
    if echo "$url" | grep -qiE "(github\.com|twitter\.com|x\.com|reddit\.com|facebook\.com)"; then
        return 0  # 需要 JS
    fi
    return 1  # 不需要 JS
}

# 检测是否包含图片/图表内容
has_images() {
    local url="$1"
    # 检查是否是图片为主的网站
    if echo "$url" | grep -qiE "(instagram\.com|pinterest\.com|imgur\.com|photos|gallery)"; then
        return 0  # 包含图片
    fi
    return 1  # 不包含图片
}

# 决策函数
make_decision() {
    local url="$1"
    local level=0
    local method=""
    local reason=""
    
    echo -e "${BLUE}🔍 分析目标 URL...${NC}"
    echo "URL: $url"
    echo ""
    
    # 决策树
    if has_images "$url"; then
        level=3
        method="L3 - Browser + 视觉识别"
        reason="包含图片/图表内容，需要截图 + OCR"
    elif needs_login "$url"; then
        level=3
        method="L3 - Browser + 登录"
        reason="需要登录才能访问"
    elif is_paywalled "$url"; then
        level=1
        method="L1 - jina.ai Reader"
        reason="付费内容，jina.ai 可绕过付费墙"
    elif needs_js "$url"; then
        level=2
        method="L2 - Browser 无头模式"
        reason="需要 JS 渲染"
    else
        level=0
        method="L0 - web_fetch"
        reason="静态页面，最快最轻量"
    fi
    
    # 输出决策结果
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📊 决策结果:"
    echo "  推荐层级：$method"
    echo "  原因：$reason"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # 返回决策
    echo "$level|$method|$reason"
}

# =============================================================================
# 执行抓取
# =============================================================================

execute_fetch() {
    local url="$1"
    local level="$2"
    local output_file="$3"
    
    echo -e "${BLUE}🚀 执行抓取...${NC}"
    echo ""
    
    case $level in
        0)
            # L0: web_fetch
            echo "使用 L0 - web_fetch"
            if command -v web_fetch &> /dev/null; then
                web_fetch --url="$url" --maxChars=8000 > "$output_file" 2>&1
                echo "✅ web_fetch 完成"
            else
                echo "⚠️  web_fetch 不可用，尝试 curl"
                curl -s "$url" > "$output_file"
            fi
            ;;
        1)
            # L1: jina.ai Reader
            echo "使用 L1 - jina.ai Reader"
            local jina_url="https://r.jina.ai/$url"
            curl -s --connect-timeout 10 "$jina_url" > "$output_file"
            echo "✅ jina.ai 完成"
            ;;
        2)
            # L2: Browser 无头模式
            echo "使用 L2 - Browser 无头模式"
            echo "⚠️  需要 browser 工具支持"
            if command -v openclaw &> /dev/null; then
                openclaw browser navigate --url="$url" 2>&1 | tee -a "$LOG_DIR/browser_$DATE.log"
                sleep 3
                openclaw browser snapshot --format=markdown > "$output_file" 2>&1
                echo "✅ Browser 完成"
            else
                echo "❌ browser 工具不可用"
                return 1
            fi
            ;;
        3)
            # L3: Browser + 登录/视觉
            echo "使用 L3 - Browser + 登录/视觉识别"
            echo "⚠️  需要人工协助或高级配置"
            echo ""
            echo "请按以下步骤操作:"
            echo "1. 在浏览器中打开：$url"
            echo "2. 完成登录 (如果需要)"
            echo "3. 执行抓取命令"
            echo ""
            echo "或者使用人工接管脚本:"
            echo "  ./manual_browser_assist.sh grab --output=$(basename $output_file .md)"
            return 2  # 需要人工协助
            ;;
    esac
    
    # 检查结果
    if [ -f "$output_file" ]; then
        local size=$(wc -c < "$output_file")
        if [ "$size" -gt 100 ]; then
            echo "✅ 抓取成功！"
            echo "📄 输出文件：$output_file"
            echo "📊 内容大小：$size 字符"
            return 0
        else
            echo "⚠️  抓取内容过少 ($size 字符)"
            return 1
        fi
    else
        echo "❌ 抓取失败"
        return 1
    fi
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    if [ $# -lt 1 ]; then
        echo "🧠 智能抓取决策树"
        echo "用法：$0 <URL> [--execute] [--output=FILE]"
        echo ""
        echo "示例:"
        echo "  $0 https://github.com/trending"
        echo "  $0 https://medium.com/some-article --execute"
        echo ""
        exit 1
    fi
    
    local TARGET_URL="$1"
    local EXECUTE=false
    local OUTPUT_FILE=""
    
    # 解析参数
    shift
    for arg in "$@"; do
        case $arg in
            --execute)
                EXECUTE=true
                ;;
            --output=*)
                OUTPUT_FILE="${arg#*=}"
                ;;
        esac
    done
    
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     智能抓取决策树 - Smart Fetch          ║"
    echo "║           $TIMESTAMP                      ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    # 生成决策
    local decision=$(make_decision "$TARGET_URL")
    local level=$(echo "$decision" | cut -d'|' -f1)
    local method=$(echo "$decision" | cut -d'|' -f2)
    local reason=$(echo "$decision" | cut -d'|' -f3)
    
    # 生成输出文件名
    if [ -z "$OUTPUT_FILE" ]; then
        OUTPUT_FILE="$OUTPUT_DIR/fetch_$(date +%H%M%S).md"
    fi
    
    # 如果指定了 --execute，执行抓取
    if [ "$EXECUTE" = true ]; then
        echo ""
        execute_fetch "$TARGET_URL" "$level" "$OUTPUT_FILE"
        exit_code=$?
        
        # 记录日志
        {
            echo "智能抓取记录"
            echo "============"
            echo "时间：$TIMESTAMP"
            echo "URL: $TARGET_URL"
            echo "决策：$method"
            echo "原因：$reason"
            echo "输出：$OUTPUT_FILE"
            echo "状态：$([ $exit_code -eq 0 ] && echo "成功" || echo "失败")"
            echo ""
        } >> "$LOG_DIR/smart_fetch_history_$DATE.txt"
        
        exit $exit_code
    else
        # 仅显示决策，不执行
        echo "💡 提示:"
        echo "  添加 --execute 参数执行抓取"
        echo "  添加 --output=FILE 指定输出文件"
        echo ""
        echo "示例:"
        echo "  $0 $TARGET_URL --execute"
        echo "  $0 $TARGET_URL --execute --output=my_article.md"
        echo ""
    fi
}

# 运行主函数
main "$@"
