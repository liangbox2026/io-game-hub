/**
 * 游戏数据管理
 * 支持两种模式：
 * 1. GameDistribution API（推荐）
 * 2. 本地配置（备用）
 */

// GameDistribution API 配置
const GD_API_URL = 'https://api.gamedistribution.com/v2/games';
const GD_API_KEY = process.env.NEXT_PUBLIC_GD_API_KEY || '';

// 本地备用游戏数据（API 失败时使用）
const LOCAL_GAMES = [
  {
    id: 'space-impact',
    title: 'Space Impact',
    slug: 'space-impact',
    emoji: '🚀',
    description: 'Drive your warship and destroy alien enemies',
    category: 'Shooting',
    rating: 4.8,
    players: '12.5k',
    isNew: true,
    isHot: false
  },
  {
    id: 'snake-io',
    title: 'Snake.io',
    slug: 'snake-io',
    emoji: '🐍',
    description: 'Classic snake game with multiplayer battle',
    category: 'Casual',
    rating: 4.9,
    players: '50.2k',
    isNew: false,
    isHot: true
  },
  {
    id: 'paper-io',
    title: 'Paper.io',
    slug: 'paper-io',
    emoji: '📄',
    description: 'Conquer territory and become the biggest',
    category: 'Strategy',
    rating: 4.7,
    players: '35.8k',
    isNew: true,
    isHot: false
  },
  {
    id: 'basket-random',
    title: 'Basket Random',
    slug: 'basket-random',
    emoji: '🏀',
    description: 'Funny physics basketball battle',
    category: 'Sports',
    rating: 4.6,
    players: '28.3k',
    isNew: false,
    isHot: true
  },
  {
    id: 'surviv-io',
    title: 'Surviv.io',
    slug: 'surviv-io',
    emoji: '🔫',
    description: '2D battle royale shooter',
    category: 'Shooting',
    rating: 4.5,
    players: '45.1k',
    isNew: false,
    isHot: true
  },
  {
    id: 'skribbl-io',
    title: 'Skribbl.io',
    slug: 'skribbl-io',
    emoji: '🎨',
    description: 'Multiplayer drawing and guessing game',
    category: 'Casual',
    rating: 4.9,
    players: '60.5k',
    isNew: true,
    isHot: false
  },
  {
    id: 'krunker',
    title: 'Krunker',
    slug: 'krunker',
    emoji: '⚔️',
    description: 'Fast-paced first-person shooter',
    category: 'Shooting',
    rating: 4.7,
    players: '42.0k',
    isNew: false,
    isHot: true
  },
  {
    id: 'hole-io',
    title: 'Hole.io',
    slug: 'hole-io',
    emoji: '⚫',
    description: 'Eat everything to become the biggest hole',
    category: 'Casual',
    rating: 4.6,
    players: '38.7k',
    isNew: false,
    isHot: false
  }
];

/**
 * 从 GameDistribution API 获取游戏
 * @returns {Promise<Array>} 游戏列表
 */
export async function getGamesFromAPI() {
  try {
    if (!GD_API_KEY) {
      console.log('⚠️ No API key, using local games');
      return LOCAL_GAMES;
    }

    const response = await fetch(GD_API_URL, {
      headers: {
        'Authorization': `Bearer ${GD_API_KEY}`,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    const data = await response.json();
    
    // 转换 API 数据格式
    return data.games?.slice(0, 50).map(game => ({
      id: game.id,
      title: game.title,
      slug: game.id,
      emoji: getGameEmoji(game.categories?.[0] || 'Action'),
      description: game.description?.slice(0, 100) || 'Exciting HTML5 game',
      category: game.categories?.[0] || 'Action',
      rating: game.rating || 4.0,
      players: formatPlayers(game.plays || 0),
      isNew: game.releaseDate && isNewGame(game.releaseDate),
      isHot: (game.plays || 0) > 10000,
      iframeUrl: `https://html5.gamedistribution.com/${game.id}/`,
      thumbnail: game.assets?.thumbnail || null,
      releaseDate: game.releaseDate
    }));
  } catch (error) {
    console.error('Failed to fetch games from API:', error);
    return LOCAL_GAMES;
  }
}

/**
 * 获取所有游戏（优先 API，失败则本地）
 */
export async function getGames() {
  return getGamesFromAPI();
}

/**
 * 根据 slug 获取单个游戏
 */
export async function getGameBySlug(slug) {
  const games = await getGames();
  return games.find(g => g.slug === slug);
}

/**
 * 获取游戏分类
 */
export async function getCategories() {
  const games = await getGames();
  const categories = [...new Set(games.map(g => g.category))];
  return categories;
}

/**
 * 根据分类筛选游戏
 */
export async function getGamesByCategory(category) {
  const games = await getGames();
  return games.filter(g => g.category === category);
}

// 辅助函数

function getGameEmoji(category) {
  const emojis = {
    'Action': '⚔️',
    'Shooting': '🔫',
    'Casual': '🎮',
    'Strategy': '🧠',
    'Sports': '⚽',
    'Racing': '🏎️',
    'Puzzle': '🧩',
    'Adventure': '🗺️',
    'Girls': '👧',
    'Kids': '👶'
  };
  return emojis[category] || '🎮';
}

function formatPlayers(plays) {
  if (plays >= 1000000) {
    return (plays / 1000000).toFixed(1) + 'M';
  } else if (plays >= 1000) {
    return (plays / 1000).toFixed(1) + 'k';
  }
  return plays.toString();
}

function isNewGame(releaseDate) {
  const date = new Date(releaseDate);
  const now = new Date();
  const diffTime = Math.abs(now - date);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  return diffDays < 90; // 3 个月内算新游戏
}

// 导出本地游戏（备用）
export { LOCAL_GAMES };
