# Feishu 多维表格集成方案

_Reddit 舆情监控数据流转与存储_

**等级**: L1 🟡  
**创建日期**: 2026-02-25  
**相关**: [[reddit_monitoring]], [[sentiment_analysis]]

---

## 📦 整体架构

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Reddit 监控    │────→│  Feishu 多维表格 │────→│   BI 数据看板    │
│  (数据采集)     │     │  (数据存储)     │     │   (数据展示)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
   • 自动抓取              • 自动翻译              • 声量趋势图
   • 情感分析              • 情感标记              • 情感比例饼图
   • 关键词匹配            • 关键词高亮            • 话题聚类词云
```

---

## 🛠️ 集成方案

### 方案 A: OpenClaw + Feishu API (推荐)

**优势**:
- ✅ 直接在 OpenClaw 内调用 Feishu API
- ✅ 实时写入数据
- ✅ 无需额外工具

**实现步骤**:

#### 1. 获取 Feishu 授权

```bash
# 1. 创建 Feishu 应用
访问：https://open.feishu.cn/app

# 2. 获取 App ID 和 App Secret
App ID: cli_a91fc0eb96f89bc7 (已有)
App Secret: U8cqWj4dmKF6TfgSVoyvSbsROu1Ywjcg (已有)

# 3. 获取 tenant_access_token
POST https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal
{
  "app_id": "cli_a91fc0eb96f89bc7",
  "app_secret": "U8cqWj4dmKF6TfgSVoyvSbsROu1Ywjcg"
}
```

#### 2. 创建多维表格

```bash
# 使用现有 Feishu 工具
feishu_bitable_create_app name="Reddit 舆情监控"

# 或使用已有 base
Base URL: https://vantasma.feishu.cn/base/CtLhbbcyIaaxdxsBOfncNRcen0f
```

#### 3. 数据表结构设计

**表 1: 社区帖子采集**

| 字段名 | 类型 | 说明 |
|--------|------|------|
| 帖子 ID | 文本 | 唯一标识 |
| 帖子标题 | 文本 | 原始标题 |
| 翻译内容 | 文本 | 中文翻译 |
| 子社区 | 文本 | r/automation 等 |
| 作者 | 文本 | 发帖人 |
| 点赞数 | 数字 | upvotes |
| 评论数 | 数字 | 评论数量 |
| 情感倾向 | 单选 | positive/negative/neutral |
| 匹配关键词 | 多选 | AI, RPA, 飞书等 |
| 创建时间 | 日期 | 发帖时间 |
| 采集时间 | 日期 | 抓取时间 |
| 帖子链接 | 链接 | Reddit URL |

**表 2: 帖子评论采集**

| 字段名 | 类型 | 说明 |
|--------|------|------|
| 评论 ID | 文本 | 唯一标识 |
| 关联帖子 | 关联 | 链接到帖子表 |
| 评论内容 | 文本 | 原始评论 |
| 翻译内容 | 文本 | 中文翻译 |
| 作者 | 文本 | 评论人 |
| 情感倾向 | 单选 | positive/negative/neutral |
| 匹配关键词 | 多选 | 命中的关键词 |
| 创建时间 | 日期 | 评论时间 |

**表 3: 监控关键词配置**

| 字段名 | 类型 | 说明 |
|--------|------|------|
| 关键词 | 文本 | AI, RPA 等 |
| 是否启用 | 复选框 | 控制开关 |
| 优先级 | 单选 | 高/中/低 |
| 备注 | 文本 | 说明 |

**表 4: 社区小组链接配置**

| 字段名 | 类型 | 说明 |
|--------|------|------|
| 子社区名称 | 文本 | automation |
| 完整链接 | 链接 | https://reddit.com/r/automation |
| 是否循环采集 | 复选框 | 持续监控 |
| 采集频率 | 单选 | 每小时/每天/每周 |
| 最后采集时间 | 日期 | 记录 |

---

### 方案 B: 八爪鱼 RPA + Feishu (原文方案)

**优势**:
- ✅ 图形化配置，无需编程
- ✅ 自动翻页、自动滚动
- ✅ 成熟的 Reddit 模板

**配置步骤**:

#### 1. 下载八爪鱼 RPA

```
下载链接：https://partner.rpa.bazhuayu.com/reddwb
仅支持 Windows
```

#### 2. 获取飞书授权码

```
1. 打开飞书多维表格
2. 点击右上角"插件" → "自定义插件"
3. 点击"获取授权码" → "启动授权码"
4. 复制授权码字符串
```

#### 3. 配置 RPA 应用

**机器人 1 号：社区新帖监控**

应用链接：https://rpa.bazhuayu.com/shareableLink/695ce9d4c43b527d69f09e31

配置参数：
- 飞书授权码：[填入授权码]
- 社区小组链接：[表格 URL]
- 社区帖子采集：[结果表格 URL]
- 帖子链接：[新帖 URL 表格]
- 浏览器类型：八爪鱼浏览器
- 数量限制：500

**机器人 2 号：评论自动采集**

应用链接：https://rpa.bazhuayu.com/shareableLink/695ce9c38a592d87e24b1427

配置参数：
- 飞书授权码：[填入授权码]
- 帖子链接：[帖子 URL 表格]
- 帖子评论采集：[评论结果表格]
- 采集数量限制：300

---

## 📊 BI 数据看板设计

### 看板 1: 帖子采集总览

**指标卡**:
- 今日采集帖子数
- 命中关键词数
- 负面评价数 (预警)
- 平均情感得分

**图表**:
1. **声量趋势图** (折线图)
   - X 轴：日期
   - Y 轴：帖子数量
   - 分组：正/负/中性

2. **情感比例** (饼图)
   - positive: 绿色
   - negative: 红色
   - neutral: 灰色

3. **关键词热度** (柱状图)
   - X 轴：关键词
   - Y 轴：提及次数

4. **子社区分布** (饼图)
   - 各子社区发帖量占比

### 看板 2: 评论分析

**指标卡**:
- 今日评论数
- 负面评论数
- 平均评论情感

**图表**:
1. **评论情感趋势** (面积图)
2. **热门评论 TOP10** (表格)
3. **评论关键词词云**

### 看板 3: 预警中心

**自动通知规则**:
```
当 帖子情感=negative AND 点赞数>100 → 发送飞书消息
当 评论命中关键词 AND 情感=negative → 发送飞书消息
当 单帖子评论数>50 → 发送飞书消息 (热门讨论)
```

**通知模板**:
```
⚠️ Reddit 舆情预警

