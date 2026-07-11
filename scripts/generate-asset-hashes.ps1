<#
.SYNOPSIS
    Generates Assets/asset_hashes.json — the per-asset SHA-256 manifest consumed by
    ArdysaModsTools for download integrity verification (ADR-0010).

.DESCRIPTION
    Walks the ModsPack asset tree and emits { assetPath -> { sha256, size } } for every
    downloadable archive:
      * Standalone *.zip (e.g. Assets/models/<hero>/<set>/model.zip, Assets/Original.zip)
        -> SHA-256 of the file, size = file length.
      * Split archives (*.zip.001, *.zip.002, ...) -> SHA-256 of the parts CONCATENATED in
        order, keyed by the MERGED *.zip path. This matches the file the client assembles
        from the parts and then verifies before extraction.

    Keys are repo-relative paths with forward slashes, matching CdnConfig.ExtractAssetPath
    on the client. Hashes are uppercase hex (matching Convert.ToHexString).

    Run this in the ModsPack repo BEFORE sync-to-r2.ps1 so the manifest ships with the assets.

.PARAMETER AssetsRoot
    Root of the ModsPack repo (the folder that contains the Assets/ directory).

.PARAMETER Output
    Output manifest path. Defaults to "<AssetsRoot>/Assets/asset_hashes.json".

.EXAMPLE
    .\generate-asset-hashes.ps1 -AssetsRoot F:\Projects\ModsPack
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$AssetsRoot,
    [string]$Output
)

$ErrorActionPreference = 'Stop'

$root = (Resolve-Path $AssetsRoot).Path
if (-not $Output) {
    $Output = Join-Path $root 'Assets/asset_hashes.json'
}

function Get-RelKey([string]$fullPath) {
    $rel = $fullPath.Substring($root.Length).TrimStart('\', '/')
    return ($rel -replace '\\', '/')
}

# SHA-256 over one or more files concatenated in the given order; returns uppercase hex.
function Get-ConcatSha256 {
    param([string[]]$Paths, [ref]$TotalSize)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $buffer = New-Object byte[] 1048576
    $size = [long]0
    try {
        foreach ($p in $Paths) {
            $fs = [System.IO.File]::OpenRead($p)
            try {
                while (($read = $fs.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    [void]$sha.TransformBlock($buffer, 0, $read, $null, 0)
                    $size += $read
                }
            }
            finally { $fs.Dispose() }
        }
        [void]$sha.TransformFinalBlock([byte[]]::new(0), 0, 0)
        $TotalSize.Value = $size
        return ([System.BitConverter]::ToString($sha.Hash) -replace '-', '')
    }
    finally { $sha.Dispose() }
}

$assets = [ordered]@{}

# Only the Assets/ subtree is downloadable/synced (keys are Assets/...). Scanning the whole repo
# root would also sweep in the _plaintext/ encryption backups — publishing their plaintext SHA-256s
# and referencing files that never reach R2. Keys stay repo-relative via Get-RelKey ($root).
$scanRoot = Join-Path $root 'Assets'

# 1) Standalone .zip files (the *.zip filter excludes split parts ending in .zip.NNN).
Get-ChildItem -Path $scanRoot -Recurse -File -Filter *.zip | Sort-Object FullName | ForEach-Object {
    $key = Get-RelKey $_.FullName
    $hash = (Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
    $assets[$key] = [ordered]@{ sha256 = $hash; size = $_.Length }
}

# 2) Split archives: group *.zip.001/.002/... by the merged ".zip" path, hash concatenation.
$splitGroups = Get-ChildItem -Path $scanRoot -Recurse -File |
    Where-Object { $_.Name -match '\.zip\.\d{3}$' } |
    Group-Object { $_.FullName -replace '\.\d{3}$', '' }

foreach ($group in $splitGroups) {
    $orderedParts = $group.Group | Sort-Object Name | ForEach-Object { $_.FullName }
    $size = [long]0
    $hash = Get-ConcatSha256 -Paths $orderedParts -TotalSize ([ref]$size)
    $mergedKey = Get-RelKey $group.Name   # group key = full path without the ".NNN" suffix
    $assets[$mergedKey] = [ordered]@{ sha256 = $hash; size = $size }
}

$manifest = [ordered]@{
    version     = 1
    algorithm   = 'SHA-256'
    generatedAt = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    assets      = $assets
}

$json = $manifest | ConvertTo-Json -Depth 6
Set-Content -Path $Output -Value $json -Encoding UTF8

Write-Host "Wrote $($assets.Count) asset hashes to $Output"
