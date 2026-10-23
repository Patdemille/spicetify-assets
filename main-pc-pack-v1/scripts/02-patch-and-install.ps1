$ErrorActionPreference = 'Stop'
$pack = Split-Path -Parent $PSScriptRoot
$sp = Join-Path $env:APPDATA 'spicetify'
$ini = Join-Path $sp 'config-xpui.ini'
if (!(Test-Path $ini)) { throw "Config Spicetify absente : $ini" }
if (!(Get-Command spicetify -ErrorAction SilentlyContinue)) { throw "Spicetify CLI introuvable" }
if (Get-Process Spotify -ErrorAction SilentlyContinue) { throw "Fermer Spotify avant l'installation" }
$ok = Read-Host "La sauvegarde 01-backup.ps1 est-elle terminee ? (OUI)"
if ($ok -ne 'OUI') { throw "Installation annulee : sauvegarde requise" }
$ext = Join-Path $sp 'Extensions'
New-Item -ItemType Directory -Path $ext -Force | Out-Null
foreach ($f in @('catjam-mirror.js', 'characters-laptop.js')) {
  $target = Join-Path $ext $f
  if (Test-Path $target) {
    Copy-Item $target "$target.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Force
  }
  Copy-Item (Join-Path $pack "extensions\$f") $target -Force
  if ((Get-Content $ini -Raw) -notmatch [regex]::Escape($f)) {
    & spicetify config extensions $f
    if ($LASTEXITCODE -ne 0) { throw "Echec activation $f" }
  }
}
$mp = Join-Path $sp 'CustomApps\marketplace\extension.js'
if (Test-Path $mp) {
  $code = [IO.File]::ReadAllText($mp)
  $needle = 'Spicetify.LocalStorage&&Spicetify.showNotification'
  if ($code.Contains($needle)) {
    Copy-Item $mp "$mp.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Force
    [IO.File]::WriteAllText($mp, $code.Replace($needle, 'Spicetify.LocalStorage'), [Text.UTF8Encoding]::new($false))
    Write-Host 'Patch Marketplace cible applique.'
  } else {
    Write-Host 'Signature absente : aucun changement du Marketplace.'
  }
} else { Write-Warning 'Marketplace absent : installer v1.0.12 manuellement.' }
& spicetify apply
if ($LASTEXITCODE -ne 0) { throw 'spicetify apply a echoue : restaurer la sauvegarde si necessaire.' }
Write-Host 'Pack installe. Cat Jam Synced doit etre active separement.' -ForegroundColor Green
