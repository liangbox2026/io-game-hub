#!/bin/bash
# =============================================================================
# 系统健康检查脚本 - System Health Check
# 功能：定期检查 Gateway、磁盘、内存、Cron 等关键组件状态
# 用法：./system_health_check.sh [--verbose] [--notify]
# =============================================================================

set -e

# 配置
ALERT_THRESHOLD_DISK=80        # 磁盘告警阈值 (%)
ALERT_THRESHOLD_MEMORY=80      # 内存告警阈值 (%)
ALERT_THRESHOLD_CRON_ERRORS=5  # Cron 错误告警阈值 (24 小时内)
GATEWAY_URL="http://127.0.0.1:18789/health"
LOG_DIR="/root/.openclaw/workspace/backup/logs"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# 解析参数
VERBOSE=false
NOTIFY=false
for arg in "$@"; do
    case $arg in
        --verbose) VERBOSE=true ;;
        --notify) NOTIFY=true ;;
    esac
done

# 创建日志目录
mkdir -p "$LOG_DIR"

# 告警数组
ALERTS=()
WARNINGS=()
INFO=()

# 颜色输出
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    INFO+=("$1")
    [ "$VERBOSE" = true ] && echo -e "${BLUE}ℹ️  $1${NC}"
}

log_warning() {
    WARNINGS+=("$1")
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_alert() {
    ALERTS+=("$1")
    echo -e "${RED}❌ $1${NC}"
}

log_success() {
    log_info "✅ $1"
}

# =============================================================================
# 检查项 1: Gateway 状态
# =============================================================================
check_gateway() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}1️⃣  Gateway 状态检查${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # HTTP 健康检查 (检查端口是否可访问)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$GATEWAY_URL" 2>/dev/null)
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "304" ]; then
        log_success "Gateway HTTP 可访问 (状态码：$HTTP_CODE)"
    else
        log_alert "Gateway HTTP 不可访问 (状态码：$HTTP_CODE)"
    fi
    
    # 进程检查
    GATEWAY_PID=$(pgrep -f "openclaw-gateway" | head -1)
    if [ -n "$GATEWAY_PID" ]; then
        log_success "Gateway 进程运行中 (PID: $GATEWAY_PID)"
        
        # 运行时间
        UPTIME=$(ps -o etime= -p "$GATEWAY_PID" 2>/dev/null | tr -d ' ')
        log_info "Gateway 运行时长：$UPTIME"
    else
        log_alert "Gateway 进程未运行"
    fi
    
    # 端口检查
    if netstat -tlnp 2>/dev/null | grep -q ":18789" || ss -tlnp 2>/dev/null | grep -q ":18789"; then
        log_success "Gateway 端口 18789 正常监听"
    else
        log_warning "Gateway 端口 18789 未监听"
    fi
}

# =============================================================================
# 检查项 2: 磁盘使用率
# =============================================================================
check_disk() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}2️⃣  磁盘使用率检查${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 根分区
    DISK_INFO=$(df -h / | tail -1)
    DISK_TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
    DISK_USED=$(echo "$DISK_INFO" | awk '{print $3}')
    DISK_AVAIL=$(echo "$DISK_INFO" | awk '{print $4}')
    DISK_USAGE=$(echo "$DISK_INFO" | awk '{print $5}' | tr -d '%')
    
    echo "根分区：总计 ${DISK_TOTAL}, 已用 ${DISK_USED}, 可用 ${DISK_AVAIL}, 使用率 ${DISK_USAGE}%"
    
    if [ "$DISK_USAGE" -ge "$ALERT_THRESHOLD_DISK" ]; then
        log_alert "磁盘使用率 ${DISK_USAGE}% 超过阈值 ${ALERT_THRESHOLD_DISK}%"
    elif [ "$DISK_USAGE" -ge 70 ]; then
        log_warning "磁盘使用率 ${DISK_USAGE}% 接近阈值"
    else
        log_success "磁盘使用率正常 (${DISK_USAGE}%)"
    fi
    
    # 检查 OpenClaw 目录大小
    OC_SIZE=$(du -sh /root/.openclaw 2>/dev/null | cut -f1)
    log_info "OpenClaw 目录大小：$OC_SIZE"
}

