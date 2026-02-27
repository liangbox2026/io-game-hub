#!/usr/bin/env python3
"""
AI 游戏站快速搭建工具
基于黄金三角模型：选词 + 内容 + 外链
"""

import json
import os
from datetime import datetime

# 游戏关键词候选（从各渠道收集）
GAME_KEYWORDS = [
    {"name": "HorrorVale", "type": "Horror", "trend": "rising"},
    {"name": "AI Dungeon Quest", "type": "RPG", "trend": "stable"},
    {"name": "Cyber Samurai", "type": "Action", "trend": "rising"},
    {"name": "Pixel Farm Life", "type": "Simulation", "trend": "rising"},
    {"name": "Space Trader", "type": "Strategy", "trend": "stable"},
]

def generate_content(game_name, game_type="RPG"):
    """生成 SEO 优化内容"""
    
    content = f"""# {game_name} - Play Online Free

## Play {game_name} Game

<iframe src="https://example.com/embed/{game_name.lower().replace(' ', '-')}" 
        width="800" 
        height="600" 
        frameborder="0"
        loading="lazy"
        allowfullscreen>
</iframe>

## How to Play {game_name}

{game_name} is an exciting {game_type} game that you can play directly in your browser. 
No download required!

### Game Controls:
- **WASD / Arrow Keys**: Move character
- **Mouse**: Interact with objects
- **Space**: Action button
- **ESC**: Pause menu

## {game_name} Game Features

✨ **Unique Features:**
- Immersive {game_type.lower()} gameplay
- Stunning graphics and sound effects
- Multiple levels and challenges
- Save progress automatically
- Play on any device (PC, tablet, mobile)

## Why Play {game_name}?

🎮 **Top Reasons:**
1. **Free to Play** - No cost, no registration required
2. **Instant Access** - Start playing immediately
3. **Regular Updates** - New content added weekly
4. **Community** - Join thousands of players worldwide

## {game_name} Game Overview

| Feature | Description |
|---------|-------------|
| Genre | {game_type} |
| Platform | Browser (HTML5) |
| Release Date | 2025 |
| Developer | Indie Studio |
| Rating | ⭐⭐⭐⭐⭐ |

## Frequently Asked Questions (FAQ)

### Is {game_name} free to play?
Yes! {game_name} is completely free to play online. No download or registration required.

### Can I play {game_name} on mobile?
Yes! The game works on all modern browsers including Chrome, Firefox, Safari on desktop and mobile devices.

### How do I save my progress?
Your progress is automatically saved in your browser. Make sure not to clear your browser cache.

### Are there in-game purchases?
{game_name} is free with optional cosmetic upgrades. All core content is accessible without payment.

## Explore More Games

If you enjoyed {game_name}, check out these similar games:
- [Related Game 1](/games/related-1)
- [Related Game 2](/games/related-2)
- [Related Game 3](/games/related-3)

---

**Tags:** {game_name.lower().replace(' ', '-')}, {game_type.lower()} game, play online free, browser game, HTML5 game, {game_name.lower()} walkthrough

**Published:** {datetime.now().strftime('%Y-%m-%d')}
"""
    return content


def create_game_site(game_name, game_type="RPG", output_dir="./game_sites"):
    """创建完整游戏站"""
    
    # 创建目录
    site_dir = f"{output_dir}/{game_name.lower().replace(' ', '_')}"
    os.makedirs(site_dir, exist_ok=True)
    
    # 生成内容
    content = generate_content(game_name, game_type)
    
    # 保存 HTML
    html_template = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{game_name} - Play Online Free</title>
    <meta name="description" content="Play {game_name} online for free. Best {game_type} game with instant access. No download required!">
    <meta name="keywords" content="{game_name}, {game_type} game, play online, free game, browser game">
    <style>
        body {{ font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px; }}
        iframe {{ width: 100%; max-width: 800px; height: 600px; border: 2px solid #333; border-radius: 8px; }}
        h1 {{ color: #2c3e50; }}
        h2 {{ color: #34495e; border-bottom: 2px solid #3498db; padding-bottom: 10px; }}
        table {{ border-collapse: collapse; width: 100%; margin: 20px 0; }}
        th, td {{ border: 1px solid #ddd; padding: 12px; text-align: left; }}
        th {{ background-color: #3498db; color: white; }}
        .features {{ background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }}
    </style>
</head>
<body>
    <article>
{content}
    </article>
    <footer style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #ddd; color: #666;">
        <p>© 2025 Game Site. All rights reserved.</p>
    </footer>
</body>
</html>
"""
    
    with open(f"{site_dir}/index.html", 'w') as f:
        f.write(html_template)
    
    # 保存 SEO 内容 (Markdown)
    with open(f"{site_dir}/content.md", 'w') as f:
        f.write(content)
    
    # 创建配置文件
    config = {
        "game_name": game_name,
        "game_type": game_type,
        "created_at": datetime.now().isoformat(),
        "seo": {
            "title": f"{game_name} - Play Online Free",
            "description": f"Play {game_name} online for free. Best {game_type} game with instant access.",
            "keywords": f"{game_name}, {game_type} game, play online, free game",
        },
        "tasks": {
            "pending": [
                "Find actual game iframe URL",
                "Verify Google Trends data",
                "Submit to search engines",
                "Build 5-10 backlinks"
            ],
            "completed": [
                "Site structure created",
                "SEO content generated"
            ]
        }
    }
    
    with open(f"{site_dir}/config.json", 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"✅ 游戏站已创建：{site_dir}/")
    print(f"   - index.html (完整网站)")
    print(f"   - content.md (SEO 内容)")
    print(f"   - config.json (配置文件)")
    
    return site_dir


def main():
    print("\n🎮 AI 游戏站快速搭建工具")
    print("=" * 60)
    
    # 显示候选游戏
    print("\n📋 候选游戏列表:")
    for i, game in enumerate(GAME_KEYWORDS, 1):
        trend_icon = "📈" if game["trend"] == "rising" else "➡️"
        print(f"  {i}. {game['name']} ({game['type']}) {trend_icon}")
    
    # 选择游戏
    try:
        choice = int(input(f"\n选择游戏编号 (1-{len(GAME_KEYWORDS)}): ")) - 1
        if 0 <= choice < len(GAME_KEYWORDS):
            selected = GAME_KEYWORDS[choice]
        else:
            print("无效选择，使用默认")
            selected = GAME_KEYWORDS[0]
    except:
        print("使用默认游戏")
        selected = GAME_KEYWORDS[0]
    
    print(f"\n🎯 选择：{selected['name']} ({selected['type']})")
    
    # 创建网站
    site_dir = create_game_site(selected['name'], selected['type'])
    
    print(f"\n✅ 完成！下一步:")
    print("  1. 找到实际的游戏 iframe 嵌入链接")
    print("  2. 用 Google Trends 验证关键词趋势")
    print("  3. 部署到 GitHub Pages / Vercel / Netlify")
    print("  4. 开始建设外链 (Reddit, 论坛等)")
    print("\n" + "=" * 60)


if __name__ == "__main__":
    main()
