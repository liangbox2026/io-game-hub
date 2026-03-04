import './globals.css'

export const metadata = {
  title: 'IO Game Hub - Free Online HTML5 Games',
  description: 'Play free online IO games instantly. Best HTML5 game platform with multiplayer games.',
  keywords: 'io games, online games, HTML5 games, free games, multiplayer games',
}

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <head>
        {/* Google AdSense - To be configured */}
        {/* <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-XXXXXXXXXXXXXXXX" crossOrigin="anonymous"></script> */}
      </head>
      <body>{children}</body>
    </html>
  )
}
