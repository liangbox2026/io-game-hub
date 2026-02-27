# 🦞 人工接管浏览器爬取指南

_方案 3：人工登录 + 自动抓取_

---

## 🎯 使用场景

**适合：**
- ✅ 需要登录的付费网站
- ✅ 有验证码的网站
- ✅ 复杂交互的会员系统
- ✅ 偶尔爬取的网站

**不适合：**
- ❌ 需要高频自动化的场景
- ❌ 大规模批量爬取
- ❌ 完全自动化需求

---

## 📋 快速开始

### 步骤 1: 启动浏览器并登录

```bash
# 启动浏览器，打开目标网站
./manual_browser_assist.sh setup --url=https://example.com --name=example
```

**输出：**
```
╔═══════════════════════════════════════════╗
║     人工接管浏览器 - 登录阶段              ║
╚═══════════════════════════════════════════╝

📋 步骤说明:
1. 浏览器即将启动 (有头模式)
2. 请在浏览器中手动登录目标网站
3. 登录完成后，保持浏览器开启
4. 返回终端执行抓取命令

🌐 启动浏览器...
🔗 打开目标网站...

✅ 浏览器已启动!
```

### 步骤 2: 人工登录

1. 浏览器窗口会自动打开
2. 在浏览器中**手动登录**目标网站
3. 导航到要抓取的页面
4. **保持浏览器开启**，不要关闭

### 步骤 3: 抓取内容

```bash
# 抓取当前页面
./manual_browser_assist.sh grab --name=example --output=article1
```

**输出：**
```
╔═══════════════════════════════════════════╗
║     人工接管浏览器 - 抓取阶段              ║
╚═══════════════════════════════════════════╝

📊 抓取配置:
网站标识：example
输出文件：/root/.openclaw/workspace/backup/outputs/example_article1.md
时间：2026-02-27 13:45:00

📸 抓取页面内容...
✅ 抓取完成!

📄 输出文件：example_article1.md
📊 内容大小：15234 字符
```

---

## 🔧 完整命令参考

### setup - 启动浏览器

```bash
# 基本用法
./manual_browser_assist.sh setup --url=URL --name=NAME

# 示例
./manual_browser_assist.sh setup --url=https://wsj.com --name=wsj
```

| 选项 | 说明 |
|------|------|
| `--url=URL` | 目标网站 URL |
| `--name=NAME` | 网站标识名称 |

---

### grab - 抓取内容

```bash
# 基本用法
./manual_browser_assist.sh grab --name=NAME --output=FILENAME

# 完整页面截图
./manual_browser_assist.sh grab --name=NAME --full
```

| 选项 | 说明 |
|------|------|
| `--name=NAME` | 网站标识名称 |
| `--output=FILE` | 输出文件名 |
| `--full` | 完整页面截图 |

---

### cookies - 导出 Cookie

```bash
# 导出当前会话 Cookie
./manual_browser_assist.sh cookies --name=example
```

**输出位置：** `/root/.openclaw/credentials/cookies/example_YYYYMMDD.json`

---

### status - 检查状态

```bash
./manual_browser_assist.sh status
```

---

## 📊 工作流程图

```
开始
  │
  ▼
┌─────────────────┐
│ setup 命令       │
│ 启动浏览器       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 人工登录网站     │ ← 用户操作
│ 导航到目标页面   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ grab 命令        │
│ 自动抓取内容     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 保存 Markdown    │
│ (可选截图)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ cookies 命令     │
│ 导出 Cookie      │ ← 可选
└────────┬────────┘
         │
         ▼
完成
```

---

## 🛡️ 安全最佳实践

### 1. 凭证管理

```bash
# ✅ 推荐：使用专用账号
# 创建只读权限的子账号用于爬取

# ✅ 推荐：定期更换密码
# 每月更换一次爬取专用账号密码

# ❌ 避免：使用主账号
# 不要用你的主要邮箱/社交媒体账号
```

### 2. Cookie 安全

