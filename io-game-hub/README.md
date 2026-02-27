# ioGameHub - HTML5 游戏平台

免费在线 io 游戏聚合站，基于 Next.js 构建。

## 🚀 快速开始

### 1. 安装依赖

```bash
cd /root/.openclaw/workspace/io-game-hub
npm install
```

### 2. 本地开发

```bash
npm run dev
# 访问 http://localhost:3000
```

### 3. 构建生产版本

```bash
npm run build
npm start
```

## 📁 项目结构

```
io-game-hub/
├── app/
│   ├── layout.js          # 全局布局（含 SEO meta）
│   ├── page.js            # 首页
│   ├── game/
│   │   └── [slug]/
│   │       └── page.js    # 游戏详情页（动态路由）
│   └── globals.css        # 全局样式
├── public/
│   └── games/             # 游戏缩略图
├── lib/
│   └── games.js           # 游戏数据（可替换为 API）
├── package.json
└── next.config.js
```

## 🎮 添加新游戏

### 方法 1：手动添加（推荐新手）

1. 在 `app/game/[slug]/page.js` 的 `games` 对象中添加：

```javascript
const games = {
  'your-game-slug': {
    title: '游戏名称',
    slug: 'your-game-slug',
    emoji: '🎮',
    description: '简短描述（100 字内）',
    category: '分类',
    rating: 4.5,
    players: '1,000',
    releaseDate: '2026-02-26',
    developer: '开发者',
    iframeUrl: 'https://html5.gamedistribution.com/xxx/',
    longDescription: `
      详细介绍（500 字以上，用于 SEO）
      
      【游戏特色】
      • 特色 1
      • 特色 2
      
      【操作说明】
      • 控制方式
      
      【游戏技巧】
      1. 技巧 1
      2. 技巧 2
    `
  }
}
```

2. 在 `app/page.js` 的 `games` 数组中添加首页展示

3. 重新部署即可

### 方法 2：从 GameDistribution API 获取

```javascript
// lib/games.js
export async function getGames() {
  const res = await fetch('https://api.gamedistribution.com/games')
  return res.json()
}
```

## 💰 广告配置

### Google AdSense

1. 注册 AdSense: https://adsense.google.com
2. 获取发布商 ID: `ca-pub-XXXXXXXXXXXXXXXX`
3. 替换 `app/layout.js` 中的 ID

### AdSense 广告位建议

```javascript
// 在游戏页 iframe 上方/下方添加
<div className="ad-slot">
  <ins className="adsbygoogle"
       style={{display:'block'}}
       data-ad-client="ca-pub-XXX"
       data-ad-slot="XXX"
       data-ad-format="auto"></ins>
  <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
</div>
```

## 🌐 部署到 Vercel

### 步骤 1：推送代码到 GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/yourname/io-game-hub.git
git push -u origin main
```

### 步骤 2：Vercel 部署

1. 访问 https://vercel.com
2. 注册/登录账号
3. 点击 "New Project"
4. 导入 GitHub 仓库
5. 点击 "Deploy"
6. 获得公网链接！

### 自定义域名（可选）

1. 购买域名（Namecheap/GoDaddy）
2. Vercel 设置中添加域名
3. 配置 DNS 记录

## 📊 SEO 优化清单

- [x] 每款游戏独立详情页
- [x] 500+ 字原创游戏介绍
- [x] 结构化数据（VideoGame schema）
- [x] Meta 标题/描述优化
- [x] 语义化 URL（/game/space-impact）
- [x] 内部链接（相关游戏推荐）
- [ ] 添加用户评论（UGC 内容）
- [ ] 添加游戏攻略文章
- [ ] 提交 sitemap 到 Google

## 📈 数据分析

### Google Analytics

```javascript
// app/layout.js
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script
  dangerouslySetInnerHTML={{
    __html: `
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', 'G-XXXXXXXXXX');
    `
  }}
/>
```

## 🛠️ 技术栈

- **框架**: Next.js 14 (App Router)
- **语言**: JavaScript (可升级 TypeScript)
- **样式**: CSS Modules
- **部署**: Vercel
- **游戏源**: GameDistribution API

## 📝 待办事项

- [ ] 添加用户评论系统
- [ ] 集成 GameDistribution API
- [ ] 添加游戏收藏功能
- [ ] 用户登录系统
- [ ] 游戏排行榜
- [ ] 多语言支持

## 📄 许可证

MIT
