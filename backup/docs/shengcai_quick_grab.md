# 🦞 生财有术 OpenClaw 帖子 - 快速抓取指南

**现状**: 生财有术需要登录才能查看内容  
**解决方案**: 人工登录 + 自动抓取

---

## 🎯 3 步完成抓取

### 步骤 1: 登录并搜索

1. 打开浏览器
2. 访问 https://scys.com/
3. 登录你的账号
4. 搜索 `OpenClaw` 或 `小龙虾`

### 步骤 2: 复制帖子链接

在每个相关帖子上:
- 右键点击帖子标题
- 选择"复制链接地址"
- 类似：`https://scys.com/t/12345`

### 步骤 3: 执行抓取命令

```bash
cd /root/.openclaw/workspace

# 对每个帖子执行
./backup/scripts/shengcai_auto_grab.sh https://scys.com/t/帖子 ID

# 示例
./backup/scripts/shengcai_auto_grab.sh https://scys.com/t/12345
./backup/scripts/shengcai_auto_grab.sh https://scys.com/t/67890
```

---

## 📋 批量抓取模板

```bash
#!/bin/bash
# 批量抓取生财有术 OpenClaw 帖子

POSTS=(
    "https://scys.com/t/帖子 ID1"
    "https://scys.com/t/帖子 ID2"
    "https://scys.com/t/帖子 ID3"
)

for i in "${!POSTS[@]}"; do
    echo "抓取第 $((i+1)) 个帖子..."
    /root/.openclaw/workspace/backup/scripts/shengcai_auto_grab.sh "${POSTS[$i]}"
    sleep 3  # 避免触发反爬虫
done

echo "✅ 全部完成!"
```

---

## 📁 输出位置

```
/root/.openclaw/workspace/backup/outputs/shengcai/
├── openclaw_134521.md
├── openclaw_134532.md
└── openclaw_134545.md
```

---

## ⚠️ 注意事项

1. **登录后才能抓取** - 未登录只能看到登录页
2. **每次抓取间隔 3-5 秒** - 避免触发反爬虫
3. **不要高频请求** - 建议每小时最多 10-20 次

---

**现在请:**
1. 登录生财有术
2. 搜索 OpenClaw
3. 复制 3-5 个相关帖子链接
4. 执行上面的抓取命令

**完成后告诉我，我帮你整理内容！** 📚
