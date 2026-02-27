#!/bin/bash
# OpenClaw Gateway 自检脚本
# 用法：./gateway-check.sh

echo "╔════════════════════════════════════════════════════════╗"
echo "║         OpenClaw Gateway 状态检查                      ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# 1. 服务状态
echo "📊 1. 服务状态"
echo "─────────────────────────────────────────────────────────"
systemctl --user status openclaw-gateway --no-pager | head -10
echo ""

# 2. Token 一致性检查
echo "🔑 2. Token 一致性检查"
echo "─────────────────────────────────────────────────────────"
SYSTEMD_TOKEN=$(grep OPENCLAW_GATEWAY_TOKEN /root/.config/systemd/user/openclaw-gateway.service 2>/dev/null | cut -d'=' -f2)
CONFIG_TOKEN=$(grep -A1 '"token"' /root/.openclaw/openclaw.json | grep token | cut -d'"' -f4)

echo "systemd: $SYSTEMD_TOKEN"
echo "config:  $CONFIG_TOKEN"

if [ "$SYSTEMD_TOKEN" = "$CONFIG_TOKEN" ]; then
    echo "✅ Token 一致"
else
    echo "❌ Token 不一致！需要修复"
    echo ""
    echo "修复命令:"
    echo "  1. 编辑 systemd 文件：nano /root/.config/systemd/user/openclaw-gateway.service"
    echo "  2. 更新 OPENCLAW_GATEWAY_TOKEN 与 config 一致"
    echo "  3. systemctl --user daemon-reload && restart openclaw-gateway"
fi
echo ""

# 3. 端口和连接检查
echo "🌐 3. 端口和连接检查"
echo "─────────────────────────────────────────────────────────"
curl -s http://127.0.0.1:18789/health > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Gateway 端口 18789 可访问"
    curl -s http://127.0.0.1:18789/health | head -3
else
    echo "❌ Gateway 端口不可访问"
fi
echo ""

# 4. 进程检查
echo "🔄 4. 进程检查"
echo "─────────────────────────────────────────────────────────"
ps aux | grep openclaw-gateway | grep -v grep
echo ""

# 5. 最近日志
echo "📋 5. 最近日志 (最后 5 条)"
echo "─────────────────────────────────────────────────────────"
journalctl --user -u openclaw-gateway --no-pager -n 5 | tail -5
echo ""

echo "╔════════════════════════════════════════════════════════╗"
echo "║  检查完成                                              ║"
echo "╚════════════════════════════════════════════════════════╝"
