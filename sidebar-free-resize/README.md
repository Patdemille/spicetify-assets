# Sidebar Free Resize — panneau droit Spotify librement redimensionnable

Extension **Spicetify JavaScript** autonome : autorise à agrandir le panneau droit Spotify au-delà du plafond natif observé à **420 px**, en faisant glisser une nouvelle zone de redimensionnement sur son bord gauche.

**Version de référence : v0.2** — validée fonctionnelle par l'utilisateur sur **Main le 24 octobre 2026**. Le glissement reste parfois saccadé mais répond au besoin. **Laptop non testé.** Cette version de référence est une copie à l'identique de \`../experiments/sidebar-free-resize/v0.2/sidebar-free-resize.js\`.

## Fonctionnalités

- Glisser le bord **gauche** de la sidebar de Spotify pour en augmenter ou réduire la largeur.
- Plage indicative **280 à 800 px** ; limite effective aussi liée à la taille de la fenêtre (le script réserve 500 px aux autres zones).
- Mémorisation de la dernière largeur sélectionnée dans le \`localStorage\` de Spotify.
- Aucun service local, aucune fenêtre PowerShell permanente, **aucune tâche au démarrage de Windows** : le JavaScript ne tourne que lorsque Spotify/Spicetify fonctionne.
- N'altère pas les fichiers binaires de Spotify, SpotX, Cat-Jam, Characters ou Now Playing Toast.

## Compatibilité testée

| Élément | Configuration validée sur Main |
| --- | --- |
| Système | Windows 11 |
| Spotify | 1.3.3.264.gdaf3b824 (installation utilisateur modifiée, **non distribuée**) |
| Spicetify CLI | 2.46.2 |
| Extension | Sidebar Free Resize v0.2 |
| Marketplace | Pas nécessaire pour exécuter cette extension |

La compatibilité avec d'autres builds Spotify, macOS, Linux, ou des thèmes modifiant profondément la grille **n'est pas établie**.

## Installation sur un autre PC (ex. Laptop)

**Prérequis :** Spotify desktop et Spicetify CLI opérationnels. Ne pas remplacer ni mettre à jour Spotify/SpotX uniquement pour cette extension.

### Option A — Depuis le ZIP GitHub (sans téléchargement par PowerShell)

1. Télécharger le dépôt via **Code → Download ZIP** et le décompresser.
2. Fermer complètement Spotify, y compris son icône dans la zone de notification.
3. Dans le dossier décompressé \`sidebar-free-resize\`, exécuter **une seule fois** le script \`install.ps1\` via PowerShell utilisateur (pas administrateur). Il sauvegarde une éventuelle copie existante, installe l'extension, l'active dans Spicetify et exécute \`spicetify apply\`.
4. Rouvrir Spotify. Placer la souris sur le bord gauche du panneau droit, puis glisser.

PowerShell sert **uniquement à l'installation**. Une fois le script terminé, il n'est plus nécessaire.

### Option B — Installation manuelle sans script d'installation

1. Fermer Spotify.
2. Copier \`sidebar-free-resize.js\` vers :
   \`\`\`text
   %APPDATA%\spicetify\Extensions\sidebar-free-resize.js
   \`\`\`
3. Dans un terminal où Spicetify CLI est disponible, exécuter :
   \`\`\`powershell
   spicetify config extensions sidebar-free-resize.js
   spicetify apply
   \`\`\`
4. Rouvrir Spotify.

**Ne pas activer simultanément** la bribe CSS expérimentale qui fixe la largeur à 560 px ou une autre extension modifiant cette même largeur.

## Désactivation / retour arrière

Fermer Spotify, puis :

\`\`\`powershell
spicetify config extensions sidebar-free-resize.js-
spicetify apply
\`\`\`

Le fichier JavaScript peut rester installé mais inactif. Pour le réactiver : \`spicetify config extensions sidebar-free-resize.js\` puis \`spicetify apply\`.

Une sauvegarde datée \`sidebar-free-resize.js.bak-AAAAMMJJ-HHMMSS\` est créée par \`install.ps1\` lorsqu'une version existe déjà. Elle n'est pas supprimée automatiquement.

## Limitations connues et évolutions envisagées

- La nouvelle tirette peut présenter des **saccades** : Spotify réorganise la grille pendant le déplacement. v0.2 limite les recalculs JavaScript mais ne supprime pas toute la charge de mise en page.
- Le panneau doit exister et conserver l'ID HTML \`Desktop_PanelContainer_Id\`. Une mise à jour Spotify pourrait imposer une nouvelle adaptation.
- La taille peut être inférieure à 800 px si l'écran n'offre pas assez d'espace.
- Pas de publication Marketplace à ce stade. Le **dépôt GitHub public** est le canal d'installation et de partage ; soumettre ensuite l'extension au Marketplace pourra nécessiter une adaptation de son empaquetage et de sa documentation.

## Historique

- **v0.1** : preuve de concept, glisser-déposer fonctionnel ; code dans \`../experiments/sidebar-free-resize/sidebar-free-resize.js\`.
- **v0.2** : réduction des lectures de mise en page par mouvement et rafraîchissement calé sur \`requestAnimationFrame\`; validée fonctionnelle sur Main (pas de gain majeur de fluidité constaté).
- **Prochaine étape** : test sur Laptop, sans changer les personnalisations déjà présentes.

## Partage public

Cette extension est uniquement du **code Spicetify ajouté au client**. Ce dépôt **ne fournit pas Spotify modifié, SpotX ni des fichiers propriétaires du client**. Pour une diffusion élargie, vérifier les droits/licences des autres GIF et contenus du dépôt indépendamment de cette extension.
