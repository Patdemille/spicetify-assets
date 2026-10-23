# Now Playing Toast - installation de l'auto-demarrage Windows (sans admin)
# Ne modifie ni Spotify, ni Spicetify, ni SpotX.
$ErrorActionPreference = 'Stop'

$appDir = Join-Path $env:LOCALAPPDATA 'NowPlayingToast'
$companion = Join-Path $appDir 'NowPlayingToast.ps1'
$extension = Join-Path (Join-Path $env:APPDATA 'spicetify\Extensions') 'now-playing-toast.js'

if (-not (Test-Path -LiteralPath $companion -PathType Leaf)) {
    throw "Compagnon absent : $companion"
}
if (-not (Test-Path -LiteralPath $extension -PathType Leaf)) {
    Write-Warning "L'extension Spicetify est absente : $extension"
}

$startup = [Environment]::GetFolderPath('Startup')
if (-not (Test-Path -LiteralPath $startup)) {
    throw "Dossier de demarrage Windows introuvable : $startup"
}
$shortcutPath = Join-Path $startup 'Now Playing Toast.lnk'
$powershellPath = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'

if (-not (Test-Path -LiteralPath $powershellPath)) {
    throw "Windows PowerShell introuvable : $powershellPath"
}

# Only creates/replaces OUR startup shortcut; no registry edits, no services.
$wsh = New-Object -ComObject WScript.Shell
$shortcut = $wsh.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $powershellPath
$shortcut.Arguments = '-NoProfile -STA -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $companion + '"'
$shortcut.WorkingDirectory = $appDir
$shortcut.WindowStyle = 7
$shortcut.Description = 'Now Playing Toast - compagnon local Spotify, lancement discret'
$shortcut.Save()

# Re-read for basic consistency.
$check = $wsh.CreateShortcut($shortcutPath)
if ($check.TargetPath -ne $powershellPath -or $check.Arguments -notlike '*NowPlayingToast.ps1*') {
    throw "Le raccourci de demarrage n'a pas pu etre verifie."
}
Write-Host "OK : lancement automatique configure." -ForegroundColor Green
Write-Host "Raccourci : $shortcutPath"
Write-Host "Programme : $companion"
Write-Host "Prochaine connexion Windows : demarrage masque, aucune console a lancer."
Write-Host "La session actuellement en cours n'est pas modifiee."
Write-Host "Pour desactiver : executer Disable-AutoStart.ps1 ou supprimer ce raccourci."
