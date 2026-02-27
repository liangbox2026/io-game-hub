#!/usr/bin/env python3
"""
Google Trends 数据抓取测试脚本
"""

import urllib.request
import urllib.parse
import json
import ssl

def fetch_trends(keyword="AI", geo="US"):
    """抓取 Google Trends 数据"""
    
    # 创建 SSL 上下文（忽略证书验证）
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    
    # 构建请求
    url = "https://trends.google.com/trends/api/explore"
    params = {
        "q": keyword,
        "geo": geo,
        "hl": "en-US"
    }
    
    full_url = f"{url}?{urllib.parse.urlencode(params)}"
    
    # 设置请求头
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Accept": "text/html,application/xhtml+xml,application/json",
        "Accept-Language": "en-US,en;q=0.9",
    }
    
    try:
        req = urllib.request.Request(full_url, headers=headers)
        with urllib.request.urlopen(req, context=ctx, timeout=10) as response:
            content = response.read().decode('utf-8')
            print(f"状态码：{response.status}")
            print(f"内容长度：{len(content)}")
            print(f"\n内容预览:\n{content[:2000]}")
            return content
    except Exception as e:
        print(f"错误：{e}")
        return None

def fetch_trending_daily():
    """抓取每日热门趋势"""
    
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    
    url = "https://trends.google.com/trends/trendingsearches/daily"
    
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Accept": "text/html,application/xhtml+xml",
    }
    
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, context=ctx, timeout=15) as response:
            content = response.read().decode('utf-8')
            print(f"\n=== 每日热门趋势 ===")
            print(f"状态码：{response.status}")
            print(f"内容长度：{len(content)}")
            print(f"内容预览:\n{content[:3000]}")
            return content
    except Exception as e:
        print(f"错误：{e}")
        return None

if __name__ == "__main__":
    print("=" * 60)
    print("Google Trends 数据抓取测试")
    print("=" * 60)
    
    print("\n1. 抓取关键词 'AI' 趋势...")
    fetch_trends("AI", "US")
    
    print("\n\n2. 抓取每日热门趋势...")
    fetch_trending_daily()
    
    print("\n\n测试完成!")
