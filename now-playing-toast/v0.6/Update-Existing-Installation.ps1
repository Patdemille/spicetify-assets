# Now Playing Toast v0.6 - update an existing v0.5 Windows installation.
# Run as normal user; Spotify must be fully closed. No Spotify/SpotX update.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$app = Join-Path $env:LOCALAPPDATA 'NowPlayingToast'
$companion = Join-Path $app 'NowPlayingToast.ps1'
$ext = Join-Path $env:APPDATA 'spicetify\Extensions\now-playing-toast.js'
$startup = Join-Path ([Environment]::GetFolderPath('Startup')) 'Now Playing Toast.lnk'
$base = 'https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/now-playing-toast/v0.6'
if (Get-Process -Name 'Spotify' -ErrorAction SilentlyContinue) {
    throw 'Fermer Spotify completement, y compris dans la zone de notification Windows.'
}
if (-not (Get-Command spicetify -ErrorAction SilentlyContinue)) {
    throw 'La commande spicetify est introuvable.'
}
foreach ($file in @($companion, $ext, $startup)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Installation v0.5 incomplete : $file"
    }
}

$backup = Join-Path $app ('backup-before-v0.6-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $backup -Force | Out-Null
Copy-Item -LiteralPath $companion -Destination (Join-Path $backup 'NowPlayingToast.ps1') -Force
Copy-Item -LiteralPath $ext -Destination (Join-Path $backup 'now-playing-toast.js') -Force
Write-Host "Sauvegarde creee : $backup" -ForegroundColor Cyan

$tmpPs = Join-Path $app 'NowPlayingToast.v06.download'
$tmpJs = Join-Path $app 'now-playing-toast.v06.download'
try {
    Invoke-WebRequest -UseBasicParsing "$base/NowPlayingToast.ps1" -OutFile $tmpPs
    Invoke-WebRequest -UseBasicParsing "$base/now-playing-toast.js" -OutFile $tmpJs
    if (-not ((Get-Content -LiteralPath $tmpPs -TotalCount 1) -like '# Now Playing Toast v0.6*')) {
        throw 'Compagnon telecharge inattendu : installation interrompue.'
    }
    if (-not ((Get-Content -LiteralPath $tmpJs -TotalCount 1) -like '// Now Playing Toast v0.6*')) {
        throw 'Extension telechargee inattendue : installation interrompue.'
    }
    if ((Get-Item -LiteralPath $tmpPs).Length -lt 18000 -or
        (Get-Item -LiteralPath $tmpJs).Length -lt 6500) {
        throw 'Telechargement incomplet : installation interrompue.'
    }
    Copy-Item -LiteralPath $tmpPs -Destination $companion -Force
    Copy-Item -LiteralPath $tmpJs -Destination $ext -Force

    & spicetify apply
    if ($LASTEXITCODE -ne 0) {
        throw "spicetify apply a echoue avec le code $LASTEXITCODE"
    }
} catch {
    # Restore both files; preserve existing installed configuration.
    Copy-Item -LiteralPath (Join-Path $backup 'NowPlayingToast.ps1') -Destination $companion -Force
    Copy-Item -LiteralPath (Join-Path $backup 'now-playing-toast.js') -Destination $ext -Force
    Write-Warning "Les deux fichiers v0.5 ont ete restaures depuis $backup"
    throw
} finally {
    Remove-Item -LiteralPath $tmpPs, $tmpJs -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host 'OK : Now Playing Toast v0.6 est installe dans les fichiers du laptop.' -ForegroundColor Green
Write-Host 'AUCUN changement de Spotify/SpotX, Cat-Jam, Marketplace ou des personnages.'
Write-Host 'Le raccourci Windows existant est conserve.'
Write-Host 'Redemarrer Windows puis ouvrir une session pour activer le compagnon v0.6.'
Write-Host 'Le compagnon actuellement en cours garde son ancienne version jusqu au redemarrage.'
Write-Host 'Tester ensuite le bouton Suivant, Ctrl+Maj+W et le deplacement a la souris.'
Write-Host "Sauvegarde : $backup"
