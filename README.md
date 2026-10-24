# spicetify-assets

Personnalisations **Spotify + Spicetify** conservées sur GitHub pour pouvoir retrouver le même environnement sur plusieurs machines (**Main**, puis **Laptop**) et, à terme, partager les extensions avec d'autres utilisateurs.

**Dépôt public :** https://github.com/Patdemille/spicetify-assets

> **Important :** ce dépôt rassemble des composants et sauvegardes à des stades différents. **Ne pas appliquer tout le dépôt d'un bloc.** Installer les modules souhaités individuellement, après sauvegarde de la configuration locale. Aucune distribution du client Spotify modifié ou de SpotX.

## Modules indépendants — choisissez ceux que vous voulez

| Module | Emplacement | Statut / installation |
| --- | --- | --- |
| **Rhythm Companion — nouveau projet** | [rhythm-companion/](rhythm-companion/) | **J01 lancé le 24/10/2026** : création d'un chat original et préparation d'un moteur d'animation indépendant. Aucun plugin ni asset final livré à ce stade. [Roadmap](rhythm-companion/ROADMAP.md) · [Issue J01](https://github.com/Patdemille/spicetify-assets/issues/1). |
| **Sidebar Free Resize** | [sidebar-free-resize/](sidebar-free-resize/) | **v0.2 validée sur Main (24/10/2026)** : élargit à la demande le panneau droit au-delà de 420 px. Autonome, démarre avec Spotify, sans processus PowerShell permanent. [Instructions](sidebar-free-resize/README.md). **Laptop à tester.** |
| **Now Playing Toast** | [now-playing-toast/v0.7/](now-playing-toast/v0.7/) | v0.7 testée sur Main : popup Windows avec commandes Suivant / Titres likés. **Contrairement aux extensions Spicetify seules, utilise un compagnon PowerShell/WPF Windows**, voir sa documentation spécifique. Laptop à harmoniser. |
| **Futurama — Bender** | [characters/futurama/](characters/futurama/) | Personnage Bender à gauche de la progression. **Installation indépendante** ; peut être utilisé seul ou avec BMO. [Instructions](characters/futurama/README.md). Extraction du pack ancien, test isolé restant à faire. |
| **Adventure Time — BMO** | [characters/adventure-time/](characters/adventure-time/) | Personnage BMO à droite de la progression. **Installation indépendante** ; peut être utilisé seul ou avec Bender. [Instructions](characters/adventure-time/README.md). Extraction du pack ancien, test isolé restant à faire. |
| **Cat-Jam Mirror** | [cat-jam-mirror/](cat-jam-mirror/) | Double le chat en miroir. **Sans lien obligatoire avec Bender/BMO** ; nécessite seulement [Cat Jam Synced](https://github.com/BlafKing/spicetify-cat-jam-synced). [Instructions](cat-jam-mirror/README.md). Réglages Main à revérifier. |
| **Ancien pack groupé (archive)** | [main-pc-pack-v1/](main-pc-pack-v1/) | Ancienne méthode qui associait Bender, BMO et Cat-Jam Mirror. **Conservée pour historique, pas recommandée pour de nouvelles installations**. Certaines valeurs ne sont plus à jour. |
| **Historique Sidebar Free Resize** | [experiments/sidebar-free-resize/](experiments/sidebar-free-resize/) | v0.1 et v0.2 conservées pour comparaison et retour arrière. |

**À la carte :** installer uniquement **Futurama**, uniquement **Adventure Time**, les deux, **Cat-Jam Mirror**, ou toute combinaison. Aucun personnage n'est imposé par l'installation du miroir. Le miroir exige toutefois **Cat Jam Synced** pour fournir le chat d'origine.

**Rhythm Companion est en phase de conception** : aucune procédure d'installation ni plugin exécutable n'est encore proposé. Il n'affecte pas les autres modules.

## Déployer sur une autre machine

1. **Faire une sauvegarde** de `%APPDATA%\spicetify` et identifier les modules déjà actifs.
2. Vérifier la **version de Spotify**, la compatibilité Spicetify et les dépendances. Ne jamais mettre à jour une version modifiée de Spotify uniquement pour un module.
3. Télécharger le dépôt (**Code → Download ZIP**) ou récupérer le fichier de l'extension voulue.
4. Suivre **le README propre au module**. Pour Sidebar Free Resize, le script `sidebar-free-resize/install.ps1` fonctionne **une seule fois**, depuis le ZIP local, puis l'extension tourne uniquement dans Spotify.
5. Tester chaque modification séparément. Ne pas activer simultanément un CSS de largeur fixe et Sidebar Free Resize.
6. Pour Bender et BMO, **désactiver l'ancien `characters-laptop.js` ou les bribes de personnages équivalentes avant d'activer les modules séparés**, afin d'éviter les doublons.

## Machines et validation

| Composant | Main | Laptop |
| --- | --- | --- |
| Sidebar Free Resize v0.2 | ✅ Fonctionne, déplacement parfois saccadé | ⏳ À installer/tester |
| Now Playing Toast v0.7 | ✅ Commandes validées | ⏳ À aligner et tester |
| Futurama / Bender (module séparé) | CSS issu du pack Main ; **version séparée à tester** | CSS historique présent ; migration facultative à tester |
| Adventure Time / BMO (module séparé) | CSS issu du pack Main ; **version séparée à tester** | CSS historique présent ; migration facultative à tester |
| Cat-Jam Mirror (module séparé) | Cat-Jam miroir présent ; réglages publiés à revérifier | Cat-Jam présent ; confirmer les positions avant migration |

Environnement Main utilisé pour la validation Sidebar Free Resize : **Windows 11, Spotify 1.3.3.264.gdaf3b824, Spicetify CLI 2.46.2**. Ces tests ne garantissent pas la compatibilité avec toutes les versions de Spotify.

## À consolider avant une diffusion générale

- **Synchroniser les versions réellement utilisées sur Main et Laptop** (en particulier Cat-Jam : taille et positions ont été retouchées après le premier pack GitHub).
- Tester séparément les nouveaux modules **Futurama/Bender**, **Adventure Time/BMO** et **Cat-Jam Mirror** avant d'annoncer leur stabilité sur d'autres PC.
- Documenter pour chaque module : dépendances, fichiers à installer, compatibilité, captures d'écran, désinstallation.
- Vérifier les **droits de redistribution** et crédits des GIF/visuels externes.
- Pour les extensions adaptées à un usage général : envisager une publication **Spicetify Marketplace**. À défaut, ce dépôt GitHub public sert de source d'installation indépendante.

## Périmètre

Les fichiers Spicetify `.js` s'exécutent **dans Spotify** ; ils ne nécessitent pas de programme résident lancé avec Windows. Cette remarque **ne s'applique pas** au compagnon Windows de Now Playing Toast. Ce dépôt n'intègre ni binaire Spotify/SpotX, ni identifiants, ni configuration sensible.
