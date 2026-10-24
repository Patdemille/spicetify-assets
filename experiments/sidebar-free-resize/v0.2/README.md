# Sidebar Free Resize v0.2 — test de fluidité

**Statut : non encore testé sur Main.** La v0.1 fonctionne pour agrandir le panneau droit Spotify mais le glisser-déposer est saccadé.

## Changement technique

- Évite les lectures de géométrie `getBoundingClientRect()` après chaque écriture de largeur CSS.
- Regroupe les mouvements via `requestAnimationFrame`, **au maximum une mise à jour de largeur par image**.
- Suit le déplacement du curseur sans recalculer le panneau à chaque événement souris.
- Garde la plage 280–800 px (limitée à la largeur réellement disponible).
- Réutilise la clé `localStorage` de v0.1, donc conserve la largeur mémorisée.
- Ne change ni Spotify/SpotX, ni les autres extensions ou thèmes.

## Test Main (après désactivation de la bribe CSS de largeur)

1. **Fermer complètement Spotify**, y compris dans la zone de notification.
2. Dans PowerShell normal :

```powershell
$f = "$env:APPDATA\spicetify\Extensions\sidebar-free-resize.js"
Copy-Item $f "$f.bak-v0.1" -Force
Invoke-WebRequest "https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/experiments/sidebar-free-resize/v0.2/sidebar-free-resize.js" -OutFile $f
spicetify apply
```

3. Rouvrir Spotify, vérifier que la tirette fonctionne et que la largeur actuelle est conservée. Comparer la fluidité et la navigation entre les panneaux.

## Retour arrière

Fermer Spotify, puis :

```powershell
$f = "$env:APPDATA\spicetify\Extensions\sidebar-free-resize.js"
Copy-Item "$f.bak-v0.1" $f -Force
spicetify apply
```

**Limite :** même avec moins de recalculs JavaScript, Spotify doit réorganiser le contenu central et la sidebar durant le déplacement ; une légère saccade peut subsister. Ne pas publier comme version stable sans essai utilisateur.
