# Now Playing Toast v0.6 — Skip / morceau suivant (préversion)

> **Expérimental : source publiée mais PAS encore testée sur Main ou Laptop.** Conserver la v0.5, actuellement fonctionnelle, tant que cette version n'est pas validée.

## Fonctionnement

- Même apparence que v0.5 (442 × 156, 7 s, fondus, pochette, année, barre de progression).
- Bouton « morceau suivant » (double flèche et barre) en haut à droite, cliquable à la souris.
- Le clic envoie **uniquement** la commande `next` dans une petite file locale du compagnon Windows.
- L'extension JavaScript interroge `GET http://127.0.0.1:43827/control` toutes les 700 ms ; à la réception de `next`, elle appelle `Spicetify.Player.next()`.
- `POST /track` (métadonnées) et `GET /health` (diagnostic) restent inchangés.
- Déplacement à la souris : cliquer sur le fond du toast, pas sur le bouton. L'animation est toujours suspendue pendant le survol.
- Le compagnon écoute seulement `127.0.0.1`. Pas de commande arbitraire depuis HTTP : seule une valeur précisément égale à `next` provoque une action côté Spicetify.

API : https://spicetify.app/docs/development/api-wrapper/methods/player

## Préparation du test (sans toucher à v0.5)

Télécharger les 2 fichiers sous des **noms de préversion distincts** :

```powershell
$dir = "$env:LOCALAPPDATA\NowPlayingToast"
$ext = "$env:APPDATA\spicetify\Extensions"

Invoke-WebRequest "https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/now-playing-toast/v0.6/NowPlayingToast.ps1" -OutFile "$dir\NowPlayingToast-v0.6-preview.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/now-playing-toast/v0.6/now-playing-toast.js" -OutFile "$dir\now-playing-toast-v0.6-preview.js"
```

Cette étape ne touche pas à Spotify, ni à l'extension active, ni au raccourci Windows.

### Test d'intégration (à faire manuellement uniquement après sauvegarde)

1. Fermer entièrement Spotify.
2. Sauvegarder l'extension active `%APPDATA%\spicetify\Extensions\now-playing-toast.js`.
3. Copier la JS v0.6 dans le **même nom de fichier d'extension existant**, sans ajouter une seconde extension concurrente.
4. Exécuter `spicetify apply` pour charger cette JS.
5. Identifier puis arrêter **uniquement** le processus `powershell.exe` du compagnon v0.5 (pas tous les processus PowerShell), car le port 43827 ne peut être partagé.
6. Lancer `NowPlayingToast-v0.6-preview.ps1` via PowerShell 5.1 `-STA`, une console visible pour examiner les erreurs.
7. Ouvrir Spotify, laisser le toast apparaître, puis cliquer sur son bouton Suivant. Vérifier que la lecture passe bien au morceau suivant et que le toast se rafraîchit.
8. Vérifier que le glisser-déposer de v0.5 marche toujours, de même que `Ctrl + Maj + W`, l'année et les fondus.

**Ne pas modifier** le raccourci de démarrage Windows, qui pointe toujours vers la v0.5. Après le test, on peut arrêter la préversion, restaurer la JS v0.5, appliquer Spicetify et relancer le raccourci existant.

## Points à vérifier avant publication

- Bouton et clic sous Windows 11 avec `ShowActivated=False` et `WM_MOUSEACTIVATE`.
- Performances du polling à 700 ms, gestion des coupures entre Spotify et le compagnon.
- Compatibilité avec l'installation Spotify/SpotX existante, multi-écrans et mises à l'échelle.
- Revue de sécurité du serveur local et de la provenance des requêtes.
