# Now Playing Toast v0.6 — Skip / morceau suivant

> **Statut au 23/10/2026 : validée sur Main** (bouton Suivant opérationnel, fonctionnement de la notification et démarrage du compagnon vérifiés). **Laptop pas encore mis à jour vers v0.6.** La V0.5 reste disponible pour revenir en arrière. Publication Marketplace et audit de sécurité non réalisés.

## Fonctionnement

- Même apparence que v0.5 (442 × 156, 7 s, fondus, pochette, année, barre de progression).
- Bouton « morceau suivant » (double flèche et barre) en haut à droite, cliquable à la souris.
- Le clic envoie **uniquement** la commande `next` dans une petite file locale du compagnon Windows.
- L'extension JavaScript interroge `GET http://127.0.0.1:43827/control` toutes les 700 ms ; à la réception de `next`, elle appelle `Spicetify.Player.next()`.
- `POST /track` (métadonnées) et `GET /health` (diagnostic) restent inchangés.
- Déplacement à la souris : cliquer sur le fond du toast, pas sur le bouton. L'animation est toujours suspendue pendant le survol.
- Le compagnon écoute seulement `127.0.0.1`. Pas de commande arbitraire depuis HTTP : seule une valeur précisément égale à `next` provoque une action côté Spicetify.

API : https://spicetify.app/docs/development/api-wrapper/methods/player

## Mettre à jour une installation existante V0.5 sur Laptop

L'ordinateur portable possède déjà une installation opérationnelle. Il est inutile de réinstaller Spicetify ou de reconfigurer le raccourci Windows.

1. Fermer **complètement Spotify**, y compris dans la zone de notification.
2. Ouvrir **Windows PowerShell en utilisateur normal**, puis télécharger le script de mise à jour :

```powershell
$dir = "$env:LOCALAPPDATA\NowPlayingToast"
Invoke-WebRequest "https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/now-playing-toast/v0.6/Update-Existing-Installation.ps1" -OutFile "$dir\Update-Existing-Installation.ps1"
notepad "$dir\Update-Existing-Installation.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$dir\Update-Existing-Installation.ps1"
```

Le script sauvegarde les **deux** composants V0.5 dans un dossier horodaté, récupère les sources V0.6, vérifie les en-têtes et la taille des téléchargements, copie les fichiers, puis exécute `spicetify apply`. Il ne touche pas à Spotify/SpotX, Cat-Jam ou Marketplace et conserve le raccourci Windows existant.

3. **Redémarrer Windows** et ouvrir la session. Le raccourci existant lancera alors le compagnon V0.6 sans fenêtre. Le redémarrage est nécessaire car le compagnon V0.5 déjà chargé en mémoire ne se remplace pas à chaud.
4. Lancer Spotify et vérifier : bouton **Suivant**, `Ctrl+Maj+W`, déplacement de la fenêtre, année/pochette et disparition automatique.

Vérification réseau si nécessaire :

```powershell
Invoke-RestMethod 'http://127.0.0.1:43827/health' -TimeoutSec 5
```

Réponse attendue : `Now Playing Toast OK`.

**Retour arrière :** dans le dossier de sauvegarde indiqué par le script, remettre les anciennes copies de `NowPlayingToast.ps1` et `now-playing-toast.js` à leurs emplacements d'origine, fermer Spotify, appliquer Spicetify, puis redémarrer Windows. Le raccourci ne nécessite pas de modification.

## Historique du premier test sur Main

La V0.6 a d'abord été testée sous des noms de fichiers de prévisualisation, sans modifier le compagnon V0.5 actif, puis installée à la place de V0.5. Le bouton a été vérifié fonctionnel, y compris son déclenchement du passage au morceau suivant. La copie seule du compagnon ne démarrait pas le processus ; la relance du raccourci Windows a résolu ce point.

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

## Points à vérifier avant publication Marketplace

- Bouton et clic sous Windows 11 avec `ShowActivated=False` et `WM_MOUSEACTIVATE`.
- Performances du polling à 700 ms, gestion des coupures entre Spotify et le compagnon.
- Compatibilité avec l'installation Spotify/SpotX existante, multi-écrans et mises à l'échelle.
- Revue de sécurité du serveur local et de la provenance des requêtes.
