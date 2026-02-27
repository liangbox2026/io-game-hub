# Smart Fetch Pattern 智能抓取模式

_优先 jina.ai，失败回退的稳健抓取策略_

**类型**: 抓取模式  
**复用次数**: 3+  
**相关**: [[web_scraping]], [[browser_automation]]

---

## 📦 核心思想

```
优先使用 jina.ai Reader (绕过付费墙 + 干净 Markdown)
       ↓
   失败/限流？
       ↓
回退到直接抓取 (web_fetch / curl)
```

---

## 🎯 使用场景

| 场景 | 推荐配置 | 说明 |
|------|----------|------|
| 普通网页 | `use_jina=True` | 优先 jina.ai |
| 付费文章 | `use_jina=True` | 绕过付费墙 |
| API 接口 | `use_jina=False` | 直接抓取 |
| 图片/视频 | `use_jina=False` | jina.ai 只提取文本 |

---

## 💻 实现代码

### Python 版本

```python
def smart_fetch(url, use_jina=True, retries=2):
    """
    智能抓取网页内容
    
    Args:
        url: 目标网址
        use_jina: 是否优先使用 jina.ai
        retries: 重试次数
    
    Returns:
        抓取到的内容，失败返回 None
    """
    urls_to_try = []
    
    if use_jina:
        urls_to_try.append(f"https://r.jina.ai/{url}")
    urls_to_try.append(url)  # 直接抓取作为回退
    
    for fetch_url in urls_to_try:
        for attempt in range(retries):
            try:
                content = fetch(fetch_url)
                
                # 检查是否被限流
                if "429" in content:
                    time.sleep(5 * (attempt + 1))
                    continue
                
                # 检查是否成功
                if len(content) > 100:
                    return content
                    
            except Exception as e:
                if attempt < retries - 1:
                    time.sleep(3)
    
    return None
```

### Bash 版本

```bash
smart_fetch() {
    local url=$1
    local jina_url="https://r.jina.ai/${url}"
    
    # 尝试 jina.ai
    local content=$(curl -s -A "Mozilla/5.0" "$jina_url")
    if [ ${#content} -gt 100 ] && [[ "$content" != *"429"* ]]; then
        echo "$content"
        return 0
    fi
    
    # 回退到直接抓取
    content=$(curl -s -A "Mozilla/5.0" "$url")
    if [ ${#content} -gt 100 ]; then
        echo "$content"
        return 0
    fi
    
    echo "抓取失败"
    return 1
}
```

---

## 📊 对比测试

| 网站 | web_fetch | jina.ai | 结果 |
|------|-----------|---------|------|
| 普通博客 | ✅ | ✅ | jina.ai 更干净 |
| 新闻网站 | ⚠️ 有广告 | ✅ 干净 | jina.ai 胜 |
| 付费文章 | ❌ 被挡 | ✅ 绕过 | jina.ai 胜 |
| Google Trends | ⚠️ 429 限流 | ⚠️ 部分数据 | 平手 |
| GitHub | ✅ | ✅ | 平手 |

---

## ⚠️ 注意事项

### 1. 限流处理

jina.ai 也有限流，建议：
- 增加请求间隔 (5-10 秒)
- 使用指数退避
- 必要时换 IP

### 2. 内容验证

抓取后验证内容有效性：
```python
if not content or len(content) < 100:
    return None
if "429" in content or "Too Many Requests" in content:
    return None
```

### 3. 错误处理

始终准备回退方案：
```python
try:
    content = fetch_jina(url)
except:
    content = fetch_direct(url)  # 回退
```

---

## 🔗 相关资源

- [[web_scraping]] - 网页抓取基础
- [[browser_automation]] - 浏览器自动化
- [[keyword_validation]] - 关键词验证实战

---

_创建时间：2026-02-25_
_复用次数：3+_
_作者：OpenClaw Agent_
