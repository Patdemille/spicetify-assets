# Adventure Time — BMO

**Extension Spicetify facultative et autonome** : affiche BMO (50 × 50 px) **à droite** de la barre de progression Spotify.

- Fichier : [`bmo.js`](bmo.js)
- Animation : GIF chargé via un lien tiers Tumblr provenant du pack historique. **Disponibilité du lien et droit de redistribution non vérifiés.**
- Aucune dépendance à Futurama, Bender ou Cat-Jam Mirror.
- Peut être activée **seule** ou **avec Bender** (BMO utilise `::before`, Bender `::after`).
- Source : règles BMO extraites de l'ancien [`characters-laptop.js`](../../main-pc-pack-v1/extensions/characters-laptop.js).

## Installer sur un PC Windows équipé de Spotify + Spicetify

1. Télécharger [le dépôt en ZIP](https://github.com/Patdemille/spicetify-assets/archive/refs/heads/main.zip) puis le décompresser.
2. Fermer complètement Spotify (y compris zone de notification).
3. Copier `characters/adventure-time/bmo.js` dans `%APPDATA%\spicetify\Extensions\bmo.js`.
4. Depuis un terminal utilisateur :

```powershell
spicetify config extensions bmo.js
spicetify apply
```

5. Rouvrir Spotify.

**Attention :** ne pas garder simultanément l'ancien `characters-laptop.js` ou une bribe CSS qui affiche déjà BMO ; désactiver l'ancien affichage avant ce nouveau module.

## Désactiver

Fermer Spotify, puis :

```powershell
spicetify config extensions bmo.js-
spicetify apply
```

Aucun programme supplémentaire ni démarrage Windows n'est nécessaire.

## Statut / droits

Version indépendante issue des styles du pack historique, **non encore testée isolément** sur Main ou Laptop. Le GIF étant servi depuis un site tiers, son affichage peut cesser si l'URL change ou devient inaccessible.

**Adventure Time et BMO sont des créations de leurs ayants droit** ; ce module non officiel n'implique aucune affiliation ni permission de redistribution du visuel.
