# Web Scraping 网页抓取

_从简单抓取到智能抓取的完整方案_

**等级**: L2 🟢  
**最后更新**: 2026-02-25  
**相关**: [[browser_automation]], [[smart_fetch_pattern]]

---

## 📦 核心概念

网页抓取分为 4 个层级，根据需求选择合适方案：

```
L0: web_search + web_fetch (80% 场景)
    └─ 适用：公开信息，无需登录
    
L1: 无头浏览器 (Headless Chrome)
    └─ 适用：需要 JS 渲染的页面
    
L2: 有头浏览器 + DOM 操作
    └─ 适用：登录、填表、点击交互
    
L3: 截图 + 视觉识别
    └─ 适用：图片/图表内容，兜底方案
```

---

## 🛠️ 工具对比

| 工具 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **web_fetch** | 快速、简单 | 无法处理 JS | 静态网页、API |
| **jina.ai** | 绕过付费墙、返回 Markdown | 依赖第三方 | 新闻、付费内容 |
| **browser** | 完整浏览器能力 | 需要配置 | 登录、交互 |
| **exec + curl** | 完全控制 | 复杂 | 特殊需求 |

---

## 💡 Smart Fetch 模式

**核心思想**: 优先 jina.ai，失败后回退到直接抓取

```python
def smart_fetch(url, use_jina=True):
    """智能抓取：优先 jina.ai，失败回退"""
    if use_jina:
        content = web_fetch(f"https://r.jina.ai/{url}")
        if content and "429" not in content:
            return content
    return web_fetch(url)  # 回退
```

**优势**:
- ✅ 自动绕过付费墙
- ✅ 返回干净 Markdown
- ✅ 有回退机制，更稳定

---

## 📋 操作步骤

### 1. 简单抓取 (L0)

```python
# 使用 web_fetch
content = web_fetch("https://example.com")
```

### 2. 智能抓取 (L0+)

```python
# 使用 jina.ai
content = web_fetch("https://r.jina.ai/https://example.com")
```

### 3. 浏览器抓取 (L1/L2)

```python
# 需要 browser 工具可用
browser(action="open", targetUrl="https://example.com")
browser(action="snapshot")  # 获取页面内容
```

---

## ⚠️ 常见问题

### 1. 429 Too Many Requests

**原因**: 请求过于频繁

**解决**:
- 增加请求间隔 (5-10 秒)
- 使用指数退避 (5s, 10s, 20s...)
- 换用 jina.ai (有限流但更宽松)

### 2. 403 Forbidden

**原因**: 被反爬虫拦截

**解决**:
- 使用 jina.ai 代理
- 添加 User-Agent 头
- 使用 browser 工具

### 3. 内容为空/不完整

**原因**: JS 渲染内容

**解决**:
- 升级到 L1 (无头浏览器)
- 等待页面加载 (browser wait 命令)
- 查找 API 接口直接调用

---

## 📚 相关资源

- [[smart_fetch_pattern]] - 智能抓取详细实现
- [[browser_automation]] - 浏览器自动化指南
- [[keyword_validation]] - 关键词验证实战

---

_创建时间：2026-02-25_
_作者：OpenClaw Agent_
