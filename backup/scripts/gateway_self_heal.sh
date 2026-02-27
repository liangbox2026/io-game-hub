#!/bin/bash
# =============================================================================
# Gateway 自愈脚本 - Gateway Self-Healing
# 功能：检测 Gateway 异常并自动尝试修复
# 用法：./gateway_self_heal.sh [--verbose] [--force-restart]
# =============================================================================

set -e

# 配置
GATEWAY_URL="http://127.0.0.1:18789"
HEALTH_ENDPOINT="$GATEWAY_URL/health"
MAX_RESTART_ATTEMPTS=3
RESTART_DELAY=5  # 秒
LOG_DIR="/root/.openclaw/workspace/backup/logs"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# 解析参数
VERBOSE=false
FORCE_RESTART=false
for arg in "$@"; do
    case $arg in
        --verbose) VERBOSE=true ;;
        --force-restart) FORCE_RESTART=true ;;
    esac
done

# 创建日志目录
mkdir -p "$LOG_DIR"

# 日志函数
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_DIR/gateway_heal_$DATE.log"
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
log_success() { log "SUCCESS" "$@"; }

# =============================================================================
# 检查 Gateway 健康状态
# =============================================================================
check_gateway_health() {
    # HTTP 检查
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$HEALTH_ENDPOINT" 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "304" ]; then
        return 0  # 健康
    else
        return 1  # 异常
    fi
}

# =============================================================================
# 检查 Gateway 进程
# =============================================================================
check_gateway_process() {
    local pid=$(pgrep -f "openclaw-gateway" | head -1)
    
    if [ -n "$pid" ]; then
        log_info "Gateway 进程运行中 (PID: $pid)"
        
        # 检查运行时间
        local uptime=$(ps -o etime= -p "$pid" 2>/dev/null | tr -d ' ')
        log_info "Gateway 运行时长：$uptime"
        
        return 0  # 进程存在
    else
        log_warn "Gateway 进程未运行"
        return 1  # 进程不存在
    fi
}

# =============================================================================
# 检查端口监听
# =============================================================================
check_gateway_port() {
    if netstat -tlnp 2>/dev/null | grep -q ":18789" || ss -tlnp 2>/dev/null | grep -q ":18789"; then
        log_info "Gateway 端口 18789 正常监听"
        return 0
    else
        log_warn "Gateway 端口 18789 未监听"
        return 1
    fi
}