```bash
# Cookie 文件权限
chmod 600 /root/.openclaw/credentials/cookies/*.json

# 定期清理过期 Cookie
find /root/.openclaw/credentials/cookies -name "*.json" -mtime +30 -delete
```

### 3. 使用限制

```bash
# 添加延迟，避免触发反爬虫
sleep 5  # 每次抓取间隔至少 5 秒

# 限制频率
# 每小时最多 10-20 次请求
```

---

## 📁 输出文件结构

```
/root/.openclaw/workspace/backup/
├── outputs/
│   ├── example_article1.md      # 抓取的内容
│   ├── example_article1.png     # 页面截图 (可选)
│   └── wsj_news_20260227.md
├── logs/
│   ├── browser_setup_2026-02-27.log
│   ├── grab_history_2026-02-27.log
│   └── ...
└── scripts/
    └── manual_browser_assist.sh
```

---

## 🔍 故障排查

### 问题 1: 浏览器启动失败

**症状：**
```
❌ 浏览器未运行
```

**解决：**
```bash
# 1. 检查 browser 工具
openclaw browser status

# 2. 重启 browser 服务
openclaw browser stop
openclaw browser start

# 3. 检查 Chrome 是否安装
which google-chrome || which chromium
```

---

### 问题 2: 抓取内容为空

**症状：**
```
📊 内容大小：0 字符
```

**解决：**
```bash
# 1. 确认浏览器中已登录
# 2. 确认当前页面是目标页面
# 3. 尝试手动刷新页面
# 4. 使用 --full 截图查看实际情况
```

---

### 问题 3: Cookie 导出失败

**症状：**
```
🍪 Cookie 数量：0
```

**解决：**
```bash
# 1. 确认浏览器中已登录
# 2. 检查浏览器控制台是否有 Cookie
# 3. 某些网站使用 HttpOnly Cookie，无法通过 JS 获取
# 4. 改用浏览器扩展导出 Cookie
```

---

## 💡 进阶技巧

### 技巧 1: 批量抓取

```bash
#!/bin/bash
# batch_grab.sh

URLS=(
    "https://example.com/article1"
    "https://example.com/article2"
    "https://example.com/article3"
)

for i in "${!URLS[@]}"; do
    echo "抓取第 $((i+1)) 个页面..."
    
    # 导航到页面 (需要手动或自动化)
    openclaw browser navigate --url="${URLS[$i]}"
    
    # 等待人工确认 (或直接抓取)
    echo "按回车继续..."
    read
    
    # 抓取
    ./manual_browser_assist.sh grab --name=example --output=article_$i
    
    # 延迟
    sleep 5
done
```

---

### 技巧 2: 定时抓取

```bash
# Crontab 配置 (每天上午 10 点)
# 注意：需要人工登录，所以不适合完全自动化

# 更适合：提醒脚本
0 10 * * * echo "记得执行手动爬取！" | notify-send
```

---

### 技巧 3: 内容后处理

```bash
#!/bin/bash
# post_process.sh

INPUT_FILE="$1"

# 清理 Markdown
pandoc "$INPUT_FILE" -o "${INPUT_FILE%.md}.html"

# 提取关键信息
grep -E "^#|^\*\*" "$INPUT_FILE" > "${INPUT_FILE%.md}_summary.md"

# 转换为其他格式
pandoc "$INPUT_FILE" -o "${INPUT_FILE%.md}.pdf"
```

---

## 📚 相关资源

- [Browser 工具文档](https://docs.openclaw.ai/tools/browser)
- [Lobster 插件指南](../lobster_member_site_scraping.md)
- [智能抓取指南](../smart_fetch_guide.md)

---

## ⚠️ 法律提醒

1. **遵守服务条款** - 某些网站禁止自动化爬取
2. **尊重版权** - 付费内容不要公开分享
3. **合理使用** - 不要给目标网站造成过大负载
4. **数据隐私** - 不要爬取他人个人信息

---

_最后更新：2026-02-27_
_作者：OpenClaw Assistant_
