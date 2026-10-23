# Now Playing Toast — V0.4, Spotify bridge (prototype)

**Objectif :** une petite notification Windows 11 en bas à droite, avec pochette légèrement arrondie, titre, artiste, album, année si disponible, durée, progression, puis disparition après 5 secondes. Rappel à la demande par **Ctrl + Maj + W**.

La version V0.4 utilise deux composants :
- `NowPlayingToast.ps1` : compagnon local Windows (WPF, PowerShell 5.1, port **127.0.0.1:43827**, sans droits admin).
- `now-playing-toast.js` : extension Spicetify, qui lit le morceau Spotify via `Spicetify.Player` et envoie les métadonnées au compagnon via HTTP local.

**Les vraies métadonnées ne s'affichent que lorsque Spotify tourne et que l'extension JS est activée.** Les données ne sont pas envoyées à un service tiers par le compagnon. L'année dépend des données fournies par Spotify ; lorsqu'elle est indisponible, le pop-up affiche `--`.

## Installation sur Main, sans laisser de scripts sur le Bureau

Fermer **l'ancienne session PowerShell** qui exécute la démo V0.3 : sinon le raccourci est déjà pris.

Ouvrir PowerShell standard (**pas admin**) et exécuter :

```powershell
$dir = Join-Path $env:LOCALAPPDATA 'NowPlayingToast'
New-Item -ItemType Directory -Path $dir -Force | Out-Null

Invoke-WebRequest 'https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/now-playing-toast/v0.4/NowPlayingToast.ps1' -OutFile (Join-Path $dir 'NowPlayingToast.ps1')

$spicetifyExtensions = Join-Path $env:APPDATA 'spicetify\Extensions'
New-Item -ItemType Directory -Path $spicetifyExtensions -Force | Out-Null
Invoke-WebRequest 'https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/now-playing-toast/v0.4/now-playing-toast.js' -OutFile (Join-Path $spicetifyExtensions 'now-playing-toast.js')
```

**Premier test compagnon seul :**

```powershell
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\NowPlayingToast\NowPlayingToast.ps1"
```

Résultat attendu : `Raccourci Ctrl+Maj+W enregistre : True` et un récepteur `127.0.0.1:43827`. Pas de pop-up tant qu'aucun morceau réel n'est arrivé.

**Activer ensuite l'extension Spicetify** dans une deuxième fenêtre PowerShell (fermer Spotify avant `apply` et conserver la première console si possible) :

```powershell
spicetify config extensions now-playing-toast.js
spicetify apply
```

Ouvrir Spotify et lancer un titre. La notification devrait apparaître ; puis tester **Ctrl+Maj+W** après cinq secondes. La progression est rafraîchie régulièrement même quand le pop-up est masqué.

Après validation, nettoyer le Bureau de l'ancien script :

```powershell
Remove-Item -LiteralPath "$env:USERPROFILE\Desktop\NowPlayingToast-Demo.ps1" -ErrorAction SilentlyContinue
```

Cela supprime seulement **l'ancien fichier de démo** sur le Bureau, pas la version désormais installée sous `%LOCALAPPDATA%\NowPlayingToast`.

## Diagnostic

Dans un navigateur local ou PowerShell, `http://127.0.0.1:43827/health` doit répondre `Now Playing Toast OK` lorsque le compagnon tourne. Dans les DevTools Spotify, regarder les messages `[Now Playing Toast]`.

Si le navigateur refuse l'envoi local pour raison CSP / CORS / autorisation d'accès au réseau local, arrêter le test et noter le message : cette liaison HTTP est encore un prototype et nécessite peut-être un mécanisme de transport alternatif selon la version de Spotify. Ne pas désactiver globalement la sécurité du navigateur ou du système.

Si le raccourci est déjà enregistré par l'ancienne démo, il faut d'abord fermer son PowerShell.

## Arrêt et retour arrière

- Quitter le PowerShell qui exécute le compagnon.
- Pour désactiver l'extension : `spicetify config extensions now-playing-toast.js-` puis `spicetify apply` (Spotify fermé).
- Aucun fichier Spotify/SpotX n'est modifié directement ; pas de tâche de démarrage Windows ni de service permanent créé.

## État de développement

- Fenêtre : UI et raccourci testés sur Main en V0.3.
- Transport et affichage des morceaux : **V0.4 publiée mais pas encore testée sur Main**.
- Accent de couleur basé sur la pochette, anim de transition, démarrage automatique, raccourci configurable, multi-écran : envisagés pour une version ultérieure.

Le serveur HTTP est lié **uniquement à l'interface de bouclage**. Les requêtes avec un `Origin` web non Spotify sont rejetées ; il n'est pas exposé sur le réseau local.