# =============================================================================
# 检查项 3: 内存使用率
# =============================================================================
check_memory() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}3️⃣  内存使用率检查${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    MEM_INFO=$(free -h | grep "^Mem:")
    MEM_TOTAL=$(echo "$MEM_INFO" | awk '{print $2}')
    MEM_USED=$(echo "$MEM_INFO" | awk '{print $3}')
    MEM_FREE=$(echo "$MEM_INFO" | awk '{print $4}')
    MEM_AVAIL=$(echo "$MEM_INFO" | awk '{print $7}')
    MEM_USAGE=$(echo "$MEM_INFO" | awk '{printf("%.0f", $3/$2 * 100)}')
    
    echo "内存：总计 ${MEM_TOTAL}, 已用 ${MEM_USED}, 可用 ${MEM_AVAIL}, 使用率 ${MEM_USAGE}%"
    
    if [ "$MEM_USAGE" -ge "$ALERT_THRESHOLD_MEMORY" ]; then
        log_alert "内存使用率 ${MEM_USAGE}% 超过阈值 ${ALERT_THRESHOLD_MEMORY}%"
    elif [ "$MEM_USAGE" -ge 70 ]; then
        log_warning "内存使用率 ${MEM_USAGE}% 接近阈值"
    else
        log_success "内存使用率正常 (${MEM_USAGE}%)"
    fi
}

# =============================================================================
# 检查项 4: Cron 任务状态
# =============================================================================
check_cron() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}4️⃣  Cron 任务状态检查${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Cron 服务状态
    if systemctl is-active crond > /dev/null 2>&1 || systemctl is-active cron > /dev/null 2>&1; then
        log_success "Cron 服务运行中"
    else
        log_warning "Cron 服务未运行"
    fi
    
    # 检查 Cron 日志中的错误 (24 小时内)
    CRON_ERRORS=$(journalctl -u cron --since "24 hours ago" 2>/dev/null | grep -iE "(error|fail)" | wc -l)
    
    if [ "$CRON_ERRORS" -gt "$ALERT_THRESHOLD_CRON_ERRORS" ]; then
        log_alert "Cron 24 小时内 ${CRON_ERRORS} 个错误 (阈值：${ALERT_THRESHOLD_CRON_ERRORS})"
        
        # 显示最近的错误
        if [ "$VERBOSE" = true ]; then
            echo -e "\n${YELLOW}最近 5 个 Cron 错误:${NC}"
            journalctl -u cron --since "24 hours ago" 2>/dev/null | grep -iE "(error|fail)" | tail -5
        fi
    else
        log_success "Cron 错误数正常 (24 小时：${CRON_ERRORS} 个)"
    fi
    
    # 显示当前 Cron 任务
    CRON_COUNT=$(crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" | wc -l)
    log_info "当前 Cron 任务数：$CRON_COUNT"
}

# =============================================================================
# 检查项 5: OpenClaw 版本
# =============================================================================
check_openclaw_version() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}5️⃣  OpenClaw 版本检查${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 当前版本
    CURRENT_VERSION=$(openclaw --version 2>/dev/null || echo "unknown")
    log_info "当前版本：$CURRENT_VERSION"
    
    # 检查更新 (不阻塞)
    if command -v npm &> /dev/null; then
        LATEST_VERSION=$(npm view openclaw version 2>/dev/null || echo "unknown")
        if [ "$LATEST_VERSION" != "unknown" ] && [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
            log_warning "有新版本可用：$CURRENT_VERSION → $LATEST_VERSION"
        else
            log_success "已是最新版本"
        fi
    fi
}

# =============================================================================
# 检查项 6: 备份状态
# =============================================================================
check_backup() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}6️⃣  备份状态检查${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    BACKUP_DIR="/root/.openclaw/backup"
    
    # 备份脚本是否存在
    if [ -f "$BACKUP_DIR/scripts/daily_backup.sh" ]; then
        log_success "备份脚本存在"
    else
        log_alert "备份脚本缺失"
    fi
    
    # 最新备份
    LATEST_BACKUP=$(ls -td "$BACKUP_DIR"/workspace-backup-* 2>/dev/null | head -1)
    if [ -n "$LATEST_BACKUP" ] && [ -d "$LATEST_BACKUP" ]; then
        BACKUP_DATE=$(basename "$LATEST_BACKUP" | sed 's/workspace-backup-//')
        BACKUP_SIZE=$(du -sh "$LATEST_BACKUP" 2>/dev/null | cut -f1)
        log_info "最新备份：$BACKUP_DATE (大小：$BACKUP_SIZE)"
        
        # 检查备份是否超过 7 天
        BACKUP_MTIME=$(stat -c %Y "$LATEST_BACKUP" 2>/dev/null || echo "0")
        if [ "$BACKUP_MTIME" != "0" ]; then
            BACKUP_AGE_DAYS=$(( ($(date +%s) - BACKUP_MTIME) / 86400 ))
            if [ "$BACKUP_AGE_DAYS" -gt 7 ]; then
                log_warning "备份已超过 7 天未更新"
            else
                log_success "备份在 7 天内"
            fi
        fi
    else
        log_warning "未找到备份目录"
    fi
}

