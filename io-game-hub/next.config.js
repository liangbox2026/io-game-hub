/** @type {import('next').NextConfig} */
const nextConfig = {
  // 允许嵌入外部游戏 iframe
  headers: async () => [
    {
      source: '/:path*',
      headers: [
        {
          key: 'X-Frame-Options',
          value: 'SAMEORIGIN'
        }
      ]
    }
  ],
  // 图片优化
  images: {
    domains: ['img.gamedistribution.com', 'images.crazygames.com']
  }
}

module.exports = nextConfig
