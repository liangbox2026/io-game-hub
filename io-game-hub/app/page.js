import Link from 'next/link'
import { getGames, getCategories } from '../lib/games'

export default async function Home() {
  // 服务端获取游戏数据（SEO 友好）
  const games = await getGames()
  const categories = await getCategories()

  // 分类筛选
  const newGames = games.filter(g => g.isNew).slice(0, 8)
  const hotGames = games.filter(g => g.isHot).slice(0, 8)

  return (
    <main className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900">
      {/* Hero Section */}
      <section className="container mx-auto px-4 py-16 text-center">
        <h1 className="text-5xl md:text-6xl font-bold text-white mb-4">
          🎮 IO Game Hub
        </h1>
        <p className="text-xl text-purple-200 mb-8">
          Free Online HTML5 Games - Play Instantly!
        </p>
        
        {/* 分类导航 */}
        <div className="flex flex-wrap justify-center gap-3 mb-8">
          <Link 
            href="/"
            className="px-4 py-2 bg-white/10 hover:bg-white/20 rounded-full text-white transition"
          >
            All Games
          </Link>
          {categories.map(cat => (
            <Link
              key={cat}
              href={`/category/${cat.toLowerCase().replace(/\s+/g, '-')}`}
              className="px-4 py-2 bg-white/10 hover:bg-white/20 rounded-full text-white transition"
            >
              {cat}
            </Link>
          ))}
        </div>
      </section>

      {/* 热门游戏 */}
      <section className="container mx-auto px-4 py-8">
        <h2 className="text-3xl font-bold text-white mb-6 flex items-center gap-2">
          🔥 Hot Games
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {hotGames.map(game => (
            <GameCard key={game.id} game={game} />
          ))}
        </div>
      </section>

      {/* 新游戏 */}
      <section className="container mx-auto px-4 py-8">
        <h2 className="text-3xl font-bold text-white mb-6 flex items-center gap-2">
          ✨ New Games
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {newGames.map(game => (
            <GameCard key={game.id} game={game} />
          ))}
        </div>
      </section>

      {/* 全部游戏 */}
      <section className="container mx-auto px-4 py-8">
        <h2 className="text-3xl font-bold text-white mb-6 flex items-center gap-2">
          🎯 All Games ({games.length})
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {games.map(game => (
            <GameCard key={game.id} game={game} />
          ))}
        </div>
      </section>

      {/* Footer */}
      <footer className="container mx-auto px-4 py-12 text-center text-purple-300">
        <p className="mb-4">
          © 2026 IO Game Hub. Free HTML5 Games for Everyone!
        </p>
        <div className="flex justify-center gap-6 text-sm">
          <Link href="/about" className="hover:text-white transition">About</Link>
          <Link href="/privacy" className="hover:text-white transition">Privacy</Link>
          <Link href="/terms" className="hover:text-white transition">Terms</Link>
          <Link href="/contact" className="hover:text-white transition">Contact</Link>
        </div>
      </footer>
    </main>
  )
}

// 游戏卡片组件
function GameCard({ game }) {
  return (
    <Link href={`/game/${game.slug}`} className="group">
      <div className="bg-white/10 backdrop-blur-sm rounded-xl overflow-hidden hover:bg-white/20 transition-all duration-300 hover:scale-105 hover:shadow-2xl">
        {/* 游戏封面 */}
        <div className="aspect-video bg-gradient-to-br from-purple-500 to-blue-500 flex items-center justify-center text-6xl">
          {game.emoji}
        </div>
        
        {/* 游戏信息 */}
        <div className="p-4">
          <h3 className="text-white font-bold text-lg mb-2 group-hover:text-purple-300 transition">
            {game.title}
          </h3>
          
          <p className="text-purple-200 text-sm mb-3 line-clamp-2">
            {game.description}
          </p>
          
          {/* 标签 */}
          <div className="flex items-center justify-between text-xs">
            <span className="px-2 py-1 bg-purple-500/30 rounded text-purple-200">
              {game.category}
            </span>
            <div className="flex items-center gap-2 text-purple-300">
              <span>⭐ {game.rating}</span>
              <span>👥 {game.players}</span>
            </div>
          </div>
          
          {/* 新游/热门标签 */}
          {game.isNew && (
            <span className="absolute top-2 right-2 px-2 py-1 bg-green-500 text-white text-xs rounded">
              NEW
            </span>
          )}
          {game.isHot && (
            <span className="absolute top-2 right-2 px-2 py-1 bg-red-500 text-white text-xs rounded">
              HOT
            </span>
          )}
        </div>
      </div>
    </Link>
  )
}
