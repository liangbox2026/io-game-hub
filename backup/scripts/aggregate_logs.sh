#!/bin/bash
# =============================================================================
# 日志聚合脚本 - Log Aggregator
# 功能：聚合各类系统日志，生成统一报告
# 用法：./aggregate_logs.sh
# =============================================================================

set -e

# 配置
LOG_DIR="/root/.openclaw/workspace/backup/logs"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
AGGREGATED="$LOG_DIR/aggregated_$DATE.md"

# 创建目录
mkdir -p "$LOG_DIR"

echo "📋 日志聚合 ($DATE)"
echo "=========================================="

# 开始生成报告
cat > "$AGGREGATED" << EOF
# 📋 系统日志聚合

**日期**: $DATE  
**生成时间**: $TIMESTAMP

---

EOF

# 1. 健康检查日志
echo "1️⃣  健康检查日志"
echo "----------------------------------------"
echo "## 🏥 健康检查" >> "$AGGREGATED"
echo "" >> "$AGGREGATED"

if ls /root/.openclaw/workspace/backup/logs/health_check*.log 1> /dev/null 2>&1; then
    grep -hE "^(✅|❌|⚠️|===)" /root/.openclaw/workspace/backup/logs/health_check*.log 2>/dev/null | tail -20 >> "$AGGREGATED" || echo "_无数据_" >> "$AGGREGATED"
else
    echo "_无健康检查日志_" >> "$AGGREGATED"
fi
echo "" >> "$AGGREGATED"

# 2. Gateway 自愈日志
echo "2️⃣  Gateway 自愈日志"
echo "----------------------------------------"
echo "## 🔧 Gateway 自愈" >> "$AGGREGATED"
echo "" >> "$AGGREGATED"

if ls /root/.openclaw/workspace/backup/logs/gateway_heal*.log 1> /dev/null 2>&1; then
    grep -hE "^\[.*\] \[(SUCCESS|ERROR|WARN|INFO)\]" /root/.openclaw/workspace/backup/logs/gateway_heal*.log 2>/dev/null | tail -20 >> "$AGGREGATED" || echo "_无数据_" >> "$AGGREGATED"
else
    echo "_无 Gateway 自愈日志_" >> "$AGGREGATED"
fi
echo "" >> "$AGGREGATED"

# 3. Cron 执行日志
echo "3️⃣  Cron 执行日志"
echo "----------------------------------------"
echo "## ⏰ Cron 执行" >> "$AGGREGATED"
echo "" >> "$AGGREGATED"

journalctl -u cron --since "today" 2>/dev/null | grep -E "(CMD|CMDOUT)" | tail -30 >> "$AGGREGATED" || echo "_无数据_" >> "$AGGREGATED"
echo "" >> "$AGGREGATED"

# 4. 技能进化日志
echo "4️⃣  技能进化日志"
echo "----------------------------------------"
echo "## 🧬 技能进化" >> "$AGGREGATED"
echo "" >> "$AGGREGATED"

if [ -f "$LOG_DIR/skill_evolution_$DATE.md" ]; then
    grep -E "^(进化指数 | 任务 | 文件|Commits|健康)" "$LOG_DIR/skill_evolution_$DATE.md" 2>/dev/null | head -10 >> "$AGGREGATED" || echo "_无数据_" >> "$AGGREGATED"
else
    echo "_今日技能进化报告尚未生成_" >> "$AGGREGATED"
fi
echo "" >> "$AGGREGATED"

# 5. 系统摘要
echo "5️⃣  生成摘要"
echo "----------------------------------------"
echo "## 📊 摘要统计" >> "$AGGREGATED"
echo "" >> "$AGGREGATED"

HEALTH_COUNT=$(grep -c "系统健康检查" /root/.openclaw/workspace/backup/logs/health_check*.log 2>/dev/null || echo 0)
HEAL_COUNT=$(grep -c "自愈" /root/.openclaw/workspace/backup/logs/gateway_heal*.log 2>/dev/null || echo 0)
CRON_ERRORS=$(journalctl -u cron --since "today" 2>/dev/null | grep -ci "error\|fail" || echo 0)

cat >> "$AGGREGATED" << EOF
| 指标 | 数值 |
|------|------|
| 健康检查次数 | $HEALTH_COUNT |
| Gateway 自愈 | $HEAL_COUNT |
| Cron 错误 | $CRON_ERRORS |
| 系统运行时间 | $(uptime -p 2>/dev/null || echo "unknown") |

EOF

echo "" >> "$AGGREGATED"
echo "---" >> "$AGGREGATED"
echo "" >> "$AGGREGATED"
echo "*报告生成于 $TIMESTAMP*" >> "$AGGREGATED"

echo ""
echo "=========================================="
echo "✅ 聚合完成：$AGGREGATED"
echo "=========================================="
echo ""
echo "📊 摘要:"
echo "• 健康检查：$HEALTH_COUNT 次"
echo "• Gateway 自愈：$HEAL_COUNT 次"
echo "• Cron 错误：$CRON_ERRORS 个"
