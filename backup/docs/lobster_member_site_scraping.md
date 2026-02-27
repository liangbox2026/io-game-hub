# 🦞 Lobster 服务器通过浏览器爬取会员网站指南

_使用 Lobster + Browser 工具访问和爬取需要登录的网站内容_

---

## 📋 前置要求

### 1. Lobster 服务器配置

```bash
# 检查 Lobster 是否已安装
openclaw plugins list | grep lobster

# 如果未安装，启用 Lobster 插件
openclaw plugins enable lobster
```

### 2. Browser 工具配置

```bash
# 检查 browser 工具状态
openclaw browser status

# 如果需要，启动 browser
openclaw browser start
```

### 3. 本地浏览器要求

- ✅ Chrome/Chromium 80+
- ✅ 或 Firefox 75+
- ✅ 或配置无头模式

---

## 🎯 完整工作流程

### 步骤 1: 准备工作

```bash
# 1. 确认目标网站
TARGET_URL="https://example.com/member-content"

# 2. 准备登录凭证 (⚠️ 安全存储)
USERNAME="your_username"
PASSWORD="your_password"

# 3. 创建凭证文件 (加密存储)
echo "$USERNAME" > ~/.openclaw/credentials/example_user.txt
echo "$PASSWORD" > ~/.openclaw/credentials/example_pass.txt
chmod 600 ~/.openclaw/credentials/example_*
```

---

### 步骤 2: 使用 Lobster 创建工作流

```bash
# Lobster 工作流定义
lobster create --name="member_site_scraper" << 'EOF'
{
  "name": "会员网站爬取",
  "steps": [
    {
      "name": "打开登录页面",
      "action": "browser.open",
      "url": "https://example.com/login"
    },
    {
      "name": "输入用户名",
      "action": "browser.type",
      "ref": "username",
      "text": "${USERNAME}"
    },
    {
      "name": "输入密码",
      "action": "browser.type",
      "ref": "password",
      "text": "${PASSWORD}"
    },
    {
      "name": "点击登录",
      "action": "browser.click",
      "ref": "login_button"
    },
    {
      "name": "等待加载",
      "action": "browser.wait",
      "timeMs": 3000
    },
    {
      "name": "导航到目标页面",
      "action": "browser.open",
      "url": "https://example.com/member-content"
    },
    {
      "name": "抓取内容",
      "action": "browser.snapshot",
      "output": "content.md"
    },
    {
      "name": "退出登录",
      "action": "browser.click",
      "ref": "logout_button"
    }
  ]
}
EOF
```

---

### 步骤 3: 手动浏览器接管方案

如果 Lobster 自动化失败，可以人工接管：

```bash
# 1. 启动有头浏览器
openclaw browser start --profile=openclaw --headless=false

# 2. 打开控制仪表板
openclaw browser dashboard

# 3. 人工登录网站
# - 在浏览器中手动打开目标网站
# - 输入账号密码登录
# - 导航到目标页面

# 4. 使用 browser 工具抓取
browser --action=snapshot --format=markdown

# 5. 或使用截图 + OCR
browser --action=screenshot --fullPage=true
# 然后用 OCR 工具识别图片内容
```

---

### 步骤 4: Cookie 持久化方案

```bash
# 1. 首次人工登录
# - 启动浏览器
# - 手动登录网站
# - 保持登录状态

# 2. 导出 Cookie
# 方法 1: 使用浏览器扩展
# - 安装 "EditThisCookie" 或类似扩展
# - 导出 Cookie 为 JSON

# 方法 2: 使用开发者工具
# - F12 打开开发者工具
# - Application → Cookies
# - 复制 Cookie 值

# 3. 保存 Cookie
cat > ~/.openclaw/cookies/example.com.json << 'EOF'
[
  {
    "name": "session_id",
    "value": "your_session_value",
    "domain": ".example.com",
    "path": "/",
    "expiry": 1709251200
  }
]
EOF

# 4. 在 Lobster 工作流中使用
lobster run --cookies=~/.openclaw/cookies/example.com.json
```

---

## 🔧 实用脚本

### 脚本 1: 自动登录抓取

```bash
#!/bin/bash
# member_site_scraper.sh

set -e

# 配置
TARGET_URL="$1"
USERNAME_FILE="$2"
PASSWORD_FILE="$3"
OUTPUT_DIR="/root/.openclaw/workspace/backup/logs"
DATE=$(date +%Y-%m-%d)

# 读取凭证
USERNAME=$(cat "$USERNAME_FILE")
PASSWORD=$(cat "$PASSWORD_FILE")

echo "🦞 Lobster 会员网站爬取"
echo "=========================================="
echo "目标：$TARGET_URL"
echo "时间：$(date)"
echo "=========================================="

# 创建 Lobster 工作流
lobster run --workflow="
{
  \"steps\": [
    {\"action\": \"browser.open\", \"url\": \"$TARGET_URL/login\"},
    {\"action\": \"browser.type\", \"ref\": \"username\", \"text\": \"$USERNAME\"},
    {\"action\": \"browser.type\", \"ref\": \"password\", \"text\": \"$PASSWORD\"},
    {\"action\": \"browser.click\", \"ref\": \"login\"},
    {\"action\": \"browser.wait\", \"timeMs\": 3000},
    {\"action\": \"browser.open\", \"url\": \"$TARGET_URL/content\"},
    {\"action\": \"browser.snapshot\", \"output\": \"$OUTPUT_DIR/content_$DATE.md\"}
  ]
}
"

echo "✅ 抓取完成：$OUTPUT_DIR/content_$DATE.md"
```

