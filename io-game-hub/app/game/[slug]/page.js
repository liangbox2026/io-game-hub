import Link from 'next/link'
import { notFound } from 'next/navigation'
import { getGameBySlug, getGames } from '../../../lib/games'

// 生成静态参数（SSG）
export async function generateStaticParams() {
  const games = await getGames()
  return games.map((game) => ({
    slug: game.slug
  }))
}

// 生成页面元数据（SEO）
export async function generateMetadata({ params }) {
  const game = await getGameBySlug(params.slug)
  
  if (!game) {
    return {
      title: 'Game Not Found'
    }
  }

  return {
    title: `${game.title} - Play Free Online | IO Game Hub`,
    description: game.description,
    keywords: `${game.title}, ${game.category}, free online game, HTML5 game, io game, play instantly`,
    openGraph: {
      title: `${game.title} - Play Free`,
      description: game.description,
      type: 'website',
      images: game.thumbnail ? [game.thumbnail] : []
    },
    twitter: {
      card: 'summary_large_image',
      title: `${game.title} - Play Free`,
      description: game.description
    }
  }
}

// 游戏详情页
export default async function GamePage({ params }) {
  const game = await getGameBySlug(params.slug)

  if (!game) {
    notFound()
  }

  // 获取相关游戏推荐
  const allGames = await getGames()
  const relatedGames = allGames
    .filter(g => g.category === game.category && g.slug !== game.slug)
    .slice(0, 6)

  return (
    <main className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900">
      {/* 返回按钮 */}
      <div className="container mx-auto px-4 py-4">
        <Link 
          href="/"
          className="inline-flex items-center gap-2 text-purple-200 hover:text-white transition"
        >
          ← Back to Home
        </Link>
      </div>

      {/* 游戏区域 */}
      <section className="container mx-auto px-4 py-8">
        <div className="max-w-5xl mx-auto">
          {/* 游戏标题 */}
          <div className="text-center mb-8">
            <h1 className="text-4xl md:text-5xl font-bold text-white mb-4">
              {game.emoji} {game.title}
            </h1>
            <p className="text-purple-200 text-lg mb-4">
              {game.description}
            </p>
            
            {/* 游戏信息 */}
            <div className="flex flex-wrap justify-center gap-4 text-sm">
              <span className="px-3 py-1 bg-purple-500/30 rounded-full text-purple-200">
                📂 {game.category}
              </span>
              <span className="px-3 py-1 bg-purple-500/30 rounded-full text-purple-200">
                ⭐ {game.rating} / 5
              </span>
              <span className="px-3 py-1 bg-purple-500/30 rounded-full text-purple-200">
                👥 {game.players} players
              </span>
              {game.isNew && (
                <span className="px-3 py-1 bg-green-500/30 rounded-full text-green-200">
                  ✨ NEW
                </span>
              )}
              {game.isHot && (
                <span className="px-3 py-1 bg-red-500/30 rounded-full text-red-200">
                  🔥 HOT
                </span>
              )}
            </div>
          </div>

          {/* 游戏 iframe */}
          <div className="aspect-video bg-black rounded-xl overflow-hidden shadow-2xl mb-8">
            {game.iframeUrl ? (
              <iframe
                src={game.iframeUrl}
                className="w-full h-full"
                frameBorder="0"
                allowFullScreen
                allow="autoplay; fullscreen; gamepad; microphone"
                title={game.title}
              />
            ) : (
              <div className="flex items-center justify-center h-full text-white">
                <div className="text-center">
                  <div className="text-6xl mb-4">{game.emoji}</div>
                  <p>Game loading...</p>
                </div>
              </div>
            )}
          </div>

          {/* 广告位 - AdSense */}
          <div className="my-8">
            <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4 text-center text-purple-200">
              <p className="text-sm">📢 Advertisement</p>
              {/* AdSense 代码位置 */}
              <div className="mt-2 text-xs opacity-50">
                Ad slot - Replace with your AdSense code
              </div>
            </div>
          </div>

          {/* 游戏介绍 */}
          <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 mb-8">
            <h2 className="text-2xl font-bold text-white mb-4">
              About {game.title}
            </h2>
            <div className="text-purple-100 leading-relaxed space-y-4">
              <p>
                {game.longDescription || game.description}
              </p>
              
              <h3 className="text-xl font-bold text-white mt-6 mb-2">
                How to Play
              </h3>
              <ul className="list-disc list-inside space-y-1 text-purple-100">
                <li>Use arrow keys or WASD to move</li>
                <li>Mouse to aim and shoot</li>
                <li>Collect power-ups to upgrade your weapons</li>
                <li>Defeat enemies to earn points</li>
              </ul>

              <h3 className="text-xl font-bold text-white mt-6 mb-2">
                Game Features
              </h3>
              <ul className="list-disc list-inside space-y-1 text-purple-100">
                <li>Stunning graphics and visual effects</li>
                <li>Multiple game modes</li>
                <li>Global leaderboard</li>
                <li>Regular updates with new content</li>
              </ul>
            </div>
          </div>

          {/* 相关游戏 */}
          {relatedGames.length > 0 && (
            <div className="mb-8">
              <h2 className="text-2xl font-bold text-white mb-6">
                Related Games
              </h2>
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
                {relatedGames.map(relatedGame => (
                  <Link
                    key={relatedGame.id}
                    href={`/game/${relatedGame.slug}`}
                    className="bg-white/10 backdrop-blur-sm rounded-lg p-3 text-center hover:bg-white/20 transition"
                  >
                    <div className="text-3xl mb-2">{relatedGame.emoji}</div>
                    <div className="text-white text-sm font-medium truncate">
                      {relatedGame.title}
                    </div>
                    <div className="text-purple-300 text-xs mt-1">
                      {relatedGame.category}
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          )}
        </div>
      </section>

      {/* Footer */}
      <footer className="container mx-auto px-4 py-12 text-center text-purple-300">
        <p className="mb-4">
          © 2026 IO Game Hub. Play Free HTML5 Games!
        </p>
        <div className="flex justify-center gap-6 text-sm">
          <Link href="/about" className="hover:text-white transition">About</Link>
          <Link href="/privacy" className="hover:text-white transition">Privacy</Link>
          <Link href="/terms" className="hover:text-white transition">Terms</Link>
          <Link href="/contact" className="hover:text-white transition">Contact</Link>
        </div>
      </footer>

      {/* 结构化数据（SEO） */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            '@context': 'https://schema.org',
            '@type': 'VideoGame',
            name: game.title,
            description: game.description,
            genre: game.category,
            aggregateRating: {
              '@type': 'AggregateRating',
              ratingValue: game.rating,
              bestRating: '5',
              worstRating: '1',
              ratingCount: '100'
            },
            interactionCount: game.players,
            applicationCategory: 'Game',
            operatingSystem: 'Web Browser',
            offers: {
              '@type': 'Offer',
              price: '0',
              priceCurrency: 'USD'
            }
          })
        }}
      />
    </main>
  )
}
