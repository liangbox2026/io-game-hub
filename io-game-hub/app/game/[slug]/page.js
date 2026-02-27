import Link from 'next/link'

// 模拟游戏数据（实际可从数据库/API 获取）
const games = {
  'space-impact': {
    title: '太空冲击',
    slug: 'space-impact',
    emoji: '🚀',
    description: '驾驶你的战舰，在浩瀚宇宙中与外星敌人展开激烈战斗！升级武器系统，解锁新飞船，成为太空霸主。',
    category: '射击',
    rating: 4.5,
    players: '12,345',
    releaseDate: '2026-01-15',
    developer: 'Space Games Studio',
    iframeUrl: 'https://html5.gamedistribution.com/rvvASMiM/5e6f6f0e0e0e4e0e8e0e0e0e0e0e0e0e/',
    longDescription: `
      太空冲击是一款激动人心的太空射击游戏，玩家将扮演一名星际战舰指挥官，在广袤的宇宙中与各种外星敌人作战。

      【游戏特色】
      • 精美的太空场景和炫酷的特效
      • 多种战舰可选，每种都有独特技能
      • 丰富的武器升级系统
      • 挑战性的关卡设计
      • 支持全球玩家排行榜

      【操作说明】
      • WASD 或方向键：移动战舰
      • 鼠标：瞄准
      • 左键：射击
      • 空格键：释放技能

      【游戏技巧】
      1. 优先升级主武器，提高输出能力
      2. 注意躲避敌人子弹，生存第一
      3. 收集能量宝石解锁新战舰
      4. 每日登录领取奖励
    `
  }
}

export async function generateStaticParams() {
  return Object.keys(games).map((slug) => ({
    slug: slug
  }))
}

export async function generateMetadata({ params }) {
  const game = games[params.slug]
  return {
    title: `${game.title} - 免费在线玩 | ioGameHub`,
    description: game.description,
    keywords: `${game.title}, ${game.category}游戏，io 游戏，在线游戏，免费游戏`
  }
}

export default function GamePage({ params }) {
  const game = games[params.slug]

  if (!game) {
    return <div>游戏未找到</div>
  }

  // 结构化数据（SEO）
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "VideoGame",
    "name": game.title,
    "description": game.description,
    "genre": game.category,
    "applicationCategory": "Game",
    "operatingSystem": "Web Browser",
    "gamePlatform": "HTML5",
    "aggregateRating": {
      "@type": "AggregateRating",
      "ratingValue": game.rating,
      "bestRating": "5",
      "worstRating": "1",
      "ratingCount": "1000"
    }
  }

  return (
    <div>
      {/* 顶部导航 */}
      <header className="header">
        <div className="container">
          <Link href="/" className="logo">🎮 ioGameHub</Link>
          <nav className="nav">
            <Link href="/" className="nav-link">首页</Link>
            <Link href="/games" className="nav-link">全部游戏</Link>
            <Link href="/new" className="nav-link">新游</Link>
            <Link href="/popular" className="nav-link">热门</Link>
          </nav>
        </div>
      </header>

      {/* 游戏页面 */}
      <div className="game-page">
        {/* 游戏头部信息 */}
        <div className="game-header">
          <div className="game-cover">
            <div style={{
              width: '100%',
              height: '100%',
              background: 'linear-gradient(135deg, #7c3aed, #ec4899)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '120px'
            }}>
              {game.emoji}
            </div>
          </div>
          <div className="game-details">
            <h1>{game.title}</h1>
            <div className="meta">
              <span>⭐ {game.rating} / 5.0</span>
              <span>👥 {game.players} 玩家</span>
              <span>📅 {game.releaseDate}</span>
              <span>🏷️ {game.category}</span>
            </div>
            <p className="description">{game.description}</p>
            <Link href="#" className="play-btn" style={{display: 'inline-block', width: 'auto', padding: '15px 40px'}}>
              ▶️ 开始游戏
            </Link>
          </div>
        </div>

        {/* 游戏 iframe */}
        <div className="game-frame-container">
          <iframe 
            className="game-frame"
            src={game.iframeUrl}
            title={game.title}
            allowFullScreen
            allow="autoplay; fullscreen; microphone; camera"
          />
        </div>

        {/* 游戏介绍（SEO 内容） */}
        <div className="game-content">
          <h2>🎮 关于{game.title}</h2>
          {game.longDescription.split('\n').map((paragraph, index) => (
            paragraph.trim() && <p key={index}>{paragraph}</p>
          ))}
        </div>

        {/* 相关游戏 */}
        <div className="game-content">
          <h2>🎯 相关游戏推荐</h2>
          <div className="game-grid" style={{gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))'}}>
            {Object.values(games).filter(g => g.slug !== game.slug).slice(0, 3).map((g) => (
              <Link key={g.slug} href={`/game/${g.slug}`} className="game-card">
                <div className="game-thumb" style={{height: '120px'}}>
                  <span className="game-emoji" style={{fontSize: '50px'}}>{g.emoji}</span>
                </div>
                <div className="game-info" style={{padding: '10px'}}>
                  <h3 className="game-title" style={{fontSize: '14px'}}>{g.title}</h3>
                  <span className="game-rating">⭐ {g.rating}</span>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </div>

      {/* 页脚 */}
      <footer className="footer">
        <div className="container">
          <p>© 2026 ioGameHub - 免费在线 io 游戏平台</p>
          <div className="footer-links">
            <a href="#">关于我们</a>
            <a href="#">联系方式</a>
            <a href="#">隐私政策</a>
            <a href="#">广告合作</a>
          </div>
        </div>
      </footer>

      {/* SEO 结构化数据 */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }}
      />
    </div>
  )
}
