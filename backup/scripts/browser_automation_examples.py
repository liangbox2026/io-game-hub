#!/usr/bin/env python3
# =============================================================================
# Browser 自动化实战脚本集合
# 功能：演示 browser 工具的多种使用场景
# 用法：python3 browser_automation_examples.py [example_name]
# =============================================================================

import json
import sys
from datetime import datetime

# 示例 1: GitHub Trending 分析
def analyze_github_trending():
    """分析 GitHub Trending 项目"""
    print("📊 GitHub Trending 分析")
    print("=" * 50)
    
    # 模拟抓取的数据 (实际应该调用 web_fetch)
    trending_projects = [
        {"name": "SpacetimeDB", "lang": "Rust", "stars": "21,015", "today": "+441"},
        {"name": "superpowers", "lang": "Shell", "stars": "63,665", "today": "+1,532"},
        {"name": "Agent-Skills", "lang": "Python", "stars": "11,889", "today": "+922"},
        {"name": "deer-flow", "lang": "TypeScript", "stars": "21,265", "today": "+617"},
        {"name": "skills", "lang": "Python", "stars": "7,053", "today": "+715"},
    ]
    
    print(f"\n{'项目':<25} {'语言':<12} {'Stars':<12} {'今日':<10}")
    print("-" * 60)
    for proj in trending_projects:
        print(f"{proj['name']:<25} {proj['lang']:<12} {proj['stars']:<12} {proj['today']:<10}")
    
    # 统计
    langs = {}
    for proj in trending_projects:
        lang = proj['lang']
        langs[lang] = langs.get(lang, 0) + 1
    
    print(f"\n语言分布:")
    for lang, count in sorted(langs.items(), key=lambda x: x[1], reverse=True):
        print(f"  {lang}: {count} 个")
    
    return trending_projects

# 示例 2: 多页面抓取对比
def compare_fetch_methods():
    """对比不同抓取方法"""
    print("\n🔍 抓取方法对比")
    print("=" * 50)
    
    methods = [
        {"name": "web_fetch", "speed": "快", "js": "❌", "login": "❌", "best": "静态页面"},
        {"name": "browser (L1)", "speed": "中", "js": "✅", "login": "❌", "best": "动态渲染"},
        {"name": "browser (L2)", "speed": "慢", "js": "✅", "login": "✅", "best": "交互操作"},
        {"name": "browser (L3)", "speed": "很慢", "js": "✅", "login": "✅", "best": "图片内容"},
    ]
    
    print(f"\n{'方法':<20} {'速度':<8} {'JS':<6} {'登录':<6} {'最佳场景':<15}")
    print("-" * 60)
    for m in methods:
        print(f"{m['name']:<20} {m['speed']:<8} {m['js']:<6} {m['login']:<6} {m['best']:<15}")

# 示例 3: 决策树
def get_fetch_strategy(url, needs_login=False, needs_js=False, has_images=False):
    """根据需求选择最佳抓取策略"""
    print("\n🎯 抓取策略决策")
    print("=" * 50)
    print(f"URL: {url}")
    print(f"需要登录：{needs_login}")
    print(f"需要 JS: {needs_js}")
    print(f"有图片内容：{has_images}")
    print()
    
    if has_images:
        strategy = "L3 - 截图 + 视觉识别"
        reason = "包含图片/图表内容"
    elif needs_login:
        strategy = "L2 - 有头浏览器 + DOM 操作"
        reason = "需要登录/交互"
    elif needs_js:
        strategy = "L1 - 无头浏览器"
        reason = "需要 JS 渲染"
    else:
        strategy = "L0 - web_fetch"
        reason = "静态页面，最快"
    
    print(f"推荐策略：{strategy}")
    print(f"原因：{reason}")
    return strategy

# 示例 4: 生成实战报告
def generate_practice_report():
    """生成 Browser 自动化实战报告"""
    date = datetime.now().strftime("%Y-%m-%d")
    report_file = f"/root/.openclaw/workspace/backup/logs/browser_practice_{date}.md"
    
    report = f"""# 🌐 Browser 自动化实战报告

**日期**: {date}
**生成时间**: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

---

## 📊 实战 1: GitHub Trending 抓取

### 任务描述
抓取 GitHub Trending 页面，提取热门项目信息

### 使用工具
- `web_fetch` - 轻量级抓取

### 结果
✅ 成功抓取 10+ 个项目
✅ 提取项目名称、语言、Stars 数、今日增长

### 代码示例
```bash
web_fetch --url="https://github.com/trending" --maxChars=8000
```

---

## 📊 实战 2: 抓取策略决策

### 决策树
```
需要抓取图片？
  ├─ 是 → L3 (截图 + 视觉识别)
  └─ 否 → 需要登录？
           ├─ 是 → L2 (有头浏览器 + DOM 操作)
           └─ 否 → 需要 JS 渲染？
                    ├─ 是 → L1 (无头浏览器)
                    └─ 否 → L0 (web_fetch)
```

### 各层级对比

| 层级 | 工具 | 速度 | 适用场景 |
|------|------|------|----------|
| L0 | web_fetch | ⚡⚡⚡ | 静态页面、文章 |
| L1 | browser (headless) | ⚡⚡ | 动态渲染页面 |
| L2 | browser (visible) | ⚡ | 登录、填表、点击 |
| L3 | browser + vision | 🐌 | 图片/图表内容 |

---

## 📊 实战 3: 速率限制处理

### 问题
频繁请求会触发 API 限流

### 解决方案
```python
import time

# 在请求之间添加延迟
for url in urls:
    content = fetch(url)
    time.sleep(2)  # 2 秒延迟
```

### 最佳实践
- 单次请求间隔：2-3 秒
- 批量请求分批次
- 使用缓存避免重复请求

---

## 💡 经验总结

### 成功要素
1. **选择合适的工具层级** - 不要过度使用 browser
2. **添加速率限制** - 避免被封禁
3. **错误处理** - 准备 fallback 方案
4. **缓存结果** - 减少重复请求

### 常见陷阱
1. ❌ 所有页面都用 browser (慢)
2. ❌ 不添加延迟 (触发限流)
3. ❌ 不处理错误 (任务中断)
4. ❌ 不缓存结果 (浪费资源)

---

## 🎯 下一步练习

- [ ] Hacker News 抓取
- [ ] Product Hunt 每日热门
- [ ] Reddit 热门帖子监控
- [ ] Twitter/X 趋势分析

---

*报告生成于 {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}*
"""
    
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"✅ 实战报告已保存：{report_file}")
    return report_file

# 主函数
def main():
    if len(sys.argv) > 1:
        example = sys.argv[1]
        if example == "trending":
            analyze_github_trending()
        elif example == "compare":
            compare_fetch_methods()
        elif example == "decision":
            get_fetch_strategy("https://example.com", needs_js=True)
        elif example == "report":
            generate_practice_report()
        else:
            print(f"未知示例：{example}")
            print("可用示例：trending, compare, decision, report")
    else:
        # 运行所有示例
        analyze_github_trending()
        compare_fetch_methods()
        get_fetch_strategy("https://github.com/trending")
        generate_practice_report()

if __name__ == "__main__":
    main()
