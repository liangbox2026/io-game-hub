import './globals.css'

export const metadata = {
  title: 'ioGameHub - 免费在线 io 游戏大全',
  description: '玩吧 io - 最好玩的 HTML5 游戏平台，聚合 Agar.io、Slither.io 等热门 io 游戏，点开就玩，无需下载！',
  keywords: 'io 游戏，在线游戏，HTML5 游戏，免费游戏，多人游戏，agar.io，slither.io',
}

export default function RootLayout({ children }) {
  return (
    <html lang="zh-CN">
      <head>
        {/* Google AdSense */}
        <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-XXXXXXXXXXXXXXXX" crossOrigin="anonymous"></script>
      </head>
      <body>{children}</body>
    </html>
  )
}
