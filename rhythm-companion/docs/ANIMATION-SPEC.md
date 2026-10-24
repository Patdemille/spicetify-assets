# Animation source — spécification exploratoire J01

**Document de travail, pas une mesure de performance déjà validée.**

## Boucle de référence

- Cadence de référence : **120 BPM** (un temps toutes les 500 ms).
- Cycle proposé : **deux temps / 1 000 ms**. Permet une alternance des pattes, sans mouvement ultra-rapide.
- **8 poses clés indicatives** (position dans le cycle, pas nécessairement 8 images finales).
- Pour rendre la boucle cyclique, le dernier état doit rejoindre le premier sans saut.

| Position | Temps à 120 BPM | Pose / accent |
| --- | ---: | --- |
| 0 % | 0 ms | Tête haute, pattes au repos, queue vers l'extérieur |
| 12,5 % | 125 ms | Préparation du premier accent, tête descend |
| 25 % | 250 ms | Retombée / mouvement principal sur premier temps |
| 37,5 % | 375 ms | Rebond, oreilles/queue en mouvement |
| 50 % | 500 ms | Tête relevée, patte droite avance pour second temps |
| 62,5 % | 625 ms | Accent patte avant, corps stable |
| 75 % | 750 ms | Retour progressif, queue sur contretemps |
| 87,5 % | 875 ms | Anticipation du retour à l'état initial |

**Note importante :** la chronologie graphique ci-dessus est une *ébauche*, pas une carte de beats exacte. Le temps 0 et le temps 500 ms sont deux battements de référence ; la pose et les accents doivent être recadrés sur ces instants lors du storyboard final pour que la notion « bat la mesure » ait un sens.

## Supports source et exports

- Sources éditables idéales : dessin calqué / vectoriel / sprites propres, avec réglage de la position de chaque partie.
- Option vidéo : **WebM** contrôlable par `HTMLVideoElement.playbackRate`; la transparence, le codec et le décodage dans le navigateur de Spotify restent à confirmer par test.
- Option **spritesheet** : contrôle précis du temps / arrêt / phase par JavaScript ou animations CSS. Vérifier le coût CPU des transitions.
- Option **GIF** : uniquement aperçu/compatibilité, **ne pas promettre de contrôle fiable de vitesse d'un simple `<img>`**.
- Pour comparer le rendu : **0,75× / 1× / 1,25×**, démarrage, arrêt, reprise, transition entre boucles.

## Cas de test visuels

1. À 50 px, silhouette identifiable à une distance d'utilisation normale.
2. À 65 px, les deux accents (tête/patte) restent visibles.
3. À 80 px, absence de défaut d'animation et de recadrage.
4. Fond sombre et fond clair : contraste suffisant.
5. Plusieurs tours de boucle consécutifs : aucun décrochage perceptible.
6. Deux personnages simultanés (si exploité plus tard) : pas de saccade majeure introduite.

## À ne pas conclure prématurément

- La variation de `playbackRate` n'est **pas** à elle seule une synchro réelle sur la batterie/le beat du morceau.
- L'accès au BPM et à la phase musicale via Spicetify / Spotify doit être audité au jalon J03.
- Bender et BMO restent des modules séparés ; leur reprise comme source d'animation rythmique ne fait pas partie de J01.
