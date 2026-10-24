# Sidebar Free Resize — installation locale, a executer UNE SEULE FOIS.
# Aucun processus PowerShell n'est maintenu apres l'installation.
$ErrorActionPreference = "Stop"

if (-not (Get-Command spicetify -ErrorAction SilentlyContinue)) {
    throw "Spicetify CLI introuvable dans le PATH. Installez/configurez Spicetify avant de continuer."
}

if (Get-Process -Name Spotify -ErrorAction SilentlyContinue) {
    throw "Fermez completement Spotify (y compris l'icone de notification) avant l'installation."
}

$source = Join-Path $PSScriptRoot "sidebar-free-resize.js"
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Fichier source manquant : $source"
}
$folder = Join-Path $env:APPDATA "spicetify\Extensions"
$target = Join-Path $folder "sidebar-free-resize.js"
New-Item -ItemType Directory -Path $folder -Force | Out-Null

if (Test-Path -LiteralPath $target -PathType Leaf) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup = "$target.bak-$stamp"
    Copy-Item -LiteralPath $target -Destination $backup -Force
    Write-Host "Sauvegarde : $backup"
}

Copy-Item -LiteralPath $source -Destination $target -Force
spicetify config extensions sidebar-free-resize.js
if ($LASTEXITCODE -ne 0) { throw "Erreur de configuration Spicetify (code $LASTEXITCODE)." }
spicetify apply
if ($LASTEXITCODE -ne 0) { throw "Echec de spicetify apply (code $LASTEXITCODE)." }

Write-Host ""
Write-Host "Sidebar Free Resize installe. Rouvrez Spotify et glissez le bord gauche du panneau droit." -ForegroundColor Green
Write-Host "Aucun demarrage Windows ni processus PowerShell resident n'a ete ajoute."
