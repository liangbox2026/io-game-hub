# Browser Automation 浏览器自动化

_从 snapshot 到交互的完整指南_

**等级**: L2 🟢  
**最后更新**: 2026-02-25  
**相关**: [[web_scraping]], [[smart_fetch_pattern]]

---

## 📦 核心概念

浏览器自动化 4 层级：

```
L0: 搜索 + 抓取 (web_search + web_fetch)
L1: 无头浏览器 (Headless Chrome)
L2: 有头浏览器 + DOM 操作 ← 当前等级
L3: 截图 + 视觉识别
```

---

## 🛠️ 核心命令

| 命令 | 用途 | 示例 |
|------|------|------|
| `open` | 打开网页 | `browser action=open targetUrl=URL` |
| `snapshot` | 获取页面快照 | `browser action=snapshot refs=aria` |
| `act` | 执行交互 | `browser action=act ref=e1 click` |
| `type` | 输入文本 | `browser action=act ref=e2 type="text"` |
| `screenshot` | 截图 | `browser action=screenshot` |

---

## 💡 使用流程

### 1. 打开网页

```bash
browser action=open targetUrl="https://example.com"
```

### 2. 获取快照 (带 refs)

```bash
browser action=snapshot refs=aria
# 返回页面元素列表，如 e1, e2, e3...
```

### 3. 点击元素

```bash
browser action=act ref=e1 click
# e1 是从快照中获取的元素引用
```

### 4. 输入文本

```bash
browser action=act ref=e2 type="搜索内容"
```

### 5. 截图

```bash
browser action=screenshot fullPage=true
```

---

## ⚠️ 常见问题

### 1. 浏览器不可用

**错误**: `Can't reach the OpenClaw browser control service`

**原因**: Gateway 未运行或 Chrome 扩展未连接

**解决**:
```bash
# 重启 Gateway
openclaw gateway restart

# 或使用 Chrome 扩展 relay
# 点击 Chrome 扩展图标附加到标签页
```

### 2. 元素找不到

**原因**: 页面未加载完成

**解决**:
```bash
# 等待页面加载
browser action=act wait=3000

# 或等待特定元素出现
browser action=act textGone="Loading..."
```

### 3. Token 不匹配

**错误**: `gateway token mismatch`

**解决**:
```bash
# 检查 systemd 配置文件
cat /root/.config/systemd/user/openclaw-gateway.service

# 更新 OPENCLAW_GATEWAY_TOKEN 与 openclaw.json 一致
# 然后重启
systemctl --user daemon-reload && restart openclaw-gateway
```

---

## 📚 实战案例

### 案例 1: GitHub Trending 抓取

```bash
# 1. 打开页面
browser action=open targetUrl="https://github.com/trending"

# 2. 获取快照
browser action=snapshot refs=aria

# 3. 提取 trending 项目
# (从快照中解析项目列表)

# 4. 截图保存
browser action=screenshot fullPage=true
```

### 案例 2: 表单自动填写

```bash
# 1. 打开登录页面
browser action=open targetUrl="https://example.com/login"

# 2. 获取快照找到输入框
browser action=snapshot refs=aria

# 3. 填写用户名
browser action=act ref=username_input type="user@example.com"

# 4. 填写密码
browser action=act ref=password_input type="password123"

# 5. 点击登录
browser action=act ref=login_button click
```

---

## 🔗 相关资源

- [[web_scraping]] - 网页抓取基础
- [[smart_fetch_pattern]] - 智能抓取模式
- [[gateway_debugging]] - Gateway 故障排查

---

_创建时间：2026-02-25_
_作者：OpenClaw Agent_
