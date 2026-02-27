# 🧠 技能提炼与压缩 (2026-02-25)

_每日学习 → 提炼核心 → 压缩成模式 → 内化为本能_

---

## 📚 今日学习输入

| 来源 | 内容 | 耗时 |
|------|------|------|
| OpenClaw 实战文章 | 夙愿学长的配置指南（浏览器 4 层级、jina.ai、steer 模式等） | 30min |
| Google Trends 文档 | 趋势分析方法和应用场景 | 15min |
| 实践测试 | jina.ai 抓取 Google Trends | 45min |
| 系统更新 | OpenClaw v2026.2.9 → v2026.2.24 | - |

---

## 🔑 核心提炼 (压缩 80% → 20%)

### 1️⃣ 信息获取 4 层级模型

```
L0: 搜索 + 抓取 (web_search + web_fetch)
    └─ 适用：80% 公开信息，无需登录
    
L1: 无头浏览器 (headless browser)
    └─ 适用：需要 JS 渲染的页面
    
L2: 有头浏览器 + DOM 操作
    └─ 适用：登录、填表、点击交互
    
L3: 截图 + 视觉识别
    └─ 适用：图片/图表内容，兜底方案
```

**决策树：**
```
需要登录？→ 是 → L2/L3
         → 否 → 需要 JS 渲染？→ 是 → L1
                              → 否 → L0
```

### 2️⃣ jina.ai Reader 使用模式

**核心能力：**
- 绕过付费墙
- 返回干净 Markdown
- 免费无需 API key

**用法：**
```
https://r.jina.ai/https://目标网址
```

**集成到 web_fetch：**
```python
# 优先尝试 jina.ai，失败后回退到直接抓取
def smart_fetch(url):
    jina_url = f"https://r.jina.ai/{url}"
    content = fetch(jina_url)
    if not content or "429" in content:
        content = fetch(url)  # 回退
    return content
```

### 3️⃣ Gateway 故障排查流程

**问题：token 不匹配**
```
1. 检查 openclaw.json 中的 gateway.auth.token
2. 检查 systemd 服务文件中的 OPENCLAW_GATEWAY_TOKEN
3. 更新两者保持一致
4. systemctl --user daemon-reload && restart
```

**通用排查树：**
```
Gateway 不可用？
  ├─ 检查服务状态 → systemctl --user status openclaw-gateway
  ├─ 检查端口占用 → netstat -tlnp | grep 18789
  ├─ 检查 token 匹配 → grep -r OPENCLAW_GATEWAY_TOKEN
  └─ 查看日志 → journalctl --user -u openclaw-gateway
```

### 4️⃣ AI 输出质量控制原则

> **"AI 干活的质量上限，不取决于模型多强，取决于你能不能把「什么算做得好」写清楚。"**

**规范要素：**
1. 格式模板（标题、摘要、点评结构）
2. 数量约束（每条 3-6 句话）
3. 质量标准（什么算凑数条目）
4. 正误示例（正确 vs 错误对比）

### 5️⃣ Google Trends 使用模式

**判断新词 vs 老词：**
| 特征 | 新词 | 老词 |
|------|------|------|
| 趋势图 | 陡升→缓降 (尖峰) | 水平线或周期波动 |
| 原因 | 技术突破/热点 | 术语/概念/日常需求 |

**应用场景：**
- 验证产品创意
- 分析市场需求
- 对比竞品关键词

---

## 📦 压缩成可复用模式

### 模式 1：智能信息抓取

```python
def fetch_smart(url, use_jina=True):
    """智能抓取：优先 jina.ai，失败回退"""
    if use_jina:
        content = web_fetch(f"https://r.jina.ai/{url}")
        if content and "429" not in content:
            return content
    return web_fetch(url)  # 回退
```

### 模式 2：Gateway 自检脚本

```bash
#!/bin/bash
# gateway-check.sh
echo "=== Gateway 状态检查 ==="
systemctl --user status openclaw-gateway --no-pager
echo ""
echo "=== Token 检查 ==="
grep OPENCLAW_GATEWAY_TOKEN /root/.config/systemd/user/openclaw-gateway.service
grep -A1 '"token"' /root/.openclaw/openclaw.json
echo ""
echo "=== 端口检查 ==="
curl -s http://127.0.0.1:18789/health | head -3
```

### 模式 3：输出规范模板

```markdown
# [任务名称] 输出规范

## 格式要求
- 标题：[类型] 核心内容
- 每条：3-6 句话，包含背景 + 进展 + 影响
- 数量：每日 5-10 条

## 质量标准
✅ 好的：有具体数据、有来源、有分析
❌ 差的：纯标题、无实质内容、重复

## 示例
✅ "Anthropic 完成 30 亿美元 G 轮融资，投后估值 3800 亿..."
❌ "Anthropic 融资了"
```

---

## 🧬 技能进化更新

### 熟练度变化

| 技能 | 之前 | 现在 | 变化 |
|------|------|------|------|
| web_fetch | L2 🟢 | L2 🟢 | + 掌握 jina.ai 模式 |
| browser 理解 | L1 🟡 | L2 🟢 | + 理解 4 层级模型 |
| 故障排查 | L1 🟡 | L2 🟢 | + Gateway token 修复经验 |
| 输出规范 | L0 ⚪ | L1 🟡 | + 学习质量标准设计 |

### 新技能解锁

- ✅ **jina.ai Reader 集成** - 绕过付费墙抓取
- ✅ **systemd 服务调试** - token 同步问题修复
- ✅ **信息获取层级决策** - L0-L3 选择策略

---

## 🎯 明日优化目标

### 自动化改进
1. [ ] 创建 `fetch_smart()` 工具函数
2. [ ] 添加 Gateway 自检 cron 任务
3. [ ] 编写 AI 新闻输出规范文档

### 技能深化
1. [ ] 用 browser 实战 GitHub Trending 抓取
2. [ ] 测试 steer 模式效果
3. [ ] 创建多会话分场景使用

---

## 💡 元认知洞察

**今日最大收获：**
> 工具使用的本质不是"知道所有功能"，而是"建立决策框架"。
> 
> 例如：信息获取 4 层级模型让我能快速判断该用哪种工具，
> 而不是盲目尝试。

**压缩原则：**
1. **80/20 法则** - 只保留 20% 核心知识
2. **模式化** - 把经验变成可复用代码/脚本
3. **决策树** - 把知识变成判断流程
4. **自动化** - 把重复操作变成脚本

---

_创建时间：2026-02-25_
_下次更新：2026-02-26_
