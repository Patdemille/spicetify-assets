# Now Playing Toast - desactive UNIQUEMENT le demarrage automatique.
# Ne supprime ni les fichiers de l'application ni l'extension Spicetify.
$ErrorActionPreference = 'Stop'
$path = Join-Path ([Environment]::GetFolderPath('Startup')) 'Now Playing Toast.lnk'
if (Test-Path -LiteralPath $path) {
    Remove-Item -LiteralPath $path -Force
    Write-Host "Demarrage automatique desactive : $path" -ForegroundColor Green
} else {
    Write-Host "Pas de raccourci Now Playing Toast au demarrage."
}
Write-Host "Un compagnon deja lance reste actif jusqu'a la fin de sa session."
