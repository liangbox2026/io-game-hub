import Link from 'next/link'

// 游戏数据
const games = [
  {
    id: 'space-impact',
    title: '太空冲击',
    slug: 'space-impact',
    emoji: '🚀',
    description: '驾驶战舰，消灭外星敌人',
    category: '射击',
    rating: 4.8,
    players: '12.5k',
    isNew: true,
    isHot: false
  },
  {
    id: 'snake-io',
    title: '蛇蛇大作战',
    slug: 'snake-io',
    emoji: '🐍',
    description: '经典贪吃蛇多人对战版',
    category: '休闲',
    rating: 4.9,
    players: '50.2k',
    isNew: false,
    isHot: true
  },
  {
    id: 'paper-io',
    title: '纸片 io',
    slug: 'paper-io',
    emoji: '📄',
    description: '圈地占领，成为最大领主',
    category: '策略',
    rating: 4.7,
    players: '35.8k',
    isNew: true,
    isHot: false
  },
  {
    id: 'basket-random',
    title: '篮球随机',
    slug: 'basket-random',
    emoji: '🏀',
    description: '搞笑物理篮球对战',
    category: '体育',
    rating: 4.6,
    players: '28.3k',
    isNew: false,
    isHot: true
  },
  {
    id: 'surviv-io',
    title: '生存 io',
    slug: 'surviv-io',
    emoji: '🔫',
    description: '2D 大逃杀射击游戏',
    category: '射击',
    rating: 4.5,
    players: '45.1k',
    isNew: false,
    isHot: true
  },
  {
    id: 'skribbl-io',
    title: '你画我猜',
    slug: 'skribbl-io',
    emoji: '🎨',
    description: '多人在线你画我猜',
    category: '休闲',
    rating: 4.9,
    players: '60.5k',
    isNew: true,
    isHot: false
  },
  {
    id: 'krunker',
    title: 'Krunker 射击',
    slug: 'krunker',
    emoji: '⚔️',
    description: '快节奏第一人称射击',
    category: '射击',
    rating: 4.7,
    players: '42.0k',
    isNew: false,
    isHot: true
  },
  {
    id: 'hole-io',
    title: '黑洞大作战',
    slug: 'hole-io',
    emoji: '⚫',
    description: '吞噬一切成为最大黑洞',
    category: '休闲',
    rating: 4.6,
    players: '38.7k',
    isNew: false,
    isHot: false
  }
]

const categories = [
  { name: '全部', count: 156, icon: '🎮' },
  { name: '射击', count: 42, icon: '🔫' },
  { name: '休闲', count: 38, icon: '🎯' },
  { name: '策略', count: 25, icon: '🧠' },
  { name: '体育', count: 18, icon: '⚽' },
  { name: '赛车', count: 15, icon: '🏎️' },
  { name: '益智', count: 18, icon: '🧩' }
]

const popularGames = games.slice(0, 5)

