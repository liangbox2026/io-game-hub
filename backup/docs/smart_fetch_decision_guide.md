# 🧠 智能抓取决策树 - 使用指南

_自动判断最优抓取方式 (L0-L3)_

---

## 🎯 快速开始

```bash
# 仅分析 (不执行)
./backup/scripts/smart_fetch_decision.sh <URL>

# 分析并执行抓取
./backup/scripts/smart_fetch_decision.sh <URL> --execute

# 指定输出文件
./backup/scripts/smart_fetch_decision.sh <URL> --execute --output=my_article.md
```

---

## 📊 决策规则

### L0 - web_fetch (静态页面)

**适用：**
- 公开博客文章
- 新闻网站
- 文档页面

**检测条件：**
- ❌ 不需要登录
- ❌ 不是付费内容
- ❌ 不需要 JS 渲染
- ❌ 不包含图片

**示例：**
```bash
./smart_fetch_decision.sh https://example.com/blog/post --execute
```

---

### L1 - jina.ai Reader (付费内容)

**适用：**
- Medium 文章
- Every.to Newsletter
- Substack 付费内容
- 部分新闻网站

**检测条件：**
- ❌ 不需要登录
- ✅ 是付费内容
- ❌ 不需要 JS

**示例：**
```bash
./smart_fetch_decision.sh https://medium.com/some-article --execute
```

---

### L2 - Browser 无头模式 (动态页面)

**适用：**
- GitHub Trending
- Twitter/X
- Reddit
- 单页应用 (SPA)

**检测条件：**
- ❌ 不需要登录
- ❌ 不是付费内容
- ✅ 需要 JS 渲染

**示例：**
```bash
./smart_fetch_decision.sh https://github.com/trending --execute
```

---

### L3 - Browser + 登录/视觉 (复杂场景)

**适用：**
- 需要登录的会员网站
- 图片/图表内容
- Instagram、Pinterest

**检测条件：**
- ✅ 需要登录
- 或 ✅ 包含图片

**示例：**
```bash
./smart_fetch_decision.sh https://scys.com/t/12345 --execute
# 会提示需要人工协助
```

---

## 🔍 检测逻辑

```
开始
  │
  ▼
包含图片/图表？
  ├─ 是 → L3 (截图 + 视觉识别)
  └─ 否
       │
       ▼
需要登录？
  ├─ 是 → L3 (Browser + 登录)
  └─ 否
       │
       ▼
是付费内容？
  ├─ 是 → L1 (jina.ai)
  └─ 否
       │
       ▼
需要 JS 渲染？
  ├─ 是 → L2 (Browser 无头)
  └─ 否 → L0 (web_fetch)
```

---

## 📋 输出示例

### 仅分析模式

```bash
$ ./smart_fetch_decision.sh https://github.com/trending

╔═══════════════════════════════════════════╗
║     智能抓取决策树 - Smart Fetch          ║
╚═══════════════════════════════════════════╝

🔍 分析目标 URL...
URL: https://github.com/trending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 决策结果:
  推荐层级：L2 - Browser 无头模式
  原因：需要 JS 渲染

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 提示:
  添加 --execute 参数执行抓取
```

### 执行模式

```bash
$ ./smart_fetch_decision.sh https://example.com/article --execute

╔═══════════════════════════════════════════╗
║     智能抓取决策树 - Smart Fetch          ║
╚═══════════════════════════════════════════╝

🔍 分析目标 URL...
URL: https://example.com/article

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 决策结果:
  推荐层级：L0 - web_fetch
  原因：静态页面，最快最轻量

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 执行抓取...
使用 L0 - web_fetch
✅ web_fetch 完成
✅ 抓取成功！
📄 输出文件：/root/.openclaw/workspace/backup/outputs/fetch_195528.md
📊 内容大小：15234 字符
```

---

## 📁 输出位置

```
/root/.openclaw/workspace/backup/outputs/
├── fetch_195528.md
├── fetch_195612.md
└── ...
```

---

## 📊 历史记录

```bash
# 查看抓取历史
cat /root/.openclaw/workspace/backup/logs/smart_fetch_history_$(date +%Y-%m-%d).txt
```

**格式：**
```
智能抓取记录
============
时间：2026-02-27 19:55:28
URL: https://example.com/article
决策：L0 - web_fetch
原因：静态页面，最快最轻量
输出：/root/.openclaw/workspace/backup/outputs/fetch_195528.md
状态：成功
```

---

## 🛠️ 自定义检测规则

编辑脚本中的检测函数：

```bash
# 添加新的付费网站
is_paywalled() {
    local url="$1"
    if echo "$url" | grep -qiE "(medium\.com|wsj\.com|你的网站\.com)"; then
        return 0
    fi
    return 1
}

# 添加新的 JS 网站
needs_js() {
    local url="$1"
    if echo "$url" | grep -qiE "(github\.com|twitter\.com|你的网站\.com)"; then
        return 0
    fi
    return 1
}
```

---

## ⚠️ 注意事项

1. **L3 需要人工协助** - 需要登录的网站无法完全自动化
2. **频率限制** - 添加延迟避免触发反爬虫
3. **browser 工具** - L2/L3 需要 browser 工具可用

---

## 📚 相关资源

- [智能抓取指南](./smart_fetch_guide.md)
- [人工接管浏览器](./manual_browser_guide.md)
- [生财有术爬取](./shengcai_scraper_guide.md)

---

_创建时间：2026-02-27_
_版本：1.0_
