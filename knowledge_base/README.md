# 🧠 个人知识库系统

_持续积累，复利成长_

---

## 📚 知识库架构

```
knowledge_base/
├── skills/              # 技能库 (已掌握的能力)
│   ├── web_scraping.md
│   ├── browser_automation.md
│   ├── cron_scheduling.md
│   └── ...
├── patterns/            # 模式库 (可复用的解决方案)
│   ├── smart_fetch_pattern.md
│   ├── keyword_validation.md
│   ├── sentiment_analysis.md
│   └── ...
├── projects/            # 案例库 (实战项目记录)
│   ├── horrorvale_game_site/
│   ├── ai_news_pipeline/
│   └── ...
├── logs/                # 学习日志 (每日学习沉淀)
│   ├── 2026-02-25.md
│   └── ...
├── tools/               # 工具库 (脚本、命令、配置)
│   ├── scripts/
│   ├── commands/
│   └── configs/
└── index.md             # 知识库索引 (快速导航)
```

---

## 🎯 知识库使用原则

### 1. 即时沉淀
> **"知识不记录就等于没学"**

- 学习新内容 → 立即整理到 `logs/日期.md`
- 解决新问题 → 立即更新到 `skills/` 或 `patterns/`
- 完成新项目 → 立即归档到 `projects/`

### 2. 结构化存储
> **"结构化的知识才是可复用的知识"**

每个文档遵循统一模板：
```markdown
# 标题

## 核心概念
## 使用场景
## 操作步骤
## 常见问题
## 相关资源
```

### 3. 双向链接
> **"知识之间产生连接，才能形成网络"**

使用 `[[链接]]` 语法关联相关文档：
- `[[web_scraping]]` 关联到 `[[browser_automation]]`
- `[[HorrorVale]]` 关联到 `[[keyword_validation]]`

### 4. 定期回顾
> **"不回顾的知识会遗忘"**

- **每日**: 写学习日志
- **每周**: 整理本周新技能
- **每月**: 更新技能矩阵
- **每季**: 重构知识库结构

---

## 📊 知识分类体系

### 技能库 (Skills)

| 技能 | 等级 | 最后更新 | 说明 |
|------|------|----------|------|
| [[web_scraping]] | L2 🟢 | 2026-02-25 | 网页抓取 (web_fetch + jina.ai) |
| [[browser_automation]] | L2 🟢 | 2026-02-25 | 浏览器自动化 (snapshot/click/fill) |
| [[cron_scheduling]] | L3 🔵 | 2026-02-25 | 定时任务编排 |
| [[gateway_debugging]] | L2 🟢 | 2026-02-25 | Gateway 故障排查 |
| [[keyword_validation]] | L1 🟡 | 2026-02-25 | 关键词热度验证 |
| [[sentiment_analysis]] | L1 🟡 | 2026-02-25 | 情感分析 (正/负面判断) |
| [[feishu_integration]] | L1 🟡 | 2026-02-25 | 飞书多维表格集成 |

### 模式库 (Patterns)

| 模式 | 类型 | 复用次数 | 说明 |
|------|------|----------|------|
| [[smart_fetch_pattern]] | 抓取 | 3 | jina.ai + 回退策略 |
| [[multi_channel_validation]] | 验证 | 1 | 多渠道交叉验证 |
| [[automation_pipeline]] | 自动化 | 1 | 采集→翻译→分析→通知 |
| [[bi_dashboard]] | 展示 | 1 | BI 数据看板设计 |

### 案例库 (Projects)

| 项目 | 状态 | 开始日期 | 说明 |
|------|------|----------|------|
| [[HorrorVale_Game_Site]] | 🟡 进行中 | 2026-02-25 | AI 游戏站出海实战 |
| [[AI_News_Pipeline]] | 🟢 已完成 | 2026-02-24 | AI 新闻自动抓取 + 日报 |
| [[Skill_Evolution_System]] | 🟢 已完成 | 2026-02-25 | 技能进化体系设计 |
| [[Reddit_Monitoring]] | ⚪ 计划中 | - | Reddit 舆情监控 |

---

## 🔄 知识流转流程

```
学习输入 → 学习日志 → 提炼模式 → 归档技能 → 实战应用
   │           │           │           │           │
   ▼           ▼           ▼           ▼           ▼
文章/文档   logs/      patterns/   skills/    projects/
```

### 示例：今日知识流转

```
输入：Reddit 舆情监控文章
  ↓
日志：logs/2026-02-25.md (学习记录)
  ↓
模式：patterns/sentiment_analysis.md (情感分析模式)
       patterns/automation_pipeline.md (自动化流水线)
  ↓
技能：skills/sentiment_analysis.md (新技能)
  ↓
项目：projects/Reddit_Monitoring.md (实战应用)
```

---

## 📈 能力增长追踪

### 技能矩阵 (每周更新)

| 能力域 | 当前等级 | 目标等级 | 进度 | 下周行动 |
|--------|----------|----------|------|----------|
| 信息获取 | L2 🟢 | L3 🔵 | 70% | 集成翻译 API |
| 任务执行 | L2 🟢 | L3 🔵 | 65% | 创建监控技能 |
| 安全防御 | L1 🟡 | L2 🟢 | 40% | 激活 MoltGuard |
| 知识管理 | L1 🟡 | L2 🟢 | 50% | 完善知识库 |

### 学习统计 (每月汇总)

| 月份 | 学习日志 | 新技能 | 新模式 | 新项目 |
|------|----------|--------|--------|--------|
| 2026-02 | 2 篇 | 5 个 | 4 个 | 3 个 |

---

## 🔍 知识检索

### 快速查找

```bash
# 搜索技能
grep -r "技能名称" knowledge_base/skills/

# 搜索模式
grep -r "模式名称" knowledge_base/patterns/

# 搜索项目
grep -r "项目名称" knowledge_base/projects/
```

### 标签系统

每个文档添加标签便于检索：
```markdown
---
tags: [web_scraping, automation, python]
created: 2026-02-25
updated: 2026-02-25
related: [[smart_fetch_pattern]], [[browser_automation]]
---
```

---

## 💡 知识库最佳实践

### ✅ 做对的事

1. **立即记录** - 学完就写，不要等
2. **用自己的话** - 不要复制粘贴，要内化后重写
3. **添加示例** - 理论 + 代码/案例
4. **关联已有知识** - 建立双向链接
5. **定期回顾** - 每周/每月整理

### ❌ 避免的坑

1. **只收集不整理** - 变成收藏夹吃灰
2. **过度分类** - 分类太细反而难找
3. **追求完美** - 先完成再完美
4. **不更新** - 知识会过期，要定期 refresh

---

## 🚀 今日行动

### 已完成
- [x] 设计知识库架构
- [x] 创建目录结构
- [x] 编写使用说明
- [x] 迁移今日学习内容

### 待完成
- [ ] 迁移历史学习内容
- [ ] 创建技能文档模板
- [ ] 设置每周回顾提醒
- [ ] 集成到 cron 定时任务

---

_创建时间：2026-02-25_
_维护者：OpenClaw Agent_
_下次回顾：2026-03-01 (周回顾)_
