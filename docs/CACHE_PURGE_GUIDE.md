# jsDelivr CDN Cache Purging Guide

## Automatic Cache Purge (Recommended)

A GitHub Action has been set up to **automatically purge the CDN cache** whenever you push changes to:

- `Assets/heroes.json`
- `Assets/set_update.json`

**No manual action needed!** Just commit and push your changes as usual.

### How it works:

1. You update `heroes.json` or `set_update.json` locally
2. Commit and push to GitHub
3. GitHub Actions automatically runs `.github/workflows/purge-cdn-cache.yml`
4. CDN cache is purged within 5-10 seconds
5. Next app launch gets fresh data

---

## Manual Cache Purge (Backup Method)

If you need to purge the cache manually for any reason:

### Option 1: Browser

Visit these URLs in your browser:

```
https://purge.jsdelivr.net/gh/Anneardysa/ModsPack@main/Assets/heroes.json
https://purge.jsdelivr.net/gh/Anneardysa/ModsPack@main/Assets/set_update.json
```

### Option 2: PowerShell

```powershell
Invoke-WebRequest -Uri "https://purge.jsdelivr.net/gh/Anneardysa/ModsPack@main/Assets/heroes.json"
Invoke-WebRequest -Uri "https://purge.jsdelivr.net/gh/Anneardysa/ModsPack@main/Assets/set_update.json"
```

---

## How Cache-Busting Works in the App

The app uses hourly cache-busting for JSON files:

- URL format: `https://cdn.jsdelivr.net/.../heroes.json?v=2026012310`
- The `?v=` parameter changes every hour
- Combined with GitHub Actions, ensures users get updates within 1 hour max

For large files (`.zip`), the app uses normal CDN URLs without cache-busting to maximize download speed.

---

## Workflow File Location

`.github/workflows/purge-cdn-cache.yml` in the ModsPack repository

To modify or disable: Edit or delete this file and push to GitHub.
