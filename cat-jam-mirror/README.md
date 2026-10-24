# Cat-Jam Mirror — extension Spicetify indépendante

**Module facultatif**, destiné à afficher **un second Cat-Jam en miroir**, synchronisé avec le Cat-Jam d'origine. Ce projet est **séparé** de [Futurama/Bender](../characters/futurama/README.md) et [Adventure Time/BMO](../characters/adventure-time/README.md) : aucun des deux personnages n'est requis, et le miroir ne les installe pas.

## Dépendance réelle

L'extension **[Cat Jam Synced de BlafKing](https://github.com/BlafKing/spicetify-cat-jam-synced)** doit déjà être active dans Spotify : elle fournit l'élément `#catjam-webm`. **Sans Cat Jam Synced, Mirror n'affiche rien.**

Le miroir est distinct du Cat Jam d'origine : activer le miroir **n'installe pas automatiquement** le module de BlafKing.

## Réglages du fichier

- Fichier indépendant : [`catjam-mirror.js`](catjam-mirror.js).
- Taille du miroir : **65 px**.
- Miroir gauche : `left: -55px`, `bottom: 4px`.
- Décalage du Cat-Jam d'origine : `-158px`.
- Synchronisation : 150 ms ; correction si dérive supérieure à 0,12 s.

Ces valeurs proviennent du **dernier paramétrage Main explicitement relevé** ; une retouche locale à 78 px a été envisagée ensuite, mais **sa validation n'est pas établie**. Ce dossier est donc une extraction **à revalider visuellement** avant de l'utiliser comme pack de reproduction exacte de Main. L'ancien code du pack `main-pc-pack-v1` conserve ses valeurs archivées (`-15px`) et n'a pas été écrasé.

## Installation Windows

1. Vérifier que **Cat Jam Synced est installé et actif** via Marketplace.
2. Télécharger [le dépôt en ZIP](https://github.com/Patdemille/spicetify-assets/archive/refs/heads/main.zip), décompresser et fermer Spotify.
3. Copier `cat-jam-mirror/catjam-mirror.js` dans `%APPDATA%\spicetify\Extensions\catjam-mirror.js`.
4. Exécuter :

```powershell
spicetify config extensions catjam-mirror.js
spicetify apply
```

5. Rouvrir Spotify, vérifier les deux chats et leur alignement.

**Important :** ne pas installer cette copie en parallèle d'une autre version de `catjam-mirror.js`. Sauvegarder les réglages locaux avant tout remplacement ; le but est de laisser les personnalisations existantes en place tant que le module n'est pas validé sur la machine.

## Désactivation

Fermer Spotify, puis :

```powershell
spicetify config extensions catjam-mirror.js-
spicetify apply
```

Aucun PowerShell permanent ni démarrage automatique avec Windows.

## Combinaisons possibles

- Cat Jam Synced **seul** : un seul chat.
- Cat Jam Synced **+ Mirror** : deux chats synchronisés.
- Ces choix sont indépendants des modules **Bender** et **BMO** : chacun peut être activé ou non.

Vérifier la compatibilité avec les futures versions Spotify/Spicetify et respecter les droits/crédits du créateur de Cat Jam Synced.
