#!/usr/bin/env python3
"""
AI News RSS Fetcher
自动从多个 RSS 源获取最新的 AI 相关新闻
"""

import feedparser
import json
import time
from datetime import datetime, timedelta

# AI 新闻 RSS 源配置
RSS_SOURCES = {
    'domestic': [
        'https://www.jiqizhixin.com/rss',
        'https://www.qbitai.com/feed',
        'https://www.leiphone.com/feed',
    ],
    'international': [
        'https://techcrunch.com/category/artificial-intelligence/feed/',
        'https://www.theverge.com/ai/rss/index.xml',
        'https://www.wired.com/feed/category/artificial-intelligence/latest/rss',
    ]
}

def fetch_ai_news():
    """获取 AI 新闻并返回结构化数据"""
    news_data = {
        'domestic': [],
        'international': [],
        'fetched_at': datetime.now().isoformat()
    }
    
    # 获取国内 AI 新闻 (带速率限制)
    for i, source in enumerate(RSS_SOURCES['domestic']):
        try:
            if i > 0:
                time.sleep(2)  # 每个请求间隔 2 秒
            feed = feedparser.parse(source)
            for entry in feed.entries[:3]:  # 每个源取最新 3 条
                news_data['domestic'].append({
                    'title': entry.title,
                    'link': entry.link,
                    'published': entry.get('published', ''),
                    'source': source
                })
        except Exception as e:
            print(f"Error fetching {source}: {e}")
    
    # 获取国际 AI 新闻 (带速率限制)
    time.sleep(3)  # 国内和国际请求之间间隔 3 秒
    for i, source in enumerate(RSS_SOURCES['international']):
        try:
            if i > 0:
                time.sleep(2)  # 每个请求间隔 2 秒
            feed = feedparser.parse(source)
            for entry in feed.entries[:3]:  # 每个源取最新 3 条
                news_data['international'].append({
                    'title': entry.title,
                    'link': entry.link,
                    'published': entry.get('published', ''),
                    'source': source
                })
        except Exception as e:
            print(f"Error fetching {source}: {e}")
    
    # 限制每类新闻最多 5 条
    news_data['domestic'] = news_data['domestic'][:5]
    news_data['international'] = news_data['international'][:5]
    
    return news_data

if __name__ == "__main__":
    news = fetch_ai_news()
    print(json.dumps(news, indent=2, ensure_ascii=False))
