#!/bin/bash
# 系统备份脚本
DATE=$(date +%Y-%m-%d)
BACKUP_DIR="/root/.openclaw/backups/$DATE"

mkdir -p $BACKUP_DIR

# 备份工作区
cp -r /root/.openclaw/workspace $BACKUP_DIR/

# 备份重要配置
cp /root/.openclaw/config.json $BACKUP_DIR/ 2>/dev/null || echo "No config.json found"

# 清理7天前的备份
find /root/.openclaw/backups -type d -mtime +7 -exec rm -rf {} + 2>/dev/null

echo "Backup completed for $DATE"