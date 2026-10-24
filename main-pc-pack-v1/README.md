# Spicetify Main PC — reprise du setup Laptop (archive)

> **ARCHIVE — ancien pack groupé, non recommandé pour les nouvelles installations.**
> Ce pack historique réunissait Bender + BMO + Cat-Jam Mirror pour reproduire une configuration personnelle. **Les projets sont désormais indépendants** :
> - [Futurama / Bender](../characters/futurama/README.md)
> - [Adventure Time / BMO](../characters/adventure-time/README.md)
> - [Cat-Jam Mirror](../cat-jam-mirror/README.md) (requiert Cat Jam Synced)
>
> On peut installer **un seul personnage, les deux, le miroir seul (avec son extension source)**, ou n'importe quelle combinaison. Les anciens scripts et réglages sont conservés ici **pour traçabilité, pas comme méthode de déploiement universelle**. Pour le Laptop, privilégier les nouveaux dossiers et tester un module à la fois.

Pack de migration **minimal** pour retrouver Bender à gauche, BMO à droite, et deux Cat-Jam synchronisés.

## Configuration visuelle gelée
- **Bender** : 60 × 60 px, `left:-8px`, `bottom:12px`, sur `::after`
- **BMO** : 50 × 50 px, `right:-8px`, `bottom:12px`, sur `::before`
- **Cat-Jam gauche** : miroir horizontal, `left:-55px`, `bottom:4px`, taille 65 px
- **Cat-Jam droit** : décalage `translateX(-15px)`
- La source Cat-Jam originale est fournie par l'extension **Cat Jam Synced** de BlafKing.

## Pré-requis
1. Windows + Spotify desktop avec **Spicetify CLI** installé. Ne pas modifier la version Spotify/SpotX.
2. Vérifier la compatibilité avant de mettre à jour CLI. La cible du laptop est Spicetify **2.46.2**.
3. Mettre à jour **Marketplace** depuis sa publication officielle ; la version du laptop est **1.0.12**.
4. Installer **Cat Jam Synced** via Marketplace pour disposer de `#catjam-webm`.

Sources :
- https://github.com/spicetify/cli/releases
- https://github.com/spicetify/marketplace/releases
- https://github.com/BlafKing/spicetify-cat-jam-synced

## Installation prudente sur Main
1. Télécharger le dépôt (bouton GitHub **Code → Download ZIP**) et extraire son dossier `main-pc-pack-v1`.
2. Fermer complètement Spotify.
3. Exécuter `scripts/01-backup.ps1` dans PowerShell **non administrateur**. Vérifier que la sauvegarde est sur le Bureau.
4. Mettre à jour séparément CLI et Marketplace selon les releases officielles. **Ne pas mettre à jour Spotify/SpotX**.
5. Installer/activer Cat Jam Synced dans Marketplace. Refermer Spotify.
6. Désactiver tout ancien snippet Bender/BMO sur Main pour éviter les doublons.
7. Exécuter `scripts/02-patch-and-install.ps1` depuis PowerShell. Le patch Marketplace ne se déclenche que sur la signature exacte observée sur le Laptop.
8. Ouvrir Spotify, contrôler les quatre personnages et les deux Cat-Jam.

**Attention :** scripts non testés sur Main ; aucune installation n'a été lancée à distance. Ils ne téléchargent aucun binaire et ne modifient pas Spotify/SpotX. Les assets Bender/BMO restent chargés depuis leurs URL publiques d'origine (pas de redistribution de GIF protégés dans le pack). Un correctif local Marketplace n'est pas une solution universelle. Les thèmes, Spicy Lyrics et Nyan Cat ne sont pas inclus.
