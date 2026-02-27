// 游戏中心主脚本

// 开始游戏函数
function playGame(gameName) {
    console.log('Starting game:', gameName);
    alert(`🎮 正在加载 "${gameName}"...\n\n(这是演示页面，实际使用时会跳转到游戏页面或加载游戏框架)`);
}

// 搜索功能
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.querySelector('.search-input');
    const searchBtn = document.querySelector('.search-btn');
    const gameCards = document.querySelectorAll('.game-card');

    // 搜索按钮点击
    searchBtn.addEventListener('click', performSearch);
    
    // 回车搜索
    searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            performSearch();
        }
    });

    function performSearch() {
        const searchTerm = searchInput.value.toLowerCase().trim();
        
        gameCards.forEach(card => {
            const title = card.querySelector('.game-title').textContent.toLowerCase();
            const desc = card.querySelector('.game-desc').textContent.toLowerCase();
            
            if (title.includes(searchTerm) || desc.includes(searchTerm)) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }

    // 游戏卡片点击效果
    gameCards.forEach(card => {
        card.addEventListener('click', function(e) {
            if (!e.target.classList.contains('play-btn')) {
                const gameTitle = this.querySelector('.game-title').textContent;
                playGame(gameTitle);
            }
        });
    });

    // 添加简单的动画效果
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, { threshold: 0.1 });

    gameCards.forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.5s, transform 0.5s';
        observer.observe(card);
    });
});

// 模拟游戏数据（可用于动态加载）
const games = [
    { id: 1, name: '太空冒险', emoji: '🚀', desc: '探索宇宙，征服星系', category: 'action' },
    { id: 2, name: '极速赛车', emoji: '🏎️', desc: '感受速度与激情', category: 'racing' },
    { id: 3, name: '益智拼图', emoji: '🧩', desc: '挑战你的脑力', category: 'puzzle' },
    { id: 4, name: '勇者斗恶龙', emoji: '⚔️', desc: '成为传奇英雄', category: 'rpg' },
    { id: 5, name: '街头篮球', emoji: '🏀', desc: '成为灌篮高手', category: 'sports' },
    { id: 6, name: '神箭手', emoji: '🎯', desc: '百步穿杨的射击', category: 'shooting' }
];

// 动态加载游戏示例（未来扩展用）
function loadGames(gameList) {
    const gameGrid = document.querySelector('.game-grid');
    gameGrid.innerHTML = '';
    
    gameList.forEach(game => {
        const card = document.createElement('div');
        card.className = 'game-card';
        card.innerHTML = `
            <div class="game-thumb">
                <span class="game-emoji">${game.emoji}</span>
            </div>
            <h3 class="game-title">${game.name}</h3>
            <p class="game-desc">${game.desc}</p>
            <button class="play-btn" onclick="playGame('${game.name}')">开始游戏</button>
        `;
        gameGrid.appendChild(card);
    });
}

console.log('🎮 游戏中心已加载！');