# =============================================================================
# 检查项 7: 系统负载
# =============================================================================
check_system_load() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}7️⃣  系统负载检查${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 负载平均值
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | xargs)
    echo "负载平均：$LOAD_AVG"
    
    # CPU 核心数
    CPU_CORES=$(nproc 2>/dev/null || echo "unknown")
    log_info "CPU 核心数：$CPU_CORES"
    
    # 运行时间
    UPTIME_INFO=$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
    log_info "系统运行时间：$UPTIME_INFO"
}

# =============================================================================
# 生成报告
# =============================================================================
generate_report() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📊 健康检查报告摘要${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    TOTAL_CHECKS=$((${#ALERTS[@]} + ${#WARNINGS[@]} + ${#INFO[@]}))
    
    echo ""
    if [ ${#ALERTS[@]} -gt 0 ]; then
        echo -e "${RED}❌ 告警：${#ALERTS[@]} 项${NC}"
        for alert in "${ALERTS[@]}"; do
            echo -e "${RED}   • $alert${NC}"
        done
    fi
    
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  警告：${#WARNINGS[@]} 项${NC}"
        for warning in "${WARNINGS[@]}"; do
            echo -e "${YELLOW}   • $warning${NC}"
        done
    fi
    
    echo -e "${GREEN}✅ 正常：${#INFO[@]} 项${NC}"
    echo ""
    
    # 总体状态
    if [ ${#ALERTS[@]} -gt 0 ]; then
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}🚨 系统状态：需要关注${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        EXIT_CODE=2
    elif [ ${#WARNINGS[@]} -gt 0 ]; then
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}⚠️  系统状态：基本正常 (有警告)${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        EXIT_CODE=1
    else
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ 系统状态：健康${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        EXIT_CODE=0
    fi
    
    # 保存报告到文件
    REPORT_FILE="$LOG_DIR/health_check_${DATE}.log"
    {
        echo "=========================================="
        echo "系统健康检查报告"
        echo "时间：$TIMESTAMP"
        echo "=========================================="
        echo ""
        echo "告警 (${#ALERTS[@]}):"
        printf '  - %s\n' "${ALERTS[@]}"
        echo ""
        echo "警告 (${#WARNINGS[@]}):"
        printf '  - %s\n' "${WARNINGS[@]}"
        echo ""
        echo "信息 (${#INFO[@]}):"
        printf '  - %s\n' "${INFO[@]}"
        echo ""
        echo "总体状态: $([ $EXIT_CODE -eq 0 ] && echo "健康" || ([ $EXIT_CODE -eq 1 ] && echo "警告" || echo "告警"))"
    } > "$REPORT_FILE"
    
    log_info "报告已保存：$REPORT_FILE"
    
    return $EXIT_CODE
}

# =============================================================================
# 发送通知 (可选)
# =============================================================================
send_notification() {
    if [ "$NOTIFY" = true ] && [ ${#ALERTS[@]} -gt 0 ]; then
        echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}📬 发送告警通知${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        # Feishu 通知 (如果配置了)
        FEISHU_SCRIPT="/root/.openclaw/backup/scripts/send_feishu_notification.py"
        if [ -f "$FEISHU_SCRIPT" ]; then
            MESSAGE="🚨 系统告警\n告警项：${#ALERTS[@]}\n$(printf '%s\n' "${ALERTS[@]}")"
            python3 "$FEISHU_SCRIPT" "系统健康检查告警" "$MESSAGE" 2>/dev/null && \
                log_success "Feishu 通知已发送" || \
                log_warning "Feishu 通知发送失败"
        else
            log_info "Feishu 通知脚本未配置"
        fi
    fi
}

# =============================================================================
# 主函数
# =============================================================================
main() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     系统健康检查 - System Health Check    ║"
    echo "║           $(date +"%Y-%m-%d %H:%M:%S")              ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # 执行所有检查
    check_gateway
    check_disk
    check_memory
    check_cron
    check_openclaw_version
    check_backup
    check_system_load
    
    # 生成报告
    generate_report
    EXIT_CODE=$?
    
    # 发送通知 (如果有告警且启用了通知)
    send_notification
    
    exit $EXIT_CODE
}

# 运行主函数
main
