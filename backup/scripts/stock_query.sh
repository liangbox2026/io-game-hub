#!/bin/bash
# =============================================================================
# 股票行情查询 - 飞书命令
# 用法：./stock_query.sh <股票代码>
# =============================================================================

set -e

SCRIPT_DIR="/root/.openclaw/workspace/backup/scripts"
PYTHON="/usr/bin/python3"

if [ $# -lt 1 ]; then
    echo "❌ 请提供股票代码"
    echo "用法：$0 <股票代码>"
    echo "示例：$0 002837"
    exit 1
fi

STOCK_CODE="$1"

echo "🔍 查询 $STOCK_CODE 实时行情..."
$PYTHON "$SCRIPT_DIR/stock_price_api.py" "$STOCK_CODE"
