# Installer Now Playing Toast sur un second PC Windows (Laptop)

Guide reproductible utilisant les fichiers **deja publies et testes sur Main** :
- Compagnon WPF **v0.5** (deplacable et position memorisee)
- Extension Spicetify **v0.4.2** (titre, artistes, album, annee Spotify, duree et pochette)
- Demarrage automatique avec le script **Install-AutoStart.ps1** deja publie.

> Version du guide : octobre 2026. Le fonctionnement a ete valide sur Main, pas encore sur ce laptop. Aucune modification de Spotify/SpotX ou des autres extensions Spicetify n'est requise. Executer sous PowerShell normal (pas administrateur).

## 0. Pre-requis

- Spotify desktop et Spicetify fonctionnent deja.
- Quitter completement Spotify avant d'executer `spicetify apply`.
- Sauvegarder le dossier `%APPDATA%\spicetify` au prealable si cette machine contient deja des personnalisations.

## 1. Telecharger depuis GitHub, dans AppData

```powershell
$dir = Join-Path $env:LOCALAPPDATA 'NowPlayingToast'
$ext = Join-Path $env:APPDATA 'spicetify\Extensions'
New-Item -ItemType Directory -Force -Path $dir, $ext | Out-Null
Invoke-WebRequest 'https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/now-playing-toast/v0.5/NowPlayingToast.ps1' -OutFile (Join-Path $dir 'NowPlayingToast.ps1')
Invoke-WebRequest 'https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/now-playing-toast/v0.4/now-playing-toast.js' -OutFile (Join-Path $ext 'now-playing-toast.js')
Test-Path (Join-Path $dir 'NowPlayingToast.ps1')
Test-Path (Join-Path $ext 'now-playing-toast.js')
```

Les deux tests doivent afficher `True`.

## 2. Activer dans Spicetify

```powershell
spicetify config extensions now-playing-toast.js
spicetify apply
```

Spicetify **ajoute** l'extension aux extensions existantes, sans remplacer Cat-Jam ou les autres extensions.

## 3. Activer le lancement discret a l'ouverture de session Windows

```powershell
Invoke-WebRequest 'https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/now-playing-toast/v0.4/Install-AutoStart.ps1' -OutFile (Join-Path $dir 'Install-AutoStart.ps1')
# Lire le script si desire avant de l'executer :
notepad (Join-Path $dir 'Install-AutoStart.ps1')
powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $dir 'Install-AutoStart.ps1')
```

Cela cree un raccourci de session Windows vers `%LOCALAPPDATA%\NowPlayingToast\NowPlayingToast.ps1`. Cela ne cree pas de service Windows et ne lance pas le compagnon immediatement.

## 4. Test immediat et verification

```powershell
$shortcut = Join-Path ([Environment]::GetFolderPath('Startup')) 'Now Playing Toast.lnk'
Invoke-Item $shortcut
Start-Sleep -Seconds 3
Invoke-RestMethod 'http://127.0.0.1:43827/health' -TimeoutSec 5
```

Attendre `Now Playing Toast OK`. Ouvrir Spotify et lire un morceau : notification animee pendant 7 secondes. Tester `Ctrl+Maj+W`, puis deplacer le toast a la souris. La derniere position est enregistree dans `%LOCALAPPDATA%\NowPlayingToast\position.json`.

Au prochain **redemarrage + ouverture de session Windows**, le raccourci doit relancer le compagnon silencieusement. La simple ouverture de Spotify **ne le demarre pas** si le compagnon s'est arrete ; le serveur doit etre actif.

## Revenir en arriere

Pour desactiver l'extension sans supprimer la configuration des autres extensions :

```powershell
spicetify config extensions now-playing-toast.js-
spicetify apply
```

Pour enlever le demarrage Windows, supprimer uniquement le raccourci `Now Playing Toast.lnk` du dossier `shell:startup`, ou utiliser `Disable-AutoStart.ps1` deja publie.

Ne supprimer le dossier `%LOCALAPPDATA%\NowPlayingToast` que lorsque le compagnon est arrete et que le raccourci de demarrage a ete retire.

## Publication future dans Marketplace

Ce composant est **public sur GitHub mais pas encore reference dans Marketplace**. Le code JS peut etre publie comme extension avec un depot public, un `manifest.json` racine, une preview et le topic `spicetify-extensions`. Cependant le compagnon WPF necessaire aux vraies notifications Windows doit encore etre installe separement : le clic « Installer » dans Marketplace ne suffit donc pas a installer tout Now Playing Toast.

Documentation officielle :
- https://github.com/spicetify/marketplace/wiki/Publishing-to-Marketplace
- https://spicetify.app/docs/customization/extensions

Avant la publication generale, prevoir une verification securite du pont HTTP local, une procedure d'installation/suppression aboutie, une licence adaptee et des tests sur plusieurs PCs.
