#!/bin/bash
# =============================================================================
# 技能进化追踪器 - Skill Evolution Tracker
# 功能：自动追踪每日技能成长，生成进化报告
# 用法：./skill_evolution_tracker.sh [--verbose]
# =============================================================================

set -e

# 配置
LOG_DIR="/root/.openclaw/workspace/backup/logs"
MEMORY_DIR="/root/.openclaw/workspace/memory"
WORKSPACE="/root/.openclaw/workspace"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
WEEK=$(date +%Y-W%W)

# 解析参数
VERBOSE=false
for arg in "$@"; do
    case $arg in
        --verbose) VERBOSE=true ;;
    esac
done

# 创建日志目录
mkdir -p "$LOG_DIR"

# 输出文件
REPORT_FILE="$LOG_DIR/skill_evolution_$DATE.md"

# =============================================================================
# 数据收集
# =============================================================================

echo "📊 技能进化追踪 ($DATE)"
echo "=========================================="

# 1. 今日 Cron 任务执行情况
echo ""
echo "1️⃣  今日任务执行"
echo "----------------------------------------"

TASKS_BACKUP=$(journalctl -u cron --since "today" 2>/dev/null | grep -c "daily_backup" || echo 0)
TASKS_WORKLOG=$(journalctl -u cron --since "today" 2>/dev/null | grep -c "daily_worklog" || echo 0)
TASKS_NEWS=$(journalctl -u cron --since "today" 2>/dev/null | grep -c "ai_news" || echo 0)
TASKS_HEALTH=$(journalctl -u cron --since "today" 2>/dev/null | grep -c "health_check" || echo 0)
TASKS_HEAL=$(journalctl -u cron --since "today" 2>/dev/null | grep -c "gateway_heal" || echo 0)

echo "• 系统备份：$TASKS_BACKUP 次"
echo "• 工作日志：$TASKS_WORKLOG 次"
echo "• AI 新闻：$TASKS_NEWS 次"
echo "• 健康检查：$TASKS_HEALTH 次"
echo "• Gateway 自愈：$TASKS_HEAL 次"

TOTAL_TASKS=$((TASKS_BACKUP + TASKS_WORKLOG + TASKS_NEWS + TASKS_HEALTH + TASKS_HEAL))
echo "• 总计：$TOTAL_TASKS 次"

# 2. 新创建的文件 (可能是新技能)
echo ""
echo "2️⃣  新技能/工具"
echo "----------------------------------------"

NEW_SCRIPTS=$(find /root/.openclaw/workspace/backup/scripts -name "*.sh" -mtime -1 2>/dev/null | wc -l)
NEW_PYTHON=$(find /root/.openclaw/workspace -name "*.py" -mtime -1 2>/dev/null | wc -l)
NEW_MARKDOWN=$(find /root/.openclaw/workspace -name "*.md" -mtime -1 2>/dev/null | wc -l)

echo "• 新脚本 (.sh): $NEW_SCRIPTS 个"
echo "• 新 Python (.py): $NEW_PYTHON 个"
echo "• 新文档 (.md): $NEW_MARKDOWN 个"

TOTAL_FILES=$((NEW_SCRIPTS + NEW_PYTHON + NEW_MARKDOWN))
echo "• 总计：$TOTAL_FILES 个新文件"

# 3. Git commits
echo ""
echo "3️⃣  代码提交"
echo "----------------------------------------"

cd "$WORKSPACE"
COMMITS_TODAY=$(git log --since "today" --oneline 2>/dev/null | wc -l)
COMMITS_WEEK=$(git log --since "1 week ago" --oneline 2>/dev/null | wc -l)
TOTAL_COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo 0)

echo "• 今日 commits: $COMMITS_TODAY 个"
echo "• 本周 commits: $COMMITS_WEEK 个"
echo "• 总计 commits: $TOTAL_COMMITS 个"

# 4. 技能相关活动
echo ""
echo "4️⃣  技能活动"
echo "----------------------------------------"

# 检查是否使用了 browser 工具
BROWSER_USAGE=$(grep -r "browser" /root/.openclaw/workspace/memory/$DATE.md 2>/dev/null | wc -l || echo 0)
echo "• Browser 使用：$BROWSER_USAGE 次"

# 检查是否使用了 web_search
SEARCH_USAGE=$(grep -r "web_search" /root/.openclaw/workspace/memory/$DATE.md 2>/dev/null | wc -l || echo 0)
echo "• Web Search 使用：$SEARCH_USAGE 次"

# 检查是否使用了 exec
EXEC_USAGE=$(grep -r "exec" /root/.openclaw/workspace/memory/$DATE.md 2>/dev/null | wc -l || echo 0)
echo "• Exec 使用：$EXEC_USAGE 次"

