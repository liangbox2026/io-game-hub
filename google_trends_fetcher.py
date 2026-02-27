#!/usr/bin/env python3
"""
Google Trends 数据抓取脚本 v2
使用 jina.ai Reader + 重试机制

用法：python3 google_trends_fetcher.py [关键词] [地区]
"""

import urllib.request
import urllib.parse
import ssl
import time
import sys
from datetime import datetime

def fetch_jina(url, retries=3, delay=5):
    """使用 jina.ai Reader 抓取网页，带重试机制"""
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    
    jina_url = f"https://r.jina.ai/{url}"
    
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Accept": "text/plain",
    }
    
    for attempt in range(retries):
        try:
            print(f"  尝试 {attempt + 1}/{retries}...")
            req = urllib.request.Request(jina_url, headers=headers)
            with urllib.request.urlopen(req, context=ctx, timeout=30) as response:
                content = response.read().decode('utf-8')
                
                # 检查是否被限流
                if "429" in content or "Too Many Requests" in content:
                    print(f"  ⚠️  被限流，等待 {delay}s 后重试...")
                    time.sleep(delay)
                    delay *= 2  # 指数退避
                    continue
                
                return content
        except Exception as e:
            print(f"  错误：{e}")
            if attempt < retries - 1:
                print(f"  等待 {delay}s 后重试...")
                time.sleep(delay)
                delay *= 2
    
    return None

def parse_trending_content(content):
    """解析热门趋势内容"""
    if not content:
        return []
    
    lines = content.split('\n')
    trending = []
    
    # 跳过标题和导航内容
    skip_keywords = [
        'Title:', 'URL Source:', 'Markdown Content:', 
        'Trends', 'Home', 'Explore', 'Trending now',
        'United States', 'Past 24 hours', 'All categories',
        'Show active', '_maps_', '_location', '_search_',
        '_calendar', '_grid_', 'Trend location'
    ]
    
    for line in lines:
        line = line.strip()
        
        # 跳过空行和太短/太长的行
        if not line or len(line) < 3 or len(line) > 50:
            continue
        
        # 跳过包含特殊符号的行
        if any(kw in line for kw in skip_keywords):
            continue
        
        # 跳过链接
        if line.startswith(('http', '[', '*', '-', '=')):
            continue
        
        trending.append(line)
    
    # 去重
    seen = set()
    unique_trending = []
    for item in trending:
        if item.lower() not in seen:
            seen.add(item.lower())
            unique_trending.append(item)
    
    return unique_trending

def fetch_trending_daily(geo="US"):
    """抓取每日热门趋势"""
    print(f"\n📊 抓取每日热门趋势 ({geo})...")
    
    url = f"https://trends.google.com/trends/trendingsearches/daily?geo={geo}"
    content = fetch_jina(url, retries=3, delay=5)
    
    if content:
        trending = parse_trending_content(content)
        
        print(f"\n{'='*60}")
        print(f"🔥 Google Trends 热门趋势 TOP 20")
        print(f"地区：{geo} | 时间：{datetime.now().strftime('%Y-%m-%d %H:%M')}")
        print(f"{'='*60}\n")
        
        if trending:
            for i, trend in enumerate(trending[:20], 1):
                print(f"  {i:2d}. {trend}")
            print(f"\n共找到 {len(trending)} 个趋势词")
        else:
            print("  ⚠️  未找到有效趋势词，可能是页面结构变化")
        
        return trending
    else:
        print("  ❌ 抓取失败")
        return None

def fetch_keyword_trend(keyword="AI", geo="US"):
    """抓取特定关键词趋势"""
    print(f"\n📈 抓取关键词 '{keyword}' 趋势...")
    
    url = f"https://trends.google.com/trends/explore?q={urllib.parse.quote(keyword)}&geo={geo}"
    
    # 等待一段时间避免限流
    print("  等待 10s 避免限流...")
    time.sleep(10)
    
    content = fetch_jina(url, retries=2, delay=10)
    
    if content:
        if "429" in content:
            print("  ⚠️  被 Google 限流，请稍后再试")
            return None
        
        print(f"\n{'='*60}")
        print(f"关键词 '{keyword}' 趋势数据")
        print(f"{'='*60}\n")
        print(content[:2000])
        return content
    else:
        print("  ❌ 抓取失败")
        return None

def main():
    keyword = sys.argv[1] if len(sys.argv) > 1 else "AI"
    geo = sys.argv[2] if len(sys.argv) > 2 else "US"
    
    print("\n🚀 Google Trends 数据抓取工具 v2")
    print("=" * 60)
    
    # 1. 抓取每日热门趋势
    trending = fetch_trending_daily(geo)
    
    # 2. 抓取特定关键词趋势（可选）
    if len(sys.argv) > 1:
        fetch_keyword_trend(keyword, geo)
    
    # 保存结果
    if trending:
        output_file = f"trends_{geo.lower()}_{datetime.now().strftime('%Y%m%d')}.txt"
        with open(output_file, 'w') as f:
            f.write(f"Google Trends 热门趋势 ({geo})\n")
            f.write(f"抓取时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("=" * 60 + "\n\n")
            for i, trend in enumerate(trending, 1):
                f.write(f"{i}. {trend}\n")
        print(f"\n💾 结果已保存到：{output_file}")
    
    print("\n✅ 完成!")
    print("=" * 60)

if __name__ == "__main__":
    main()
