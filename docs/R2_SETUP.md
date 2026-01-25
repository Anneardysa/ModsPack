# Cloudflare R2 Setup Guide

Quick setup guide for hosting ModsPack assets on Cloudflare R2.

## 1. Create R2 Bucket

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com) → **R2 Object Storage**
2. Click **Create bucket** → Name: `modspack-assets`
3. After creation, go to **Settings** → Enable **R2.dev subdomain** for public access
4. Copy the public URL: `https://pub-{hash}.r2.dev`

## 2. Get API Credentials

1. Go to **R2** → **Manage R2 API Tokens** → **Create API token**
2. Settings:
   - Token name: `modspack-sync`
   - Permissions: `Object Read & Write`
   - Bucket: Select `modspack-assets`
3. Save these values:
   - **Access Key ID**
   - **Secret Access Key**
   - **Account ID** (shown on R2 overview page)

## 3. Local Sync Setup

### Install rclone

```powershell
winget install Rclone.Rclone
```

### Configure rclone

Edit `%USERPROFILE%\.config\rclone\rclone.conf`:

```ini
[r2]
type = s3
provider = Cloudflare
access_key_id = YOUR_ACCESS_KEY_ID
secret_access_key = YOUR_SECRET_ACCESS_KEY
endpoint = https://YOUR_ACCOUNT_ID.r2.cloudflarestorage.com
acl = public-read
```

### Sync assets

```powershell
# Dry run (preview)
.\sync-to-r2.ps1 -DryRun

# Actual sync
.\sync-to-r2.ps1
```

## 4. GitHub Actions Setup (Auto-sync)

Add these secrets to your GitHub repo (`Anneardysa/ModsPack`):

- **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret Name            | Value                      |
| ---------------------- | -------------------------- |
| `R2_ACCESS_KEY_ID`     | Your R2 access key         |
| `R2_SECRET_ACCESS_KEY` | Your R2 secret key         |
| `R2_ACCOUNT_ID`        | Your Cloudflare account ID |
| `R2_BUCKET_NAME`       | `modspack-assets`          |

Push `.github/workflows/sync-to-r2.yml` to enable auto-sync.

## 5. Enable R2 in Application

Update `CdnConfig.cs`:

```csharp
// Replace with your actual R2 URL
public const string R2BaseUrl = "https://pub-YOURHASH.r2.dev";

// Enable R2
public static bool IsR2Enabled { get; set; } = true;
```

## Testing

```powershell
# Test R2 public access
curl -I https://pub-YOURHASH.r2.dev/Assets/heroes.json
```

## Cost

**Free tier includes:**

- 10 GB storage
- 1M writes/month
- 10M reads/month

Most mod packs won't exceed this.