---

### 脚本 2: Cookie 检查脚本

```bash
#!/bin/bash
# check_cookies.sh

COOKIE_FILE="$1"

if [ ! -f "$COOKIE_FILE" ]; then
    echo "❌ Cookie 文件不存在：$COOKIE_FILE"
    exit 1
fi

echo "🍪 Cookie 检查"
echo "=========================================="

# 检查 Cookie 是否过期
EXPIRY=$(jq -r '.[0].expiry' "$COOKIE_FILE" 2>/dev/null || echo "0")
CURRENT=$(date +%s)

if [ "$EXPIRY" -lt "$CURRENT" ]; then
    echo "❌ Cookie 已过期"
    echo "需要重新登录获取新 Cookie"
    exit 1
else
    EXPIRY_DATE=$(date -d "@$EXPIRY" 2>/dev/null || date -r "$EXPIRY" 2>/dev/null || echo "unknown")
    echo "✅ Cookie 有效"
    echo "过期时间：$EXPIRY_DATE"
fi

# 显示 Cookie 数量
COUNT=$(jq '. | length' "$COOKIE_FILE" 2>/dev/null || echo "0")
echo "Cookie 数量：$COUNT"
```

---

## 🛡️ 安全最佳实践

### 1. 凭证管理

```bash
# ✅ 推荐：使用密码管理器
pass show example.com/username
pass show example.com/password

# ✅ 推荐：使用加密文件
gpg --decrypt credentials.gpg > credentials.txt

# ❌ 避免：明文存储
echo "password123" > password.txt  # 危险！
```

### 2. Cookie 安全

```bash
# 设置正确权限
chmod 600 ~/.openclaw/cookies/*.json

# 定期更新 Cookie (每周)
0 0 * * 0 /root/.openclaw/workspace/backup/scripts/refresh_cookies.sh
```

### 3. 访问控制

```bash
# 限制脚本执行权限
chmod 700 /root/.openclaw/workspace/backup/scripts/member_site_scraper.sh

# 使用专用账号（非主账号）
# 创建只读权限的子账号用于爬取
```

---

## 📊 常见网站爬取策略

| 网站类型 | 推荐方法 | 难度 | 备注 |
|---------|---------|------|------|
| **付费新闻** | jina.ai + Cookie | ⭐⭐ | WSJ、NYT 等 |
| **学术数据库** | Lobster + 机构账号 | ⭐⭐⭐ | JSTOR、IEEE |
| **社交媒体** | Browser L3 + API | ⭐⭐⭐⭐ | Twitter、LinkedIn |
| **电商会员** | Cookie 持久化 | ⭐⭐ | Amazon Prime |
| **流媒体** | 不推荐 | ⭐⭐⭐⭐⭐ | Netflix 等 DRM 保护 |
| **企业内部** | Lobster + SSO | ⭐⭐⭐ | 需要特殊配置 |

---

## 🔍 故障排查

### 问题 1: 登录后立即退出

**原因：** Cookie 未正确保存或 Session 过期

**解决：**
```bash
# 1. 检查 Cookie 有效期
./check_cookies.sh ~/.openclaw/cookies/example.com.json

# 2. 重新登录获取新 Cookie
# 3. 确保浏览器未阻止第三方 Cookie
```

### 问题 2: 触发验证码

**原因：** 请求过于频繁

**解决：**
```bash
# 1. 添加延迟
sleep $((RANDOM % 10 + 5))  # 5-15 秒随机延迟

# 2. 降低频率
# 每小时最多 10-20 次请求

# 3. 人工处理验证码
# 脚本暂停，等待人工输入
```

### 问题 3: 内容加载不全

**原因：** JavaScript 动态渲染

**解决：**
```bash
# 1. 使用 browser 而非 web_fetch
browser --action=open --url="..."
browser --action=wait --timeMs=5000  # 等待 5 秒

# 2. 滚动页面触发加载
browser --action=evaluate --fn="window.scrollTo(0, document.body.scrollHeight)"
```

---

## 📚 相关资源

- [Lobster 插件文档](https://docs.openclaw.ai/plugins/lobster)
- [Browser 工具指南](https://docs.openclaw.ai/tools/browser)
- [Puppeteer 文档](https://pptr.dev/)
- [Selenium 文档](https://www.selenium.dev/)

---

## ⚠️ 法律提醒

1. **遵守服务条款** - 某些网站禁止自动化爬取
2. **尊重版权** - 付费内容不要公开分享
3. **合理使用** - 不要给目标网站造成过大负载
4. **数据隐私** - 不要爬取他人个人信息

---

_最后更新：2026-02-27_
_下次审查：2026-03-27_
