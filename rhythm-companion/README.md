# Rhythm Companion

**Projet en cadrage — lancé le 24/10/2026.** Nouvelle extension Spicetify de personnages animés originaux, avec un moteur réutilisable (et indépendant) pour la lecture et le contrôle d'animations.

> **Statut : jalon J01 (concept visuel du chat original) EN COURS.** Aucun plugin fonctionnel ni animation finale n'existe à cette étape. Aucune installation sur Main ou Laptop.

## Ambition

Créer **notre propre chat danseur** et un moteur d'animation indépendant de Cat Jam Synced. Le personnage doit battre la mesure et rester lisible dans la barre de progression Spotify, sans sacrifier les performances de l'interface.

À terme, le moteur pourra être **utilisé en option** pour animer Bender et BMO, mais **Futurama/Bender**, **Adventure Time/BMO** et **Cat-Jam Mirror** restent des projets installables séparément. Aucun de ces trois projets n'est une dépendance requise.

## Suivi des jalons dans GitHub Issues

- **[J01 — Chat original (en cours)](https://github.com/Patdemille/spicetify-assets/issues/1)** : jalon lancé le 24/10/2026.
- [J01.1 — Valider le design](https://github.com/Patdemille/spicetify-assets/issues/6)
- [J01.2 — Réaliser la boucle](https://github.com/Patdemille/spicetify-assets/issues/7)
- [J01.3 — Tester les exports](https://github.com/Patdemille/spicetify-assets/issues/8)
- Jalons futurs : [J02](https://github.com/Patdemille/spicetify-assets/issues/2), [J03](https://github.com/Patdemille/spicetify-assets/issues/3), [J04](https://github.com/Patdemille/spicetify-assets/issues/4), [J05](https://github.com/Patdemille/spicetify-assets/issues/5).

## Documentation

- [Feuille de route / états de validation](ROADMAP.md)
- [Jalon J01 — objectifs, travaux et critères de sortie](docs/JALON-01.md)
- [Brief créatif du chat original (première proposition à valider)](docs/CREATIVE-BRIEF.md)
- [Spécification d'animation : poses, tempo, formats](docs/ANIMATION-SPEC.md)
- [Journal des décisions et questions ouvertes](docs/DECISIONS.md)
- [Dossier de futurs assets originaux](assets/original-cat/README.md)

## Principes

1. **Indépendance** : aucun besoin de Cat Jam Synced, Cat-Jam Mirror, Bender ou BMO pour fonctionner.
2. **Originalité** : personnage, animations et logique applicative conçus spécialement pour le projet ; ne pas importer le GIF ou copier le code d'un autre plugin.
3. **Portable** : installation Spicetify simple, sans processus supplémentaire lancé au démarrage de Windows.
4. **Performance** : légèreté, gestion pause/reprise, évitement de mesures DOM répétées.
5. **Honnêteté de synchronisation** : une cadence d'animation n'est pas automatiquement une véritable détection des temps musicaux.
6. **Réversibilité** : développement isolé, pas d'écrasement des extensions déjà utilisées.

## Point technique crucial

La vitesse d'un GIF dans une balise HTML `img` ne peut pas être pilotée simplement par une API standard de lecture. **Le GIF peut servir d'asset source / d'aperçu**, mais le moteur privilégiera un média contrôlable (`video.playbackRate` avec un format adapté, ou spritesheet/frames pilotées) pour faire varier la cadence. L'usage de WebM avec transparence et son comportement dans l'environnement Spotify devra être validé avant d'être retenu comme seul format.

La progression de Spotify ne fournit pas systématiquement le **BPM** ou la **phase des battements**. Le J01 est consacré **au personnage et à sa boucle autonome**, pas à la promesse d'une synchronisation parfaite avec chaque titre.

## État des machines

| Élément | Main | Laptop |
| --- | --- | --- |
| Rhythm Companion | **Non installé** | **Non installé** |
| Chat original | Concept en préparation | Non installé |
| Moteur tempo | Non développé | Non développé |

## Publication

Dépôt GitHub d'abord ; examen d'une intégration Marketplace après une version documentée et validée. Vérifier la provenance, les droits de chaque asset et la compatibilité avant distribution. Des contenus générés par IA ne garantissent pas à eux seuls une exclusivité juridique mondiale : conserver les fichiers sources et le journal de création.
