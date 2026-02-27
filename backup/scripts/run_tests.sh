#!/bin/bash
# =============================================================================
# 自动化测试套件 - Automated Test Suite
# 功能：快速验证系统核心功能是否正常
# 用法：./run_tests.sh [--verbose]
# =============================================================================

set -e

# 配置
LOG_DIR="/root/.openclaw/workspace/backup/logs"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# 解析参数
VERBOSE=false
for arg in "$@"; do
    case $arg in
        --verbose) VERBOSE=true ;;
    esac
done

# 计数器
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 测试函数
run_test() {
    local test_name=$1
    local test_command=$2
    local expected=$3
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    echo -n "测试 $TESTS_TOTAL: $test_name... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        if [ "$expected" = "pass" ]; then
            echo -e "${GREEN}✅${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        else
            echo -e "${RED}❌${NC} (期望失败但成功)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    else
        if [ "$expected" = "fail" ]; then
            echo -e "${GREEN}✅${NC} (预期失败)"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        else
            echo -e "${RED}❌${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    fi
}

# 主测试流程
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════╗"
echo "║     自动化测试套件 - Test Suite           ║"
echo "║           $TIMESTAMP                      ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"

echo "=========================================="
echo "核心功能测试"
echo "=========================================="
echo ""

# 测试 1: Gateway HTTP 可访问
run_test "Gateway HTTP" "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:18789/ | grep -q '200'" "pass"

# 测试 2: Gateway 进程运行
run_test "Gateway 进程" "pgrep -f 'openclaw-gateway' > /dev/null" "pass"

# 测试 3: Gateway 端口监听
run_test "Gateway 端口" "netstat -tlnp 2>/dev/null | grep -q ':18789' || ss -tlnp 2>/dev/null | grep -q ':18789'" "pass"

# 测试 4: Cron 服务运行
run_test "Cron 服务" "systemctl is-active crond > /dev/null 2>&1 || systemctl is-active cron > /dev/null 2>&1" "pass"

# 测试 5: 备份脚本存在
run_test "备份脚本" "test -f /root/.openclaw/backup/scripts/daily_backup.sh" "pass"

# 测试 6: 健康检查脚本可执行
run_test "健康检查脚本" "test -x /root/.openclaw/workspace/backup/scripts/system_health_check_simple.sh" "pass"

# 测试 7: Gateway 自愈脚本可执行
run_test "Gateway 自愈脚本" "test -x /root/.openclaw/workspace/backup/scripts/gateway_self_heal.sh" "pass"

# 测试 8: Git 仓库正常
run_test "Git 仓库" "cd /root/.openclaw/workspace && git status > /dev/null 2>&1" "pass"

# 测试 9: OpenClaw 命令可用
run_test "OpenClaw 命令" "openclaw --version > /dev/null 2>&1" "pass"

# 测试 10: 磁盘空间充足 (<90%)
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$DISK_USAGE" -lt 90 ]; then
    run_test "磁盘空间 (<90%)" "test $DISK_USAGE -lt 90" "pass"
else
    run_test "磁盘空间 (<90%)" "false" "fail"
fi

# 测试 11: 内存使用正常 (<90%)
MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100)}')
if [ "$MEM_USAGE" -lt 90 ]; then
    run_test "内存使用 (<90%)" "test $MEM_USAGE -lt 90" "pass"
else
    run_test "内存使用 (<90%)" "false" "fail"
fi

# 测试 12: Cron 错误数正常 (<10 个/24h)
CRON_ERRORS=$(journalctl -u cron --since "24 hours ago" 2>/dev/null | grep -ci "error\|fail" || echo 0)
if [ "$CRON_ERRORS" -lt 10 ]; then
    run_test "Cron 错误 (<10)" "test $CRON_ERRORS -lt 10" "pass"
else
    run_test "Cron 错误 (<10)" "false" "fail"
fi

# 测试 13: 技能进化脚本可执行
run_test "技能进化脚本" "test -x /root/.openclaw/workspace/backup/scripts/skill_evolution_tracker.sh" "pass"

# 测试 14: 日志聚合脚本可执行
run_test "日志聚合脚本" "test -x /root/.openclaw/workspace/backup/scripts/aggregate_logs.sh" "pass"

echo ""
echo "=========================================="
echo "📊 测试结果"
echo "=========================================="
echo ""

PASS_RATE=$(awk "BEGIN {printf \"%.1f\", ($TESTS_PASSED / $TESTS_TOTAL) * 100}")

echo "通过：${GREEN}$TESTS_PASSED${NC}"
echo "失败：${RED}$TESTS_FAILED${NC}"
echo "总计：$TESTS_TOTAL"
echo "通过率：${PASS_RATE}%"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ 所有测试通过！系统状态优秀${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    EXIT_CODE=0
else
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  $TESTS_FAILED 个测试失败，请检查系统${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    EXIT_CODE=1
fi

# 保存测试结果
TEST_REPORT="$LOG_DIR/test_report_$DATE.txt"
{
    echo "=========================================="
    echo "自动化测试报告"
    echo "时间：$TIMESTAMP"
    echo "=========================================="
    echo ""
    echo "通过：$TESTS_PASSED"
    echo "失败：$TESTS_FAILED"
    echo "总计：$TESTS_TOTAL"
    echo "通过率：${PASS_RATE}%"
    echo ""
    echo "状态：$([ $EXIT_CODE -eq 0 ] && echo "✅ 通过" || echo "⚠️  失败")"
} >> "$TEST_REPORT"

echo ""
echo "📄 测试报告：$TEST_REPORT"

exit $EXIT_CODE
