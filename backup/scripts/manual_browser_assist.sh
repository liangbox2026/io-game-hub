#!/bin/bash
# =============================================================================
# 人工接管浏览器爬取脚本 - Manual Browser Assist
# 功能：人工登录网站后，自动抓取内容
# 用法：./manual_browser_assist.sh [--setup|--grab|--help]
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
# 帮助信息
# =============================================================================
show_help() {
    cat << 'EOF'
🦞 人工接管浏览器爬取助手

用法：./manual_browser_assist.sh [命令] [选项]

命令:
  setup       启动浏览器，人工登录网站
  grab        抓取当前页面内容
  status      检查浏览器状态
  cookies     导出当前 Cookie
  help        显示帮助信息

选项:
  --url=URL       目标网站 URL
  --name=NAME     网站标识名称
  --output=FILE   输出文件名
  --full          完整页面截图
  --verbose       详细输出

示例:
  # 1. 启动浏览器并登录
  ./manual_browser_assist.sh setup --url=https://example.com --name=example
  
  # 2. 登录后抓取内容
  ./manual_browser_assist.sh grab --name=example --output=article1
  
  # 3. 导出 Cookie 以便下次自动访问
  ./manual_browser_assist.sh cookies --name=example

工作流程:
  1. setup  → 启动浏览器 → 人工登录 → 保持登录状态
  2. grab   → 自动抓取当前页面 → 保存为 Markdown
  3. cookies → 导出 Cookie → 下次可自动访问

EOF
}

# =============================================================================
# 步骤 1: 启动浏览器 (人工登录)
# =============================================================================
setup_browser() {
    local TARGET_URL=""
    local SITE_NAME=""
    
    # 解析参数
    for arg in "$@"; do
        case $arg in
            --url=*) TARGET_URL="${arg#*=}" ;;
            --name=*) SITE_NAME="${arg#*=}" ;;
        esac
    done
    
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     人工接管浏览器 - 登录阶段              ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    if [ -z "$SITE_NAME" ]; then
        echo -e "${YELLOW}⚠️  未指定网站名称，使用默认名称 'manual_site'${NC}"
        SITE_NAME="manual_site"
    fi
    
    echo ""
    echo "📋 步骤说明:"
    echo "=========================================="
    echo "1. 浏览器即将启动 (有头模式)"
    echo "2. 请在浏览器中手动登录目标网站"
    echo "3. 登录完成后，保持浏览器开启"
    echo "4. 返回终端执行抓取命令"
    echo ""
    
    if [ -n "$TARGET_URL" ]; then
        echo "目标网站：$TARGET_URL"
        echo ""
    fi
    
    echo -e "${YELLOW}准备启动浏览器...${NC}"
    echo ""
    
    # 启动浏览器 (有头模式)
    echo "🌐 启动浏览器..."
    openclaw browser start --profile=openclaw 2>&1 | tee -a "$LOG_DIR/browser_setup_$DATE.log"
    
    if [ -n "$TARGET_URL" ]; then
        echo "🔗 打开目标网站..."
        openclaw browser navigate --url="$TARGET_URL" 2>&1 | tee -a "$LOG_DIR/browser_setup_$DATE.log"
    fi
    
    echo ""
    echo -e "${GREEN}✅ 浏览器已启动!${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "下一步:"
    echo "1. 在浏览器中登录网站"
    echo "2. 导航到要抓取的页面"
    echo "3. 执行抓取命令:"
    echo ""
    echo "   ./manual_browser_assist.sh grab --name=$SITE_NAME"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # 保存状态
    echo "$SITE_NAME" > "$LOG_DIR/browser_session_name.txt"
    echo "$TIMESTAMP" > "$LOG_DIR/browser_session_time.txt"
}

