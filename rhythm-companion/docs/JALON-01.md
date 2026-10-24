# J01 — Création du chat original

**Ouvert le 24 octobre 2026. Statut : EN COURS (phase de conception).**

## Objectif

Obtenir un chat danseur **original et immédiatement reconnaissable** en petite taille, avec une boucle régulière, légère et qui puisse accélérer/ralentir proprement. Le rendu sera le premier pack d'assets de Rhythm Companion, sans dépendre de Cat Jam Synced.

## Livrables attendus

- [ ] Direction artistique du personnage **validée** (silhouette, palette, détails).
- [ ] Dessins des **poses clés** sur des calques / fichiers sources éditables.
- [ ] Première boucle animée **sans saut visible** (durée nominale cible 1 s à 120 BPM, sur deux temps).
- [ ] Export d'un format réellement contrôlable en vitesse (spritesheet ou vidéo compatible) ; GIF d'aperçu facultatif.
- [ ] Vérification sur fond Spotify sombre **et** clair, tailles 50 / 65 / 80 px, absence de débordement.
- [ ] Vérification à plusieurs cadences (par exemple 0,75× / 1× / 1,25×) et comparaison de fluidité.
- [ ] Archivage des sources, choix artistiques, paramètres d'export, provenance et contraintes de licence.

## Première proposition de personnage (non validée)

Un **chat stylisé techno-musical**, avec silhouette ronde, casque / écouteurs stylisés (sans logo), une oreille asymétrique reconnaissable, un bout de queue lumineux, pattes avant faisant les accents rythmiques. Palette de travail : **bleu nuit, crème clair, accent turquoise / orange doux**, à ajuster avec le rendu.

Proposition de boucle : tête haut → baisse sur temps 1 → retour → patte levée → accent sur temps 2 → retour, queue mobile et clignement occasionnel. Le personnage garde une ligne de sol stable pour paraître « assis sur la barre ».

**Cette description est une base de travail, pas une DA imposée.** La validation de la silhouette doit précéder les exports finaux.

## Spécifications initiales

Lire [ANIMATION-SPEC.md](ANIMATION-SPEC.md). Recommandation de test : composer l'animation comme **8 poses de contrôle dans un cycle de 1 000 ms** (deux temps à 120 BPM), exportées depuis une source modifiable. Les images intermédiaires peuvent être interpolées au besoin. Une « image de chat » ne vaut pas encore une animation validée.

## Critères de sortie J01

La fin du jalon est autorisée uniquement si :
1. L'identité du chat et la palette ont été approuvées.
2. Les sources de l'animation sont présentes dans `assets/original-cat/`.
3. Une boucle contrôlable et lisible à 50–80 px a été testée.
4. Les éléments sont suffisamment autonomes pour développer le moteur d'affichage J02.
5. La provenance et les droits de diffusion des éléments sont documentés.

**État actuel :** dossier de projet + brief + séquence de poses proposés. **Pas encore de création graphique finale ni de boucle animée testée.**
