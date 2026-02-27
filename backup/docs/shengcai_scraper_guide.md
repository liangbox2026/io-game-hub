# 🦞 生财有术爬取指南

_使用人工接管方案爬取生财有术会员内容_

---

## 📋 网站信息

| 项目 | 详情 |
|------|------|
| **网站** | 生财有术 |
| **URL** | https://scys.com/ |
| **类型** | 会员制社区 |
| **需要登录** | ✅ 是 |
| **爬取难度** | ⭐⭐ (中等) |

---

## 🎯 快速开始

### 方式 1: 分步执行 (推荐)

```bash
# 步骤 1: 启动浏览器并登录
./shengcai_scraper.sh setup

# 步骤 2: 在浏览器中登录生财有术
# 步骤 3: 导航到要抓取的页面

# 步骤 4: 抓取内容
./shengcai_scraper.sh grab --output=精华帖_20260227
```

### 方式 2: 一键执行

```bash
# 完整流程 (包含等待时间)
./shengcai_scraper.sh all --output=每日话题_20260227
```

---

## 📊 推荐爬取内容

### 1. 每日话题

```bash
# 导航到 https://scys.com/topics
./shengcai_scraper.sh setup
# 人工登录后导航到话题页面
./shengcai_scraper.sh grab --output=daily_topics_$(date +%Y%m%d)
```

### 2. 精华帖

```bash
# 导航到 https://scys.com/essence
./shengcai_scraper.sh setup
# 人工登录后导航到精华页面
./shengcai_scraper.sh grab --output=essence_$(date +%Y%m%d)
```

### 3. 特定主题

```bash
# 导航到具体主题页面
./shengcai_scraper.sh setup
# 人工搜索并打开目标主题
./shengcai_scraper.sh grab --output=topic_$(date +%Y%m%d)
```

### 4. 批量抓取多个页面

```bash
#!/bin/bash
# batch_shengcai.sh

PAGES=(
    "https://scys.com/topics"
    "https://scys.com/essence"
    "https://scys.com/latest"
)

for i in "${!PAGES[@]}"; do
    echo "抓取第 $((i+1)) 个页面..."
    
    # 导航
    openclaw browser navigate --url="${PAGES[$i]}"
    
    # 等待
    sleep 3
    
    # 抓取
    ./shengcai_scraper.sh grab --output=page_$i
    
    # 延迟避免触发反爬虫
    sleep 5
done
```

---

## 🛡️ 注意事项

### 1. 账号安全

- ⚠️ **使用专用账号** - 不要用主账号
- ⚠️ **定期更换密码** - 建议每月更换
- ⚠️ **不要分享账号** - 遵守会员协议

### 2. 爬取频率

```bash
# ✅ 推荐频率
# - 每天 1-2 次
# - 每次间隔至少 1 小时
# - 单次抓取不超过 10 个页面

# ❌ 避免
# - 高频请求 (每分钟多次)
# - 大规模批量爬取
# - 整站爬取
```

### 3. 内容使用

- ⚠️ **仅供个人学习** - 不要公开分享
- ⚠️ **尊重版权** - 生财有术内容有版权
- ⚠️ **遵守会员协议** - 不要违反服务条款

---

## 📁 输出文件

```
/root/.openclaw/workspace/backup/outputs/shengcai/
├── daily_topics_20260227.md      # 每日话题
├── essence_20260227.md           # 精华帖
├── topic_20260227.md             # 特定主题
└── logs/
    └── shengcai_history_2026-02-27.txt
```

---

## 🔧 故障排查

### 问题 1: 登录后抓取内容为空

**原因：** Cookie 未正确传递

**解决：**
```bash
# 1. 确认已登录
# 2. 刷新页面确认内容显示
# 3. 重新执行 setup
./shengcai_scraper.sh setup
```

### 问题 2: 触发验证码

**原因：** 请求过于频繁

**解决：**
```bash
# 1. 降低频率
# 2. 增加延迟
sleep 10  # 每次抓取间隔 10 秒

# 3. 人工处理验证码后继续
```

### 问题 3: 浏览器启动失败

**解决：**
```bash
# 检查 browser 状态
openclaw browser status

# 重启 browser
openclaw browser stop
openclaw browser start
```

---

## 💡 进阶用法

### 1. 定期爬取 (半自动)

```bash
# Crontab 配置 - 每天早上 9 点提醒
0 9 * * * echo "记得爬取生财有术每日话题！" | notify-send
```

### 2. 内容整理

```bash
#!/bin/bash
# organize_shengcai.sh

OUTPUT_DIR="/root/.openclaw/workspace/backup/outputs/shengcai"

# 合并今日所有抓取
cat "$OUTPUT_DIR"/*.md > "$OUTPUT_DIR/merged_$(date +%Y%m%d).md"

# 提取标题
grep "^#" "$OUTPUT_DIR"/*.md > "$OUTPUT_DIR/titles_$(date +%Y%m%d).txt"
```

### 3. 内容分析

```bash
#!/bin/bash
# analyze_shengcai.sh

INPUT_FILE="$1"

# 统计字数
wc -c "$INPUT_FILE"

# 提取高频词
cat "$INPUT_FILE" | grep -oE "[a-zA-Z\u4e00-\u9fa5]{2,}" | sort | uniq -c | sort -rn | head -20
```

---

## 📚 相关资源

- [人工接管浏览器指南](./manual_browser_guide.md)
- [智能抓取指南](./smart_fetch_guide.md)
- [Lobster 爬取方案](./lobster_member_site_scraping.md)

---

## ⚠️ 法律提醒

1. **遵守会员协议** - 生财有术是付费会员制社区
2. **仅供个人学习** - 不要公开分享爬取内容
3. **尊重知识产权** - 内容版权归生财有术所有
4. **合理使用** - 不要给网站造成过大负载

---

_最后更新：2026-02-27_
_仅供学习交流使用_
