#!/usr/bin/env python3
"""
Reddit 舆情监控 - 演示版本
使用模拟数据展示完整监控流程效果
"""

import json
from datetime import datetime, timedelta
import random

class RedditMonitorDemo:
    def __init__(self):
        # 模拟数据
        self.sample_posts = [
            {
                'title': 'Amazing AI automation tool using 飞书 base!',
                'subreddit': 'r/automation',
                'author': 'u/techfan2026',
                'points': 256,
                'comments': 45,
                'created': datetime.now() - timedelta(hours=2),
            },
            {
                'title': 'Disappointed with the new RPA software - too many issues',
                'subreddit': 'r/artificial',
                'author': 'u/frustrated_dev',
                'points': 189,
                'comments': 67,
                'created': datetime.now() - timedelta(hours=5),
            },
            {
                'title': 'How to use AI for automation? Looking for recommendations',
                'subreddit': 'r/MachineLearning',
                'author': 'u/newbie123',
                'points': 134,
                'comments': 89,
                'created': datetime.now() - timedelta(hours=8),
            },
            {
                'title': '飞书多维表格 is a game changer for our team productivity',
                'subreddit': 'r/technology',
                'author': 'u/productivity_guru',
                'points': 421,
                'comments': 102,
                'created': datetime.now() - timedelta(hours=12),
            },
            {
                'title': 'Best Lark base alternatives in 2026?',
                'subreddit': 'r/automation',
                'author': 'u/seeking_advice',
                'points': 98,
                'comments': 34,
                'created': datetime.now() - timedelta(hours=1),
            },
            {
                'title': 'Automation trends to watch - AI is everywhere',
                'subreddit': 'r/artificial',
                'author': 'u/futurist',
                'points': 567,
                'comments': 123,
                'created': datetime.now() - timedelta(hours=24),
            },
        ]
        
        self.keywords = [
            "AI",
            "RPA", 
            "automation",
            "飞书",
            "多维表格",
            "Lark",
            "base",
        ]
    
    def analyze_sentiment(self, text):
        """情感分析"""
        positive_words = [
            'amazing', 'great', 'excellent', 'awesome', 'love', 
            'helpful', 'best', 'recommend', 'perfect', 'happy',
            'game changer', 'productivity'
        ]
        
        negative_words = [
            'bad', 'terrible', 'awful', 'hate', 'worst', 
            'disappointed', 'useless', 'waste', 'problem', 
            'issue', 'fail', 'frustrated'
        ]
        
        text_lower = text.lower()
        
        positive_count = sum(1 for word in positive_words if word in text_lower)
        negative_count = sum(1 for word in negative_words if word in text_lower)
        
        if positive_count > negative_count * 1.5:
            return 'positive'
        elif negative_count > positive_count * 1.5:
            return 'negative'
        else:
            return 'neutral'
    
    def check_keywords(self, text):
        """关键词匹配"""
        text_lower = text.lower()
        matched = []
        
        for keyword in self.keywords:
            if keyword.lower() in text_lower:
                matched.append(keyword)
        
        return matched
    
    def run_demo(self):
        """运行演示"""
        print("\n🔍 Reddit 舆情监控 - 演示模式")
        print("=" * 70)
        print(f"监控子社区：4 个 (r/automation, r/artificial, r/MachineLearning, r/technology)")
        print(f"监控关键词：{len(self.keywords)} 个 ({', '.join(self.keywords)})")
        print("=" * 70)
        
        # 处理所有帖子
        print(f"\n📝 处理 {len(self.sample_posts)} 个帖子...")
        
        matched_posts = []
        for post in self.sample_posts:
            title = post['title']
            
            # 情感分析
            sentiment = self.analyze_sentiment(title)
            
            # 关键词匹配
            matched_keywords = self.check_keywords(title)
            
            # 只保留匹配关键词的帖子
            if matched_keywords:
                post['sentiment'] = sentiment
                post['matched_keywords'] = matched_keywords
                matched_posts.append(post)
        
        print(f"✅ 匹配到 {len(matched_posts)} 个相关帖子\n")
        
        # 发送通知
        print("📬 发送通知...")
        print("=" * 70)
        
        for i, post in enumerate(matched_posts, 1):
            sentiment_emoji = {
                'positive': '✅',
                'negative': '⚠️',
                'neutral': 'ℹ️'
            }
            
            message = f"""
{i}. {sentiment_emoji.get(post['sentiment'], 'ℹ️')} **Reddit 舆情预警**

📌 标题：{post['title']}
🏷️ 关键词：{', '.join(post['matched_keywords'])}
📊 情感：{post['sentiment']}
📁 子社区：{post['subreddit']}
👤 作者：{post['author']}
📈 热度：{post['points']} 点赞，{post['comments']} 评论
⏰ 时间：{post['created'].strftime('%Y-%m-%d %H:%M')}
🔗 链接：https://reddit.com{post['subreddit']}/demo
"""
            print(message)
        
        # 生成报告
        print("\n" + "=" * 70)
        print("📊 监控报告")
        print("=" * 70)
        print(f"总抓取帖子数：{len(self.sample_posts)}")
        print(f"匹配关键词数：{len(matched_posts)}")
        
        # 情感分布
        sentiment_count = {}
        for post in matched_posts:
            sentiment = post['sentiment']
            sentiment_count[sentiment] = sentiment_count.get(sentiment, 0) + 1
        
        print(f"情感分布：")
        for sentiment, count in sentiment_count.items():
            emoji = {'positive': '✅', 'negative': '⚠️', 'neutral': 'ℹ️'}.get(sentiment, '')
            print(f"  {emoji} {sentiment}: {count} ({count/len(matched_posts)*100:.1f}%)")
        
        # 关键词统计
        keyword_count = {}
        for post in matched_posts:
            for kw in post['matched_keywords']:
                keyword_count[kw] = keyword_count.get(kw, 0) + 1
        
        print(f"\n关键词热度:")
        for kw, count in sorted(keyword_count.items(), key=lambda x: x[1], reverse=True):
            print(f"  • {kw}: {count} 次")
        
        print("=" * 70)
        
        # 保存结果
        result = {
            'total_posts': len(self.sample_posts),
            'matched_posts': len(matched_posts),
            'sentiment_distribution': sentiment_count,
            'keyword_distribution': keyword_count,
            'posts': [
                {
                    'title': p['title'],
                    'sentiment': p['sentiment'],
                    'matched_keywords': p['matched_keywords'],
                    'subreddit': p['subreddit'],
                    'points': p['points'],
                    'comments': p['comments'],
                    'created': p['created'].isoformat(),
                }
                for p in matched_posts
            ],
        }
        
        output_file = f"reddit_demo_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(result, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 结果已保存到：{output_file}")
        print("\n✅ 演示完成！")
        print("=" * 70)
        
        return result


def main():
    monitor = RedditMonitorDemo()
    result = monitor.run_demo()


if __name__ == "__main__":
    main()
