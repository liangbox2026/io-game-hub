# 📖 智能抓取使用指南

_从 L0 到 L3 的完整抓取策略_

---

## 🎯 快速开始

```bash
# 最简单的方式
./smart_fetch_fallback.sh <URL>

# 示例
./smart_fetch_fetch.sh https://example.com/article
```

脚本会自动按顺序尝试：
1. **L0** - web_fetch (最快)
2. **L1** - jina.ai Reader (绕过付费墙)
3. **L2** - browser 无头模式 (动态渲染)
4. **L3** - browser 有头模式 + 登录 (需要人工)

---

## 📊 各层级对比

| 层级 | 工具 | 速度 | 付费墙 | 登录 | JS 渲染 | 最佳场景 |
|------|------|------|--------|------|--------|----------|
| **L0** | web_fetch | ⚡⚡⚡ | ❌ | ❌ | ❌ | 静态页面、博客文章 |
| **L1** | jina.ai | ⚡⚡ | ✅ | ❌ | ❌ | 付费 Newsletter、Medium |
| **L2** | browser | ⚡ | ❌ | ❌ | ✅ | 动态渲染页面 |
| **L3** | browser+login | 🐌 | ✅ | ✅ | ✅ | 需要登录的付费内容 |

---

## 🔧 手动使用各层级

### L0: web_fetch (默认)

```bash
web_fetch --url="https://example.com" --maxChars=8000
```

**适用：**
- ✅ 公开博客文章
- ✅ 新闻网站
- ✅ 文档页面

**不适用：**
- ❌ 需要登录的内容
- ❌ 付费墙内容
- ❌ 大量 JS 渲染的页面

---

### L1: jina.ai Reader (付费墙绕过)

```bash
# 直接在 URL 前加前缀
curl https://r.jina.ai/https://example.com/paywalled-article

# 或在脚本中使用
JINA_URL="https://r.jina.ai/$TARGET_URL"
curl "$JINA_URL"
```

**适用：**
- ✅ Every.to (付费 Newsletter)
- ✅ Medium (部分文章)
- ✅ 部分新闻网站

**实测有效网站：**
- Every.to
- Medium
- Substack (部分)
- 部分学术网站

---

### L2: Browser 无头模式

```bash
# 需要 browser 工具
browser --action=open --url="https://example.com"
browser --action=snapshot
```

**适用：**
- ✅ 需要 JS 渲染的页面
- ✅ 单页应用 (SPA)
- ✅ 动态加载内容

**前提：**
- 需要安装 Chrome/Chromium
- 需要配置 browser 工具

---

### L3: Browser 有头模式 + 登录

```bash
# 1. 打开登录页面
browser --action=open --url="https://example.com/login"

# 2. 输入账号密码
browser --action=type --ref="username" --text="your_username"
browser --action=type --ref="password" --text="your_password"

# 3. 点击登录
browser --action=click --ref="login_button"

# 4. 等待并抓取
browser --action=wait --timeMs=3000
browser --action=snapshot
```

**⚠️ 安全警告：**
- 不要提供银行、邮箱等重要账号
- 使用专用账号而非主账号
- 定期更换密码

**适用：**
- ✅ 付费订阅内容 (WSJ、NYT 等)
- ✅ 需要会员的内容
- ✅ 内部系统/后台

---

## 🎯 决策树

```
开始
  │
  ▼
需要抓取图片/图表？
  ├─ 是 → L3 (截图 + 视觉识别)
  └─ 否
       │
       ▼
需要登录？
  ├─ 是 → L3 (browser + 登录)
  └─ 否
       │
       ▼
需要 JS 渲染？
  ├─ 是 → L2 (无头浏览器)
  └─ 否
       │
       ▼
是付费内容？
  ├─ 是 → L1 (jina.ai)
  └─ 否 → L0 (web_fetch)
```

---

## 📋 实战示例

### 示例 1: 抓取普通博客

```bash
# L0 就够
./smart_fetch_fallback.sh https://blog.example.com/article
```

### 示例 2: 抓取付费 Newsletter

```bash
# L1 jina.ai
./smart_fetch_fallback.sh https://every.to/p/some-article
```

### 示例 3: 抓取 GitHub Trending

```bash
# L0 足够 (静态页面)
./smart_fetch_fallback.sh https://github.com/trending
```

### 示例 4: 抓取需要登录的内容

```bash
# 需要 L3，人工介入
# 1. 脚本会提示需要登录
# 2. 人工打开浏览器登录
# 3. 或使用保存的 Cookie
```

---

## 💡 最佳实践

### ✅ 推荐

1. **优先用 L0** - 最快，资源消耗最少
2. **L1 作为 fallback** - jina.ai 能绕过大部分付费墙
3. **添加延迟** - 避免触发反爬虫
4. **缓存结果** - 避免重复抓取
5. **记录日志** - 方便调试和追踪

### ❌ 避免

1. ❌ 所有页面都用 browser (慢)
2. ❌ 不添加延迟 (触发限流)
3. ❌ 硬编码账号密码 (安全风险)
4. ❌ 不处理错误 (任务中断)
5. ❌ 不缓存结果 (浪费资源)

---

## 🔒 安全提示

### 账号安全

- ⚠️ 不要提供银行、邮箱、社交媒体主账号
- ✅ 使用专用账号
- ✅ 定期更换密码
- ✅ 启用双因素认证

### 数据安全

- ⚠️ 抓取的付费内容不要公开分享
- ⚠️ 遵守网站服务条款
- ⚠️ 不要用于商业用途

---

## 📊 性能对比

| 方法 | 平均耗时 | 成功率 | 资源消耗 |
|------|---------|--------|---------|
| L0 | <1s | 60% | 低 |
| L1 | 2-5s | 80% | 低 |
| L2 | 5-15s | 90% | 中 |
| L3 | 15-60s | 95% | 高 |

---

## 🛠️ 故障排查

### 问题：所有方法都失败

**可能原因：**
1. URL 错误或网站下线
2. 网站有严格反爬虫
3. 需要验证码
4. IP 被封禁

**解决方案：**
1. 手动打开 URL 确认网站正常
2. 尝试更换 User-Agent
3. 使用代理 IP
4. 联系网站管理员

### 问题：jina.ai 也失败

**可能原因：**
1. 网站屏蔽了 jina.ai
2. 内容需要登录
3. 网站使用了强加密

**解决方案：**
1. 尝试 L2/L3
2. 寻找替代来源
3. 人工处理

---

## 📚 相关资源

- [jina.ai Reader](https://jina.ai/reader)
- [OpenClaw Browser 工具](https://docs.openclaw.ai/browser)
- [Web Scraping 最佳实践](../knowledge_base/skills/web_scraping.md)

---

_最后更新：2026-02-27_
