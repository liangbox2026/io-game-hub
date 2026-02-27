# 🛠️ 智能信息抓取工具

_基于 jina.ai Reader 的增强抓取方案_

---

## 📦 核心函数

### Python 版本

```python
#!/usr/bin/env python3
"""
smart_fetch.py - 智能网页抓取工具
优先使用 jina.ai，失败后回退到直接抓取
"""

import urllib.request
import ssl
import time

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
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Accept": "text/html,application/xhtml+xml,application/json",
    }
    
    urls_to_try = []
    
    if use_jina:
        urls_to_try.append(f"https://r.jina.ai/{url}")
    urls_to_try.append(url)  # 直接抓取作为回退
    
    for i, fetch_url in enumerate(urls_to_try):
        for attempt in range(retries):
            try:
                print(f"尝试 {i+1}.{attempt+1}: {fetch_url[:60]}...")
                req = urllib.request.Request(fetch_url, headers=headers)
                with urllib.request.urlopen(req, context=ctx, timeout=15) as response:
                    content = response.read().decode('utf-8')
                    
                    # 检查是否被限流
                    if "429" in content or "Too Many Requests" in content:
                        print(f"  ⚠️  被限流，等待后重试...")
                        time.sleep(5 * (attempt + 1))
                        continue
                    
                    # 检查是否成功
                    if len(content) > 100:
                        print(f"  ✅ 成功，内容长度：{len(content)}")
                        return content
                        
            except Exception as e:
                print(f"  ❌ 错误：{e}")
                if attempt < retries - 1:
                    time.sleep(3)
    
    print("所有尝试都失败了")
    return None


# 使用示例
if __name__ == "__main__":
    # 示例 1：抓取普通网页
    content = smart_fetch("https://example.com")
    
    # 示例 2：抓取 Google Trends
    content = smart_fetch("https://trends.google.com/trends/trendingsearches/daily?geo=US")
    
    # 示例 3：绕过付费墙
    content = smart_fetch("https://every.to/p/some-article")
```

---

### Bash 版本

```bash
#!/bin/bash
# smart-fetch.sh - 命令行智能抓取工具

smart_fetch() {
    local url=$1
    local jina_url="https://r.jina.ai/${url}"
    
    echo "尝试 jina.ai 抓取..."
    local content=$(curl -s -A "Mozilla/5.0" "$jina_url" 2>&1)
    
    # 检查是否成功
    if [ $? -eq 0 ] && [ ${#content} -gt 100 ]; then
        if [[ "$content" != *"429"* ]] && [[ "$content" != *"Too Many Requests"* ]]; then
            echo "$content"
            return 0
        fi
    fi
    
    echo "jina.ai 失败，尝试直接抓取..."
    content=$(curl -s -A "Mozilla/5.0" "$url" 2>&1)
    
    if [ $? -eq 0 ] && [ ${#content} -gt 100 ]; then
        echo "$content"
        return 0
    fi
    
    echo "抓取失败"
    return 1
}

# 使用示例
# ./smart-fetch.sh "https://example.com"
# ./smart-fetch.sh "https://trends.google.com/..."
```

---

## 🎯 使用场景

| 场景 | 推荐配置 | 说明 |
|------|----------|------|
| 普通网页 | `use_jina=True` | 优先 jina.ai，返回干净 Markdown |
| 付费墙内容 | `use_jina=True` | jina.ai 可绕过大部分付费墙 |
| API 接口 | `use_jina=False` | 直接抓取，避免 jina.ai 转换 |
| 图片/视频 | `use_jina=False` | jina.ai 只提取文本 |
| 需要登录 | browser 工具 | jina.ai 无法处理登录 |

---

## 📊 对比测试

| 网站 | web_fetch | jina.ai | 结果 |
|------|-----------|---------|------|
| 普通博客 | ✅ | ✅ | jina.ai 更干净 |
| 新闻网站 | ⚠️ 可能有广告 | ✅ 干净 | jina.ai 胜 |
| 付费文章 | ❌ 被挡 | ✅ 绕过 | jina.ai 胜 |
| Google Trends | ⚠️ 429 限流 | ⚠️ 部分数据 | 平手 |
| GitHub | ✅ | ✅ | 平手 |

---

## 🔧 集成到 OpenClaw

在技能或脚本中使用：

```python
from smart_fetch import smart_fetch

# 在 AI 新闻抓取中使用
def fetch_ai_news():
    urls = [
        "https://www.theverge.com/ai",
        "https://techcrunch.com/category/artificial-intelligence/",
        # ...
    ]
    
    for url in urls:
        content = smart_fetch(url)
        if content:
            # 处理内容...
            pass
```

---

## 💡 最佳实践

1. **优先 jina.ai** - 返回干净 Markdown，绕过付费墙
2. **设置重试** - 网络请求可能失败，重试 2-3 次
3. **指数退避** - 被限流时，每次重试等待时间翻倍
4. **记录日志** - 记录抓取成功/失败，便于调试
5. **缓存结果** - 相同 URL 不要重复抓取

---

_创建时间：2026-02-25_
