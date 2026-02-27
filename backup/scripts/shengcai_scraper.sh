#!/bin/bash
# =============================================================================
# 生财有术爬取脚本 - 生财有术专用爬取工具
# 用法：./shengcai_scraper.sh [setup|grab|all] [选项]
# =============================================================================

set -e

# 配置
SITE_NAME="shengcai"
TARGET_URL="https://scys.com/"
OUTPUT_DIR="/root/.openclaw/workspace/backup/outputs/shengcai"
LOG_DIR="/root/.openclaw/workspace/backup/logs"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 创建目录
mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

# =============================================================================
# 帮助信息
# =============================================================================
show_help() {
    cat << EOF
🦞 生财有术爬取助手

用法：./shengcai_scraper.sh [命令]

命令:
  setup       启动浏览器，人工登录生财有术
  grab        抓取当前页面内容
  all         完整流程 (setup + 等待 + grab)
  help        显示帮助

示例:
  # 方式 1: 分步执行
  ./shengcai_scraper.sh setup
  # 人工登录后...
  ./shengcai_scraper.sh grab --output=daily_topics

  # 方式 2: 一键执行
  ./shengcai_scraper.sh all --output=daily_topics

选项:
  --output=FILE   输出文件名
  --full          完整页面截图

网站信息:
  名称：生财有术
  URL: https://scys.com/
  类型：会员制社区

EOF
}

# =============================================================================
# 步骤 1: 启动浏览器 (人工登录)
# =============================================================================
setup_shengcai() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     生财有术 - 登录阶段                   ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo ""
    echo "📋 操作步骤:"
    echo "=========================================="
    echo "1. 浏览器即将启动"
    echo "2. 使用你的账号登录生财有术"
    echo "3. 建议导航到具体主题/帖子页面"
    echo "4. 保持浏览器开启，返回执行 grab 命令"
    echo ""
    echo "🎯 推荐爬取内容:"
    echo "  - 每日话题列表"
    echo "  - 精华帖内容"
    echo "  - 特定主题讨论"
    echo ""
    echo "🔗 常用页面:"
    echo "  - https://scys.com/ (首页)"
    echo "  - https://scys.com/topics (话题)"
    echo "  - https://scys.com/essence (精华)"
    echo ""
    echo -e "${YELLOW}准备启动浏览器...${NC}"
    echo ""
    
    # 启动浏览器
    openclaw browser start --profile=openclaw 2>&1 | tee -a "$LOG_DIR/shengcai_setup_$DATE.log"
    
    # 打开网站
    echo "🔗 打开生财有术..."
    openclaw browser navigate --url="$TARGET_URL" 2>&1 | tee -a "$LOG_DIR/shengcai_setup_$DATE.log"
    
    echo ""
    echo -e "${GREEN}✅ 浏览器已启动!${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "下一步:"
    echo "1. 在浏览器中登录生财有术"
    echo "2. 导航到要抓取的页面"
    echo "3. 执行:"
    echo ""
    echo "   ./shengcai_scraper.sh grab --output=页面名称"
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
grab_shengcai() {
    local OUTPUT_FILE=""
    local FULL_PAGE=false
    
    # 解析参数
    for arg in "$@"; do
        case $arg in
            --output=*) OUTPUT_FILE="${arg#*=}" ;;
            --full) FULL_PAGE=true ;;
        esac
    done
    
    # 默认命名
    if [ -z "$OUTPUT_FILE" ]; then
        OUTPUT_FILE="content_$(date +%H%M%S)"
    fi
    
    OUTPUT_PATH="$OUTPUT_DIR/${OUTPUT_FILE}.md"
    SCREENSHOT_PATH="$OUTPUT_DIR/${OUTPUT_FILE}.png"
    
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     生财有术 - 抓取阶段                   ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo "📊 抓取配置:"
    echo "=========================================="
    echo "网站：生财有术"
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
        echo "  ./shengcai_scraper.sh setup"
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
        echo "生财有术抓取记录"
        echo "================"
        echo "时间：$TIMESTAMP"
        echo "输出：$OUTPUT_PATH"
        echo "大小：$(wc -c < "$OUTPUT_PATH") 字符"
        echo ""
    } >> "$LOG_DIR/shengcai_history_$DATE.txt"
}

# =============================================================================
# 步骤 3: 完整流程
# =============================================================================
grab_all() {
    local OUTPUT_FILE=""
    
    for arg in "$@"; do
        case $arg in
            --output=*) OUTPUT_FILE="${arg#*=}" ;;
        esac
    done
    
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     生财有术 - 完整流程                   ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # 步骤 1: 启动浏览器
    setup_shengcai
    
    echo ""
    echo "⏳ 等待人工登录..."
    echo "=========================================="
    echo "请在浏览器中:"
    echo "1. 登录生财有术账号"
    echo "2. 导航到目标页面"
    echo "3. 完成后按回车继续..."
    echo ""
    read -p "按回车继续抓取..."
    
    # 步骤 2: 抓取
    echo ""
    grab_shengcai --output="${OUTPUT_FILE:-auto_$(date +%H%M%S)}"
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
            setup_shengcai
            ;;
        grab)
            shift
            grab_shengcai "$@"
            ;;
        all)
            shift
            grab_all "$@"
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
