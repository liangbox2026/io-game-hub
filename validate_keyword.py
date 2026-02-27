#!/usr/bin/env python3
"""
游戏关键词热度验证工具
多渠道验证游戏词的热度和潜力
"""

import urllib.request
import urllib.parse
import ssl
import json
import re
from datetime import datetime

class KeywordValidator:
    def __init__(self):
        self.ctx = ssl.create_default_context()
        self.ctx.check_hostname = False
        self.ctx.verify_mode = ssl.CERT_NONE
        
        self.headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "Accept": "text/html,application/xhtml+xml,application/json",
        }
    
    def fetch_with_jina(self, url, timeout=15):
        """使用 jina.ai 抓取"""
        jina_url = f"https://r.jina.ai/{url}"
        try:
            req = urllib.request.Request(jina_url, headers=self.headers)
            with urllib.request.urlopen(req, context=self.ctx, timeout=timeout) as response:
                content = response.read().decode('utf-8')
                
                # 检查错误
                if "429" in content or "Too Many Requests" in content:
                    return {"error": "rate_limited", "content": content}
                if "403" in content or "Forbidden" in content:
                    return {"error": "forbidden", "content": content}
                
                return {"error": None, "content": content}
        except Exception as e:
            return {"error": str(e), "content": None}
    
    def check_google_trends(self, keyword):
        """检查 Google Trends (需手动验证，提供链接)"""
        url = f"https://trends.google.com/trends/explore?q={urllib.parse.quote(keyword)}"
        print(f"\n📊 Google Trends 验证")
        print(f"   链接：{url}")
        print(f"   说明：由于反爬保护，请手动访问上方链接查看趋势")
        print(f"   判断标准:")
        print(f"     ✅ 趋势线持续上升 → 新词爆发")
        print(f"     ⚠️ 平稳波动 → 成熟词汇")
        print(f"     ❌ 下降趋势 → 热度消退")
        print(f"     ➖ 无数据 → 词太新 (风险/机遇)")
        return {"url": url, "status": "manual_check_required"}
    
    def check_twitter_mentions(self, keyword):
        """检查 Twitter 提及数"""
        # 使用 jina.ai 抓取 Twitter 搜索结果
        url = f"https://twitter.com/search?q={urllib.parse.quote(keyword)}"
        result = self.fetch_with_jina(url)
        
        print(f"\n🐦 Twitter 验证")
        if result["error"]:
            print(f"   状态：❌ {result['error']}")
            return {"error": result["error"], "count": 0}
        
        # 简单统计提及数 (实际应该解析内容)
        content = result.get("content", "")
        # 这里只是示例，实际需要解析 HTML
        print(f"   状态：⏳ 需解析内容")
        return {"error": None, "status": "needs_parsing"}
    
    def check_youtube_videos(self, keyword):
        """检查 YouTube 视频数"""
        print(f"\n📺 YouTube 验证")
        url = f"https://youtube.com/results?search_query={urllib.parse.quote(keyword)}"
        print(f"   链接：{url}")
        print(f"   说明：请手动访问查看视频数量和播放量")
        print(f"   判断标准:")
        print(f"     ✅ >10 个视频，播放量>1000 → 有热度")
        print(f"     ⚠️ <10 个视频 → 新兴内容")
        print(f"     ❌ 无视频 → 无热度")
        return {"url": url, "status": "manual_check_required"}
    
    def check_google_search(self, keyword):
        """检查 Google 搜索结果数"""
        print(f"\n🔍 Google 搜索验证")
        url = f"https://www.google.com/search?q={urllib.parse.quote(f'{keyword} game online')}"
        print(f"   链接：{url}")
        print(f"   说明：请手动访问查看搜索结果数量")
        print(f"   判断标准:")
        print(f"     ✅ <100 万结果 → 竞争小")
        print(f"     ⚠️ 100-500 万 → 中等竞争")
        print(f"     ❌ >500 万 → 竞争激烈")
        return {"url": url, "status": "manual_check_required"}
    
    def check_itch_io(self, keyword):
        """检查 itch.io 是否有游戏"""
        print(f"\n🎮 itch.io 验证")
        url = f"https://itch.io/games?q={urllib.parse.quote(keyword)}"
        result = self.fetch_with_jina(url)
        
        if result["error"]:
            print(f"   状态：❌ {result['error']}")
            return {"error": result["error"]}
        
        content = result.get("content", "")
        # 检查是否找到游戏
        if keyword.lower() in content.lower():
            print(f"   状态：✅ 找到相关游戏")
        else:
            print(f"   状态：⚠️ 未找到明确匹配")
        
        return {"error": None, "status": "checked"}
    
    def generate_report(self, keyword, results):
        """生成验证报告"""
        print("\n" + "="*60)
        print(f"📋 关键词验证报告：{keyword}")
        print("="*60)
        print(f"验证时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print()
        
        # 打分
        score = 0
        max_score = 5
        
        print("验证项目:")
        for check_name, result in results.items():
            if "manual_check" in str(result):
                print(f"  ⏳ {check_name}: 需手动验证")
            elif result.get("error"):
                print(f"  ❌ {check_name}: {result['error']}")
            else:
                print(f"  ✅ {check_name}: 已检查")
                score += 1
        
        print()
        print(f"初步得分：{score}/{max_score}")
        print()
        print("下一步:")
        print("  1. 访问上方提供的链接手动验证")
        print("  2. 填写 KEYWORD_VALIDATION.md 中的打分表")
        print("  3. 总分 4.0+ → ✅ 上线，<3.0 → ❌ 换词")
        print("="*60)


def main():
    print("\n🔍 游戏关键词热度验证工具")
    print("="*60)
    
    # 候选关键词
    keywords = [
        "HorrorVale",
        "Cyber Samurai",
        "Pixel Farm Life",
        "AI Dungeon Quest",
        "Space Trader"
    ]
    
    print("\n候选关键词列表:")
    for i, kw in enumerate(keywords, 1):
        print(f"  {i}. {kw}")
    
    # 选择要验证的词
    try:
        choice = int(input(f"\n选择要验证的关键词编号 (1-{len(keywords)}): ")) - 1
        if 0 <= choice < len(keywords):
            keyword = keywords[choice]
        else:
            print("无效选择，使用默认")
            keyword = keywords[0]
    except:
        print("使用默认关键词：HorrorVale")
        keyword = "HorrorVale"
    
    print(f"\n🎯 开始验证：{keyword}")
    
    validator = KeywordValidator()
    results = {}
    
    # 执行验证
    results["Google Trends"] = validator.check_google_trends(keyword)
    results["YouTube"] = validator.check_youtube_videos(keyword)
    results["Google Search"] = validator.check_google_search(keyword)
    results["itch.io"] = validator.check_itch_io(keyword)
    # results["Twitter"] = validator.check_twitter_mentions(keyword)
    
    # 生成报告
    validator.generate_report(keyword, results)
    
    print("\n💡 提示:")
    print("  - 打开上方链接手动验证 Google Trends 和 YouTube")
    print("  - 记录结果到 KEYWORD_VALIDATION.md")
    print("  - 总分 4.0+ 即可上线！")


if __name__ == "__main__":
    main()
