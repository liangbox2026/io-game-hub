# MEMORY.md - Long-Term Memory

_ curated memories and significant learnings _

## Project Context

### HTML5 Game Site Project (Started 2026-02-26)
- User wants to build an HTML5 game website
- Discussed ad networks: Google AdSense, Playwire, Adsterra, PropellerAds
- Recommended starting with GameDistribution for game content + AdSense for monetization
- Tech stack recommendation: Vue3 + Vite for frontend, Vercel/Cloudflare Pages for hosting

### System Issues (2026-02-26)
- Backup scripts missing: `daily_backup.sh` and `backup_health_check.sh` referenced in crontab but don't exist
- 4 cron jobs affected (daily/weekly/monthly backup + health check)
- ddingtalk plugin missing 'zod' dependency
- API rate limiting encountered on news/cron tasks

### Infrastructure
- Gateway token: configured (loopback only, 127.0.0.1:18789)
- Feishu integration: enabled and working
- Node version: 22.22.0 via nvm
- OpenClaw version: 2026.2.9 (update available: 2026.2.25)

---

_Last updated: 2026-02-26_