📌 标题：[帖子标题]
📊 情感：负面
📈 热度：156 点赞，89 评论
🏷️ 关键词：AI, 飞书
🔗 链接：[点击查看]

请及时处理！
```

---

## 🔧 OpenClaw 集成代码

### Feishu 多维表格写入函数

```python
def write_to_feishu(base_token, table_id, fields):
    """
    写入数据到 Feishu 多维表格
    
    Args:
        base_token: Base 令牌 (从 URL 提取)
        table_id: 表格 ID
        fields: 字段数据 (字典)
    
    Returns:
        记录 ID
    """
    # 使用 OpenClaw feishu_bitable_create_record 工具
    record = feishu_bitable_create_record(
        app_token=base_token,
        table_id=table_id,
        fields=fields
    )
    return record
```

### 完整集成示例

```python
# Reddit 监控 + Feishu 集成
from datetime import datetime

# 1. 执行监控
monitor = RedditMonitor()
result = monitor.run()

# 2. 写入 Feishu
for post in result['posts']:
    fields = {
        "帖子标题": post['title'],
        "情感倾向": post['sentiment'],
        "匹配关键词": ",".join(post['matched_keywords']),
        "子社区": post['subreddit'],
        "采集时间": datetime.now().isoformat(),
    }
    
    record_id = write_to_feishu(
        base_token="CtLhbbcyIaaxdxsBOfncNRcen0f",
        table_id="ldxbNBfEmkNkv5yD",
        fields=fields
    )
    
    print(f"✅ 写入记录：{record_id}")

# 3. 发送通知
if result['matched_posts']:
    message.send(
        channel="feishu",
        target="群组 ID",
        message=f"今日监控到 {len(result['matched_posts'])} 条相关内容"
    )
```

---

## ⚠️ 常见问题

### 问题 1: 授权码失效

**现象**: `Bad Request` 错误

**解决**:
```
1. 重新获取授权码
2. 更新 RPA 配置
3. 测试连接
```

### 问题 2: 写入限流

**现象**: `Too Many Requests`

**解决**:
```
- 单次写入 < 500 条
- 增加写入间隔 (1-2 秒)
- 使用批量写入 API
```

### 问题 3: 链接格式错误

**现象**: `JSONDecodeError`

**解决**:
```
确保使用 base/ 开头的链接:
✅ https://xxx.feishu.cn/base/ABC123...
❌ https://xxx.feishu.cn/wiki/ABC123...
```

---

## 📚 相关资源

- [[reddit_monitoring]] - Reddit 监控技能
- [[sentiment_analysis]] - 情感分析方法
- [[bi_dashboard]] - BI 看板设计

---

_创建时间：2026-02-25_
_作者：OpenClaw Agent_
