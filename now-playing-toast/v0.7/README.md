# Now Playing Toast v0.7 — bouton « Titres likés »

**Statut au 23/10/2026 : validée fonctionnellement sur Main** (bouton +, coche verte, ajout aux Titres likés et commande Suivant confirmés). **La copie définitive du compagnon est en cours d'installation sur Main. Laptop reste en V0.6.** La V0.6 reste disponible pour restauration.

## Fonctionnement proposé

- Bouton `+` placé à gauche de **Suivant**, sur le toast existant.
- Lorsque Spotify confirme que le morceau est déjà dans les **Titres likés**, le `+` devient une **coche verte**.
- Un clic ajoute ou retire le titre par `Spicetify.Player.toggleHeart()`. Le résultat et l'état affiché proviennent de `Spicetify.Player.getHeart()`, non d'une simulation.
- Le bouton reste désactivé quand le morceau n'est pas un `spotify:track:<id>` ou que son état n'est pas récupérable (épisode, fichier local, API indisponible).
- Chaque commande `toggle_like:spotify:track:<id>` contient l'URI du morceau affiché au moment du clic. Le JavaScript ignore la commande si un autre morceau est passé entre-temps.
- La lecture, **Suivant**, la mémorisation de la position, le glisser-déposer, le fondu, l'année, les 7 secondes d'affichage et `Ctrl + Maj + W` sont conservés.
- Communications seulement sur le pont existant : `127.0.0.1:43827` (`POST /track`, `GET /control`, `GET /health`).

Document officiel : https://spicetify.app/docs/development/api-wrapper/methods/player

## Première étape, sans installation

Dans une fenêtre PowerShell normale :

```powershell
$dir = "$env:LOCALAPPDATA\NowPlayingToast"
Invoke-WebRequest "https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/now-playing-toast/v0.7/NowPlayingToast.ps1" -OutFile "$dir\NowPlayingToast-v0.7-preview.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/now-playing-toast/v0.7/now-playing-toast.js" -OutFile "$dir\now-playing-toast-v0.7-preview.js"
```

Les fichiers de V0.6 en service ne sont pas modifiés.

## Test complet (à faire uniquement après sauvegarde)

1. Fermer totalement Spotify, y compris depuis la zone de notification Windows.
2. Sauvegarder l'extension `%APPDATA%\spicetify\Extensions\now-playing-toast.js` sous un nom distinct.
3. Copier `now-playing-toast-v0.7-preview.js` dans ce fichier d'extension existant, puis lancer `spicetify apply`.
4. Arrêter **uniquement** le compagnon V0.6 (qui occupe le port 43827), puis lancer `NowPlayingToast-v0.7-preview.ps1` dans PowerShell visible avec `-STA` pour tester.
5. Écouter un titre Spotify non liké : vérifier que le bouton `+` est actif. Cliquer : vérifier que le morceau est ajouté dans Spotify et que la coche apparaît.
6. Cliquer de nouveau : vérifier que la coche redevient `+` et que le titre est retiré.
7. Tester le bouton **Suivant**, le glisser-déposer, `Ctrl + Maj + W`, l'année et les pochettes.
8. Vérifier le comportement après passage rapide au morceau suivant et sur les podcasts/fichiers locaux.

Ne pas modifier le raccourci de démarrage Windows : il reste dirigé vers la V0.6 tant que la V0.7 n'est pas validée. Pour revenir en arrière, restaurer l'extension JS V0.6, exécuter `spicetify apply`, arrêter la préversion V0.7 et relancer le raccourci du compagnon V0.6.

## Avant publication générale

Revoir : compatibilité réelle de `getHeart/toggleHeart` avec cette version Spotify/SpotX, gestion des erreurs et des états transitoires, accessibilité du bouton, audit de sécurité du pont HTTP local et tests en environnement multi-écrans. La V0.7 n'est pas annoncée comme stable ou Marketplace.
