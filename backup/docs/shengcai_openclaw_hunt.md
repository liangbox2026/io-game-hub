# 🦞 生财有术 OpenClaw 帖子抓取 - 人工协助流程

**创建时间**: 2026-02-27 05:53 UTC  
**目标**: 抓取生财有术上所有关于 OpenClaw 的帖子

---

## ⚠️ 当前状态

**问题**: 生财有术需要登录才能查看内容  
**搜索结果**: 搜索页面跳转到登录页  
**解决方案**: 需要人工登录协助

---

## 📋 详细操作步骤

### 步骤 1: 打开生财有术网站

```
在浏览器中打开：https://scys.com/
```

### 步骤 2: 登录账号

- 输入你的生财有术账号和密码
- 完成登录

### 步骤 3: 搜索 OpenClaw 相关内容

**搜索关键词:**
1. `OpenClaw`
2. `小龙虾` (OpenClaw 的中文昵称)
3. `夙愿` (知名用户，写过 OpenClaw 实战文章)
4. `AI 员工`
5. `AI 助手`

**搜索方法:**
- 在网站顶部搜索框输入关键词
- 点击搜索按钮
- 浏览搜索结果

### 步骤 4: 筛选相关帖子

**优先查看:**
- ✅ 精华帖 (通常质量更高)
- ✅ 高回复数的帖子
- ✅ 最近发布的帖子
- ✅ 夙愿学长发布的文章

**可能的内容:**
- OpenClaw 安装教程
- OpenClaw 实战案例
- OpenClaw 配置分享
- OpenClaw 与其他工具对比
- OpenClaw 商业化应用

### 步骤 5: 抓取内容

**方法 A: 单个帖子抓取**
```bash
# 在每个帖子页面执行
./shengcai_scraper.sh grab --output=openclaw_post_01
./shengcai_scraper.sh grab --output=openclaw_post_02
# ...
```

**方法 B: 批量抓取 (推荐)**
```bash
# 1. 打开搜索结果的第一个帖子
# 2. 执行抓取
./shengcai_scraper.sh grab --output=openclaw_01

# 3. 手动切换到下一个帖子
# 4. 继续抓取
./shengcai_scraper.sh grab --output=openclaw_02

# 5. 重复直到所有相关帖子抓取完成
```

### 步骤 6: 整理内容

```bash
# 合并所有抓取的帖子
cat /root/.openclaw/workspace/backup/outputs/shengcai/openclaw_*.md > \
    /root/.openclaw/workspace/backup/outputs/shengcai/openclaw_all_$(date +%Y%m%d).md

# 统计
wc -l /root/.openclaw/workspace/backup/outputs/shengcai/openclaw_*.md
```

---

## 🎯 预期找到的内容

根据已知信息，可能找到:

### 1. 夙愿学长的实战文章
- **标题**: 半个月，烧了 500 美金，我终于把 OpenClaw 折腾成了真干活的 AI 员工
- **内容**: 完整的 OpenClaw 配置指南
- **价值**: ⭐⭐⭐⭐⭐ (已学习过)

### 2. 其他用户的实战分享
- OpenClaw 安装问题讨论
- OpenClaw 配置优化技巧
- OpenClaw 与其他 AI 工具对比
- OpenClaw 商业化案例

### 3. 最新更新
- OpenClaw 新版本特性
- OpenClaw 插件推荐
- OpenClaw 最佳实践

---

## 📊 抓取记录表

| 序号 | 帖子标题 | 作者 | 回复数 | 抓取文件 | 状态 |
|------|---------|------|--------|---------|------|
| 1 | [待填写] | | | openclaw_01.md | ⬜ |
| 2 | [待填写] | | | openclaw_02.md | ⬜ |
| 3 | [待填写] | | | openclaw_03.md | ⬜ |
| ... | ... | | | ... | ⬜ |

---

## 💡 高效技巧

### 1. 使用浏览器标签页
- 打开所有相关帖子到新标签页
- 逐个标签页执行抓取
- 避免反复搜索

### 2. 添加标签标记
```bash
# 在输出文件名中添加标签
./shengcai_scraper.sh grab --output=openclaw_教程_01
./shengcai_scraper.sh grab --output=openclaw_案例_01
./shengcai_scraper.sh grab --output=openclaw_讨论_01
```

### 3. 截图保存
```bash
# 抓取时同时截图
./shengcai_scraper.sh grab --output=openclaw_01 --full
```

---

## ⚠️ 注意事项

1. **遵守会员协议** - 内容仅供个人学习
2. **不要公开分享** - 尊重作者版权
3. **合理使用** - 不要高频抓取
4. **感谢作者** - 如果内容对你有帮助

---

## 📁 输出位置

```
/root/.openclaw/workspace/backup/outputs/shengcai/
├── openclaw_01.md
├── openclaw_02.md
├── openclaw_03.md
└── openclaw_all_20260227.md (合并文件)
```

---

## 🔄 后续处理

抓取完成后可以:

1. **整理为知识库**
   ```bash
   # 提取所有标题
   grep "^#" /root/.openclaw/workspace/backup/outputs/shengcai/openclaw_*.md | sort | uniq
   ```

2. **生成摘要**
   ```bash
   # 提取每个帖子的核心内容
   # 人工阅读并总结
   ```

3. **建立索引**
   ```bash
   # 创建索引文件
   cat > /root/.openclaw/workspace/backup/outputs/shengcai/README.md << 'EOF'
   # OpenClaw 帖子索引
   
   ## 教程类
   - openclaw_教程_01.md - [标题]
   
   ## 案例类
   - openclaw_案例_01.md - [标题]
   
   ## 讨论类
   - openclaw_讨论_01.md - [标题]
   EOF
   ```

---

**现在请按照上述步骤操作，完成后告诉我！** 🦞
