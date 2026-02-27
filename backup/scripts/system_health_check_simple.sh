#!/bin/bash
# 系统健康检查脚本 - 简化版
# 每 6 小时自动执行

DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
LOG_DIR="/root/.openclaw/workspace/backup/logs"
mkdir -p "$LOG_DIR"

echo "=== 系统健康检查 ($TIMESTAMP) ==="

# 1. Gateway 检查
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 http://127.0.0.1:18789/)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Gateway: 正常 ($HTTP_CODE)"
else
    echo "❌ Gateway: 异常 ($HTTP_CODE)"
fi

# 2. 磁盘
DISK=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
echo "$([ $DISK -lt 80 ] && echo '✅' || echo '❌') 磁盘：${DISK}%"

# 3. 内存
MEM=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100)}')
echo "$([ $MEM -lt 80 ] && echo '✅' || echo '❌') 内存：${MEM}%"

# 4. Cron 错误
CRON_ERR=$(journalctl -u cron --since "24 hours ago" 2>/dev/null | grep -ci "error\|fail")
CRON_ERR=${CRON_ERR:-0}
if [ "$CRON_ERR" -lt 5 ]; then
    echo "✅ Cron 错误：${CRON_ERR}/24h"
else
    echo "⚠️  Cron 错误：${CRON_ERR}/24h"
fi

# 5. OpenClaw 版本
OC_VER=$(openclaw --version 2>/dev/null || echo "unknown")
echo "ℹ️  OpenClaw: $OC_VER"

# 6. 运行时间
UPTIME=$(uptime -p 2>/dev/null || echo "unknown")
echo "ℹ️  运行时间：$UPTIME"

echo ""
echo "=== 检查完成 ==="
echo "日志：$LOG_DIR/health_check_$DATE.log"
