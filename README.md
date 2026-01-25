# 🎮 ModsPack - Dota 2 Custom Mods Repository

Custom mods and skins for Dota 2, served via Cloudflare R2 CDN.

## 📁 Repository Structure

```
ModsPack/
├── .github/workflows/      # GitHub Actions
│   ├── sync-to-r2.yml       # Auto-sync Assets to R2 on push
│   ├── sync-release-to-r2.yml  # Sync releases to R2
│   └── purge-cdn-cache.yml  # CDN cache purge
├── Assets/                  # Main assets folder (synced to R2)
│   ├── heroes.json          # Hero & skin metadata
│   ├── set_update.json      # Latest updates info
│   ├── Original.zip         # Original game files backup
│   ├── models/              # Hero skin models
│   │   └── {HeroName}/      # One folder per hero
│   │       └── {SetName}.zip  # Skin packages
│   ├── image/               # Thumbnails and preview images
│   └── misc/                # Miscellaneous mods
│       ├── Announcer/
│       ├── Tower/
│       ├── Creep/
│       └── ...
├── config/                  # Configuration files
│   └── misc_config.json     # Misc mods configuration
├── remote/                  # Remote/shared game files
│   └── gameinfo.gi          # Game configuration
└── docs/
    ├── R2_SETUP.md          # R2 setup guide
    └── CACHE_PURGE_GUIDE.md # CDN cache purge guide
```

## 🌐 CDN URLs

Assets are served via Cloudflare R2:

| Content         | URL                                                   |
| --------------- | ----------------------------------------------------- |
| **Assets**      | `https://cdn.ardysamods.my.id/Assets/`                |
| **Heroes JSON** | `https://cdn.ardysamods.my.id/Assets/heroes.json`     |
| **Set Updates** | `https://cdn.ardysamods.my.id/Assets/set_update.json` |
| **Releases**    | `https://cdn.ardysamods.my.id/modspack-releases/`     |

## 🔄 Automated Syncing

This repository uses GitHub Actions to automatically sync content:

1. **Asset Sync** (`sync-to-r2.yml`)
   - Triggers on push to `Assets/` folder
   - Syncs all assets to R2 bucket

2. **Release Sync** (`sync-release-to-r2.yml`)
   - Triggers when a release is published
   - Uploads release assets to R2

## 📝 Adding New Mods

### Hero Skins

1. Create folder: `Assets/models/{HeroName}/{SetName}/`
2. Add skin files as `.zip`
3. Update `Assets/heroes.json` with metadata
4. Commit and push → Auto-syncs to CDN

### Misc Mods

1. Add to appropriate folder in `Assets/misc/`
2. Update `config/misc_config.json`
3. Commit and push

## 📄 License

This repository contains custom modifications for Dota 2.
All Dota 2 assets are property of Valve Corporation.