# =============================================================================
# 诊断 Gateway 问题
# =============================================================================
diagnose_gateway() {
    log_info "开始诊断 Gateway 问题..."
    
    local issues=()
    
    # 1. 检查进程
    if ! check_gateway_process; then
        issues+=("process_missing")
    fi
    
    # 2. 检查端口
    if ! check_gateway_port; then
        issues+=("port_missing")
    fi
    
    # 3. 检查 HTTP
    if ! check_gateway_health; then
        issues+=("http_unreachable")
    fi
    
    # 4. 检查日志中的错误
    local recent_errors=$(journalctl -u openclaw-gateway --since "1 hour ago" 2>/dev/null | grep -ci "error\|fail" || echo 0)
    if [ "$recent_errors" -gt 10 ]; then
        issues+=("high_error_rate")
        log_warn "Gateway 1 小时内 ${recent_errors} 个错误"
    fi
    
    # 5. 检查内存使用
    local gateway_pid=$(pgrep -f "openclaw-gateway" | head -1)
    if [ -n "$gateway_pid" ]; then
        local mem_usage=$(ps -o %mem= -p "$gateway_pid" 2>/dev/null | tr -d ' ')
        if [ -n "$mem_usage" ] && [ "${mem_usage%.*}" -gt 50 ]; then
            issues+=("high_memory")
            log_warn "Gateway 内存使用率：${mem_usage}%"
        fi
    fi
    
    # 输出诊断结果
    if [ ${#issues[@]} -eq 0 ]; then
        log_info "✅ Gateway 诊断正常"
        return 0
    else
        log_warn "⚠️  发现问题：${issues[*]}"
        echo "${issues[@]}"
        return 1
    fi
}

# =============================================================================
# 修复 Gateway 问题
# =============================================================================
heal_gateway() {
    local attempt=1
    
    while [ $attempt -le $MAX_RESTART_ATTEMPTS ]; do
        log_info "尝试修复 Gateway (第 $attempt/$MAX_RESTART_ATTEMPTS 次)..."
        
        # 步骤 1: 停止 Gateway
        log_info "停止 Gateway..."
        if openclaw gateway stop 2>/dev/null; then
            log_info "Gateway 已停止"
        else
            log_warn "Gateway 停止命令失败，尝试强制停止..."
            pkill -f "openclaw-gateway" 2>/dev/null || true
        fi
        
        # 等待进程完全停止
        sleep 3
        
        # 步骤 2: 清理残留进程
        local remaining_pid=$(pgrep -f "openclaw-gateway" | head -1)
        if [ -n "$remaining_pid" ]; then
            log_warn "发现残留进程 (PID: $remaining_pid)，强制终止..."
            kill -9 "$remaining_pid" 2>/dev/null || true
            sleep 2
        fi
        
        # 步骤 3: 启动 Gateway
        log_info "启动 Gateway..."
        if openclaw gateway start 2>/dev/null; then
            log_info "Gateway 启动命令成功"
        else
            log_error "Gateway 启动命令失败"
            attempt=$((attempt + 1))
            sleep $RESTART_DELAY
            continue
        fi
        
        # 等待 Gateway 启动
        sleep $RESTART_DELAY
        
        # 步骤 4: 验证修复
        if check_gateway_health && check_gateway_process && check_gateway_port; then
            log_success "✅ Gateway 已自动恢复！"
            return 0
        else
            log_warn "⚠️  第 $attempt 次修复未完全成功"
            attempt=$((attempt + 1))
            sleep $RESTART_DELAY
        fi
    done
    
    log_error "❌ 自动修复失败，需要人工介入"
    return 1
}

# =============================================================================
# 发送通知
# =============================================================================
send_notification() {
    local status=$1
    local message=$2
    
    log_info "发送通知：$status - $message"
    
    # Feishu 通知 (如果配置了)
    local FEISHU_SCRIPT="/root/.openclaw/backup/scripts/send_feishu_notification.py"
    if [ -f "$FEISHU_SCRIPT" ]; then
        python3 "$FEISHU_SCRIPT" "Gateway 自愈通知" "$status: $message" 2>/dev/null && \
            log_success "Feishu 通知已发送" || \
            log_warn "Feishu 通知发送失败"
    fi
}

# =============================================================================
# 生成报告
# =============================================================================
generate_report() {
    local status=$1
    local details=$2
    
    local report_file="$LOG_DIR/gateway_heal_report_$DATE.txt"
    
    {
        echo "=========================================="
        echo "Gateway 自愈报告"
        echo "时间：$TIMESTAMP"
        echo "=========================================="
        echo ""
        echo "状态：$status"
        echo "详情：$details"
        echo ""
        echo "诊断结果:"
        diagnose_gateway 2>&1 || true
        echo ""
        echo "=========================================="
    } >> "$report_file"
    
    log_info "报告已保存：$report_file"
}

# =============================================================================
# 主函数
# =============================================================================
main() {
    echo "=========================================="
    echo "Gateway 自愈脚本"
    echo "时间：$TIMESTAMP"
    echo "=========================================="
    echo ""
    
    # 强制重启模式
    if [ "$FORCE_RESTART" = true ]; then
        log_warn "强制重启模式"
        heal_gateway
        local result=$?
        if [ $result -eq 0 ]; then
            send_notification "✅ 自愈成功" "Gateway 已自动重启并恢复正常"
            generate_report "SUCCESS" "Gateway 强制重启成功"
        else
            send_notification "❌ 自愈失败" "Gateway 重启失败，需要人工介入"
            generate_report "FAILED" "Gateway 强制重启失败"
        fi
        exit $result
    fi
    
    # 正常检查模式
    log_info "检查 Gateway 健康状态..."
    
    if check_gateway_health; then
        log_success "✅ Gateway 健康，无需修复"
        exit 0
    fi
    
    log_warn "⚠️  Gateway 异常，开始诊断..."
    
    # 诊断问题
    local issues=$(diagnose_gateway)
    
    # 根据问题类型决定修复策略
    if echo "$issues" | grep -q "process_missing\|port_missing\|http_unreachable"; then
        log_info "检测到严重问题，执行修复..."
        heal_gateway
        local result=$?
        
        if [ $result -eq 0 ]; then
            send_notification "✅ 自愈成功" "Gateway 已自动恢复"
            generate_report "SUCCESS" "Gateway 自动修复成功，问题：$issues"
        else
            send_notification "❌ 自愈失败" "Gateway 修复失败，问题：$issues"
            generate_report "FAILED" "Gateway 自动修复失败，问题：$issues"
        fi
        
        exit $result
    elif echo "$issues" | grep -q "high_error_rate\|high_memory"; then
        log_warn "检测到性能问题，建议重启优化..."
        # 性能问题不自动重启，只记录告警
        send_notification "⚠️  性能告警" "Gateway $issues，建议择机重启"
        generate_report "WARNING" "Gateway 性能问题：$issues"
        exit 1
    else
        log_info "Gateway 状态正常"
        exit 0
    fi
}

# 运行主函数
main