# 5. 系统健康状态
echo ""
echo "5️⃣  系统健康"
echo "----------------------------------------"

GATEWAY_OK=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 http://127.0.0.1:18789/ 2>/dev/null)
if [ "$GATEWAY_OK" = "200" ]; then
    echo "• Gateway: ✅ 正常"
else
    echo "• Gateway: ❌ 异常 ($GATEWAY_OK)"
fi

DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
echo "• 磁盘：${DISK_USAGE}%"

MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100)}')
echo "• 内存：${MEM_USAGE}%"

# =============================================================================
# 进化指数计算
# =============================================================================
echo ""
echo "=========================================="
echo "📊 进化指数计算"
echo "=========================================="

# 计算公式：
# 进化指数 = (任务分 × 0.3) + (文件分 × 0.3) + (commits 分 × 0.2) + (健康分 × 0.2)

# 任务分 (满分 10)
if [ "$TOTAL_TASKS" -ge 10 ]; then TASK_SCORE=10; else TASK_SCORE=$TOTAL_TASKS; fi

# 文件分 (满分 10)
if [ "$TOTAL_FILES" -ge 5 ]; then FILE_SCORE=10; else FILE_SCORE=$((TOTAL_FILES * 2)); fi

# Commits 分 (满分 10)
if [ "$COMMITS_TODAY" -ge 3 ]; then COMMIT_SCORE=10; else COMMIT_SCORE=$((COMMITS_TODAY * 3)); fi

# 健康分 (满分 10)
HEALTH_SCORE=10
if [ "$GATEWAY_OK" != "200" ]; then HEALTH_SCORE=$((HEALTH_SCORE - 3)); fi
if [ "$DISK_USAGE" -gt 80 ]; then HEALTH_SCORE=$((HEALTH_SCORE - 2)); fi
if [ "$MEM_USAGE" -gt 80 ]; then HEALTH_SCORE=$((HEALTH_SCORE - 2)); fi

# 总进化指数 (使用 awk 代替 bc)
EVOLUTION_SCORE=$(awk "BEGIN {printf \"%.2f\", ($TASK_SCORE * 0.3) + ($FILE_SCORE * 0.3) + ($COMMIT_SCORE * 0.2) + ($HEALTH_SCORE * 0.2)}")

echo ""
echo "任务分：$TASK_SCORE/10 (权重 30%)"
echo "文件分：$FILE_SCORE/10 (权重 30%)"
echo "Commits 分：$COMMIT_SCORE/10 (权重 20%)"
echo "健康分：$HEALTH_SCORE/10 (权重 20%)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 今日进化指数：$EVOLUTION_SCORE/10.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# =============================================================================
# 生成 Markdown 报告
# =============================================================================

cat > "$REPORT_FILE" << EOF
# 🧬 技能进化日报 ($DATE)

**生成时间**: $TIMESTAMP

---

## 📊 今日概览

| 指标 | 数值 | 状态 |
|------|------|------|
| 任务执行 | $TOTAL_TASKS 次 | $([ $TOTAL_TASKS -ge 5 ] && echo "✅" || echo "⚠️") |
| 新文件 | $TOTAL_FILES 个 | $([ $TOTAL_FILES -ge 3 ] && echo "✅" || echo "⚠️") |
| Git Commits | $COMMITS_TODAY 个 | $([ $COMMITS_TODAY -ge 1 ] && echo "✅" || echo "⚠️") |
| 系统健康 | - | $([ "$GATEWAY_OK" = "200" ] && [ "$DISK_USAGE" -lt 80 ] && [ "$MEM_USAGE" -lt 80 ] && echo "✅" || echo "⚠️") |

---

## 1️⃣ 今日任务执行

| 任务类型 | 执行次数 |
|----------|----------|
| 系统备份 | $TASKS_BACKUP |
| 工作日志 | $TASKS_WORKLOG |
| AI 新闻 | $TASKS_NEWS |
| 健康检查 | $TASKS_HEALTH |
| Gateway 自愈 | $TASKS_HEAL |
| **总计** | **$TOTAL_TASKS** |

---

## 2️⃣ 新技能/工具

| 类型 | 数量 |
|------|------|
| Shell 脚本 | $NEW_SCRIPTS |
| Python 脚本 | $NEW_PYTHON |
| 文档 | $NEW_MARKDOWN |
| **总计** | **$TOTAL_FILES** |

EOF