# =============================================================================
# 步骤 2: 抓取内容
# =============================================================================
grab_content() {
    local SITE_NAME=""
    local OUTPUT_FILE=""
    local FULL_PAGE=false
    
    # 解析参数
    for arg in "$@"; do
        case $arg in
            --name=*) SITE_NAME="${arg#*=}" ;;
            --output=*) OUTPUT_FILE="${arg#*=}" ;;
            --full) FULL_PAGE=true ;;
        esac
    done
    
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     人工接管浏览器 - 抓取阶段              ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # 默认命名
    if [ -z "$SITE_NAME" ]; then
        SITE_NAME=$(cat "$LOG_DIR/browser_session_name.txt" 2>/dev/null || echo "manual_site")
    fi
    
    if [ -z "$OUTPUT_FILE" ]; then
        OUTPUT_FILE="content_$(date +%H%M%S)"
    fi
    
    OUTPUT_PATH="$OUTPUT_DIR/${SITE_NAME}_${OUTPUT_FILE}.md"
    SCREENSHOT_PATH="$OUTPUT_DIR/${SITE_NAME}_${OUTPUT_FILE}.png"
    
    echo "📊 抓取配置:"
    echo "=========================================="
    echo "网站标识：$SITE_NAME"
    echo "输出文件：$OUTPUT_PATH"
    echo "完整页面：$([ "$FULL_PAGE" = true ] && echo "是" || echo "否")"
    echo "时间：$TIMESTAMP"
    echo "=========================================="
    echo ""
    
    # 检查浏览器状态
    echo "🔍 检查浏览器状态..."
    BROWSER_STATUS=$(openclaw browser status 2>&1)
    
    if echo "$BROWSER_STATUS" | grep -q "running"; then
        echo -e "${GREEN}✅ 浏览器运行中${NC}"
    else
        echo -e "${RED}❌ 浏览器未运行${NC}"
        echo ""
        echo "请先执行:"
        echo "  ./manual_browser_assist.sh setup --url=YOUR_URL"
        exit 1
    fi
    
    echo ""
    echo "📸 抓取页面内容..."
    
    # 抓取 Markdown 内容
    openclaw browser snapshot --format=markdown 2>&1 | tee "$OUTPUT_PATH"
    
    # 可选：截图
    if [ "$FULL_PAGE" = true ]; then
        echo ""
        echo "📷 截取完整页面..."
        openclaw browser screenshot --fullPage=true --output="$SCREENSHOT_PATH" 2>&1
        echo "截图已保存：$SCREENSHOT_PATH"
    fi
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ 抓取完成!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "📄 输出文件：$OUTPUT_PATH"
    echo "📊 内容大小：$(wc -c < "$OUTPUT_PATH" 2>/dev/null || echo "unknown") 字符"
    echo "📝 行数：$(wc -l < "$OUTPUT_PATH" 2>/dev/null || echo "unknown") 行"
    echo ""
    
    # 记录日志
    {
        echo "抓取记录"
        echo "========"
        echo "时间：$TIMESTAMP"
        echo "网站：$SITE_NAME"
        echo "输出：$OUTPUT_PATH"
        echo "大小：$(wc -c < "$OUTPUT_PATH") 字符"
        echo ""
    } >> "$LOG_DIR/grab_history_$DATE.txt"
}

# =============================================================================
# 步骤 3: 导出 Cookie
# =============================================================================
export_cookies() {
    local SITE_NAME=""
    
    # 解析参数
    for arg in "$@"; do
        case $arg in
            --name=*) SITE_NAME="${arg#*=}" ;;
        esac
    done
    
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     导出 Cookie                           ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    if [ -z "$SITE_NAME" ]; then
        SITE_NAME=$(cat "$LOG_DIR/browser_session_name.txt" 2>/dev/null || echo "manual_site")
    fi
    
    COOKIE_DIR="/root/.openclaw/credentials/cookies"
    mkdir -p "$COOKIE_DIR"
    
    COOKIE_FILE="$COOKIE_DIR/${SITE_NAME}_$(date +%Y%m%d).json"
    
    echo "🍪 导出 Cookie..."
    echo "目标文件：$COOKIE_FILE"
    echo ""
    
    # 评估 JavaScript 获取 Cookie
    echo "正在获取 Cookie..."
    openclaw browser eval --fn="JSON.stringify(document.cookie)" 2>&1 | \
        python3 -c "
import sys, json
cookie_str = sys.stdin.read().strip()
if cookie_str:
    # 简单解析 cookie 字符串
    cookies = []
    for item in cookie_str.split(';'):
        if '=' in item:
            name, value = item.split('=', 1)
            cookies.append({'name': name.strip(), 'value': value.strip()})
    print(json.dumps(cookies, indent=2, ensure_ascii=False))
else:
    print('[]')
" > "$COOKIE_FILE"
    
    COOKIE_COUNT=$(grep -c '"name"' "$COOKIE_FILE" 2>/dev/null || echo 0)
    
    echo ""
    echo -e "${GREEN}✅ Cookie 导出完成!${NC}"
    echo ""
    echo "📄 文件位置：$COOKIE_FILE"
    echo "🍪 Cookie 数量：$COOKIE_COUNT"
    echo ""
    echo "⚠️  安全提示:"
    echo "1. 此文件包含敏感信息，请妥善保管"
    echo "2. 文件权限已设置为仅所有者可读写"
    echo "3. 建议定期更新 Cookie"
    echo ""
    
    # 设置权限
    chmod 600 "$COOKIE_FILE"
}

# =============================================================================
# 检查浏览器状态
# =============================================================================
check_status() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     浏览器状态检查                        ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    openclaw browser status 2>&1
    
    echo ""
    echo "会话信息:"
    if [ -f "$LOG_DIR/browser_session_name.txt" ]; then
        echo "网站标识：$(cat "$LOG_DIR/browser_session_name.txt")"
        echo "启动时间：$(cat "$LOG_DIR/browser_session_time.txt")"
    else
        echo "无活动会话"
    fi
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
        setup)
            shift
            setup_browser "$@"
            ;;
        grab)
            shift
            grab_content "$@"
            ;;
        cookies)
            shift
            export_cookies "$@"
            ;;
        status)
            check_status
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

# 运行
main "$@"
