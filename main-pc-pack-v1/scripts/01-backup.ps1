$ErrorActionPreference = 'Stop'
$source = Join-Path $env:APPDATA 'spicetify'
if (!(Test-Path $source)) { throw "Spicetify absent : $source" }
$dest = Join-Path ([Environment]::GetFolderPath('Desktop')) ("Spicetify-Main-Backup-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
Copy-Item -LiteralPath $source -Destination $dest -Recurse -Force
Write-Host "Sauvegarde Spicetify : $dest" -ForegroundColor Green
Write-Host "Ce script ne sauvegarde PAS les fichiers Spotify/SpotX."