# 添加新文件列表
if [ $TOTAL_FILES -gt 0 ]; then
    echo "" >> "$REPORT_FILE"
    echo "**新增文件:**" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
    find /root/.openclaw/workspace -type f \( -name "*.sh" -o -name "*.py" -o -name "*.md" \) -mtime -1 2>/dev/null | head -20 | while read file; do
        echo "• $(basename $file)" >> "$REPORT_FILE"
    done
    echo '```' >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

---

## 3️⃣ 代码提交

| 时间范围 | Commits 数量 |
|----------|-------------|
| 今日 | $COMMITS_TODAY |
| 本周 | $COMMITS_WEEK |
| 总计 | $TOTAL_COMMITS |

EOF

# 添加今日 commits 列表
if [ $COMMITS_TODAY -gt 0 ]; then
    echo "" >> "$REPORT_FILE"
    echo "**今日 Commits:**" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
    cd "$WORKSPACE" && git log --since "today" --oneline 2>/dev/null >> "$REPORT_FILE" || echo "无" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

---

## 4️⃣ 技能活动

| 技能 | 使用次数 |
|------|----------|
| Browser | $BROWSER_USAGE |
| Web Search | $SEARCH_USAGE |
| Exec | $EXEC_USAGE |

---

## 5️⃣ 系统健康

| 组件 | 状态 | 详情 |
|------|------|------|
| Gateway | $([ "$GATEWAY_OK" = "200" ] && echo "✅" || echo "❌") | HTTP $GATEWAY_OK |
| 磁盘 | $([ "$DISK_USAGE" -lt 80 ] && echo "✅" || echo "⚠️") | ${DISK_USAGE}% |
| 内存 | $([ "$MEM_USAGE" -lt 80 ] && echo "✅" || echo "⚠️") | ${MEM_USAGE}% |

---

## 📈 进化指数详情

### 评分 breakdown

| 维度 | 得分 | 权重 | 加权分 |
|------|------|------|--------|
| 任务执行 | $TASK_SCORE/10 | 30% | $(echo "scale=2; $TASK_SCORE * 0.3" | bc) |
| 文件创建 | $FILE_SCORE/10 | 30% | $(echo "scale=2; $FILE_SCORE * 0.3" | bc) |
| 代码提交 | $COMMIT_SCORE/10 | 20% | $(echo "scale=2; $COMMIT_SCORE * 0.2" | bc) |
| 系统健康 | $HEALTH_SCORE/10 | 20% | $(echo "scale=2; $HEALTH_SCORE * 0.2" | bc) |

### 🎯 今日进化指数：**$EVOLUTION_SCORE/10.0**

EOF

# 添加建议
if (( $(echo "$EVOLUTION_SCORE >= 8" | bc -l) )); then
    echo "**评价**: 🌟 优秀！今日成长显著" >> "$REPORT_FILE"
elif (( $(echo "$EVOLUTION_SCORE >= 6" | bc -l) )); then
    echo "**评价**: ✅ 良好！保持稳定成长" >> "$REPORT_FILE"
elif (( $(echo "$EVOLUTION_SCORE >= 4" | bc -l) )); then
    echo "**评价**: ⚠️ 一般！建议增加实践" >> "$REPORT_FILE"
else
    echo "**评价**: 🔴 需要加油！建议多实践技能" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

---

## 💡 明日建议

EOF

# 根据今日情况生成建议
if [ $TOTAL_TASKS -lt 5 ]; then
    echo "- ⏰ 增加定时任务执行频率" >> "$REPORT_FILE"
fi
if [ $TOTAL_FILES -lt 3 ]; then
    echo "- 📝 创建更多脚本或文档" >> "$REPORT_FILE"
fi
if [ $COMMITS_TODAY -lt 1 ]; then
    echo "- 💾 记得提交 Git commits" >> "$REPORT_FILE"
fi
if [ "$GATEWAY_OK" != "200" ]; then
    echo "- 🔧 检查 Gateway 状态" >> "$REPORT_FILE"
fi

# 如果没有建议
if [ $TOTAL_TASKS -ge 5 ] && [ $TOTAL_FILES -ge 3 ] && [ $COMMITS_TODAY -ge 1 ] && [ "$GATEWAY_OK" = "200" ]; then
    echo "- ✅ 继续保持！当前状态优秀" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

---

*报告生成于 $TIMESTAMP*
*下次追踪：明日同一时间*
EOF

echo ""
echo "=========================================="
echo "📄 报告已保存：$REPORT_FILE"
echo "=========================================="

# 如果启用了详细模式，显示报告内容
if [ "$VERBOSE" = true ]; then
    echo ""
    echo "📋 报告内容预览:"
    echo "=========================================="
    cat "$REPORT_FILE"
fi
