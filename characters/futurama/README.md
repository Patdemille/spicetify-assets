# Futurama — Bender

**Extension Spicetify facultative et autonome** : affiche Bender (60 × 60 px) **à gauche** de la barre de progression Spotify.

- Fichier : [`bender.js`](bender.js)
- Animation : [`Bender_danse_nettoye_anime.gif`](../../Bender_danse_nettoye_anime.gif), actuellement hébergée à la racine du dépôt GitHub.
- Aucune dépendance à BMO, Adventure Time ou Cat-Jam Mirror.
- Peut être activée **seule** ou **avec BMO** (Bender utilise `::after`, BMO `::before`).
- Source : règles Bender extraites de l'ancien [`characters-laptop.js`](../../main-pc-pack-v1/extensions/characters-laptop.js), sans modification de la taille/position.

## Installer sur un PC Windows équipé de Spotify + Spicetify

1. Télécharger [le dépôt en ZIP](https://github.com/Patdemille/spicetify-assets/archive/refs/heads/main.zip) puis le décompresser.
2. Fermer complètement Spotify (y compris zone de notification).
3. Copier `characters/futurama/bender.js` dans `%APPDATA%\spicetify\Extensions\bender.js`.
4. Depuis le terminal utilisateur, lancer :

```powershell
spicetify config extensions bender.js
spicetify apply
```

5. Rouvrir Spotify.

**Attention :** si l'ancien `characters-laptop.js` ou une bribe CSS affiche déjà Bender/BMO, désactiver d'abord cet ancien module pour éviter le cumul. Les autres extensions continuent de fonctionner.

## Désactiver

Fermer Spotify, puis :

```powershell
spicetify config extensions bender.js-
spicetify apply
```

Aucun lancement au démarrage de Windows ni programme externe n'est nécessaire : ce fichier est exécuté uniquement dans Spotify.

## Statut / droits

Version séparée construite à partir du pack historiquement utilisé, **non encore testée isolément** sur Main ou Laptop. Les versions Spotify 1.3.x peuvent modifier leurs sélecteurs CSS.

**Futurama et Bender ne sont pas affiliés à ce dépôt.** Les droits d'usage et redistribution du GIF doivent être confirmés avant sa diffusion plus large.