export default function Home() {
  return (
    <div>
      {/* 顶部导航 */}
      <header className="header">
        <div className="container">
          <Link href="/" className="logo">🎮 ioGameHub</Link>
          <nav className="nav">
            <Link href="/" className="nav-link active">首页</Link>
            <Link href="/games" className="nav-link">全部游戏</Link>
            <Link href="/new" className="nav-link">新游</Link>
            <Link href="/popular" className="nav-link">热门</Link>
          </nav>
          <div className="header-actions">
            <button className="btn btn-secondary">🔔</button>
            <button className="btn btn-primary">👤 登录</button>
          </div>
        </div>
      </header>

      {/* 搜索区域 */}
      <section className="search-section">
        <div className="container">
          <div className="search-box">
            <input 
              type="text" 
              className="search-input" 
              placeholder="搜索 5000+ 款游戏..."
            />
            <button className="search-btn">🔍 搜索</button>
          </div>
        </div>
      </section>

      {/* 主布局 */}
      <div className="container-wide">
        <div className="main-layout">
          
          {/* 左侧边栏 - 分类 */}
          <aside className="sidebar">
            <div className="sidebar-card">
              <h3 className="sidebar-title">📂 游戏分类</h3>
              <div className="category-list">
                {categories.map((cat, index) => (
                  <Link 
                    key={cat.name}
                    href={index === 0 ? '/' : `/category/${cat.name}`}
                    className={`category-item ${index === 0 ? 'active' : ''}`}
                  >
                    <span>{cat.icon} {cat.name}</span>
                    <span className="category-count">{cat.count}</span>
                  </Link>
                ))}
              </div>
            </div>

            {/* 广告位 - 侧边 */}
            <div className="ad-slot">
              <div className="ad-label">广告</div>
              <div className="ad-placeholder">
                300x250 广告位<br/>
                Google AdSense
              </div>
            </div>
          </aside>

          {/* 中间内容区 */}
          <main className="content">
            
            {/* 顶部广告横幅 */}
            <div className="top-ad-banner">
              <div className="ad-label">广告</div>
              <div className="ad-banner-728x90">
                728x90 横幅广告位 - Google AdSense
              </div>
            </div>

            {/* 热门游戏 */}
            <section>
              <div className="section-header">
                <h2 className="section-title">🔥 热门游戏</h2>
                <Link href="/games" className="view-all">查看全部 →</Link>
              </div>
              <div className="game-grid">
                {games.filter(g => g.isHot).map((game) => (
                  <Link key={game.id} href={`/game/${game.slug}`} className="game-card">
                    <div className="game-thumb">
                      <span className="game-emoji">{game.emoji}</span>
                      <span className="game-badge hot">🔥 热门</span>
                      <span className="game-rating-badge">⭐ {game.rating}</span>
                    </div>
                    <div className="game-info">
                      <h3 className="game-title">{game.title}</h3>
                      <p className="game-desc">{game.description}</p>
                      <div className="game-meta">
                        <span className="game-players">{game.players}</span>
                        <span className="play-indicator">▶️ 开始</span>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </section>

            {/* 新游推荐 */}
            <section>
              <div className="section-header">
                <h2 className="section-title">🆕 新游推荐</h2>
                <Link href="/new" className="view-all">查看更多 →</Link>
              </div>
              <div className="game-grid">
                {games.filter(g => g.isNew).map((game) => (
                  <Link key={game.id} href={`/game/${game.slug}`} className="game-card">
                    <div className="game-thumb">
                      <span className="game-emoji">{game.emoji}</span>
                      <span className="game-badge new">NEW</span>
                      <span className="game-rating-badge">⭐ {game.rating}</span>
                    </div>
                    <div className="game-info">
                      <h3 className="game-title">{game.title}</h3>
                      <p className="game-desc">{game.description}</p>
                      <div className="game-meta">
                        <span className="game-players">{game.players}</span>
                        <span className="play-indicator">▶️ 开始</span>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </section>

            {/* 全部游戏 */}
            <section>
              <div className="section-header">
                <h2 className="section-title">🎮 全部游戏</h2>
                <Link href="/games" className="view-all">浏览全部 →</Link>
              </div>
              <div className="game-grid">
                {games.map((game) => (
                  <Link key={game.id} href={`/game/${game.slug}`} className="game-card">
                    <div className="game-thumb">
                      <span className="game-emoji">{game.emoji}</span>
                      {game.isNew && <span className="game-badge new">NEW</span>}
                      {game.isHot && <span className="game-badge hot">🔥</span>}
                      <span className="game-rating-badge">⭐ {game.rating}</span>
                    </div>
                    <div className="game-info">
                      <h3 className="game-title">{game.title}</h3>
                      <p className="game-desc">{game.description}</p>
                      <div className="game-meta">
                        <span className="game-players">{game.players}</span>
                        <span className="play-indicator">▶️ 开始</span>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </section>

          </main>

          {/* 右侧边栏 - 广告 + 热门 */}
          <aside className="right-sidebar">
            
            {/* 广告位 1 */}
            <div className="ad-slot">
              <div className="ad-label">赞助广告</div>
              <div className="ad-banner">
                300x600 竖版广告<br/>
                Google AdSense
              </div>
            </div>

            {/* 热门排行榜 */}
            <div className="sidebar-card">
              <h3 className="sidebar-title">🏆 本周排行</h3>
              <div className="popular-list">
                {popularGames.map((game, index) => (
                  <Link key={game.id} href={`/game/${game.slug}`} className="popular-item">
                    <span className={`popular-rank top-${index + 1}`}>
                      {index + 1}
                    </span>
                    <div className="popular-info">
                      <div className="popular-title">{game.title}</div>
                      <div className="popular-meta">
                        <span>⭐ {game.rating}</span>
                        <span>👥 {game.players}</span>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </div>

            {/* 广告位 2 */}
            <div className="ad-slot">
              <div className="ad-label">广告</div>
              <div className="ad-placeholder">
                300x250 广告位<br/>
                Google AdSense
              </div>
            </div>

          </aside>

        </div>
      </div>

      {/* 页脚 */}
      <footer className="footer">
        <div className="container">
          <div className="footer-content">
            <div className="footer-brand">
              <div className="footer-logo">🎮 ioGameHub</div>
              <p className="footer-desc">
                最好的免费在线 HTML5 游戏平台，聚合全球热门 io 游戏，点开就玩，无需下载！
              </p>
            </div>
            <div>
              <h4 className="footer-title">游戏</h4>
              <div className="footer-links">
                <a href="#">全部游戏</a>
                <a href="#">新游推荐</a>
                <a href="#">热门排行</a>
                <a href="#">游戏分类</a>
              </div>
            </div>
            <div>
              <h4 className="footer-title">支持</h4>
              <div className="footer-links">
                <a href="#">关于我们</a>
                <a href="#">联系方式</a>
                <a href="#">游戏提交</a>
                <a href="#">帮助中心</a>
              </div>
            </div>
            <div>
              <h4 className="footer-title">法律</h4>
              <div className="footer-links">
                <a href="#">隐私政策</a>
                <a href="#">使用条款</a>
                <a href="#">Cookie 政策</a>
                <a href="#">广告合作</a>
              </div>
            </div>
          </div>
          <div className="footer-bottom">
            <p>© 2026 ioGameHub. All rights reserved.</p>
            <div className="social-links">
              <a href="#" className="social-link">📘</a>
              <a href="#" className="social-link">🐦</a>
              <a href="#" className="social-link">📸</a>
              <a href="#" className="social-link">📺</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}
