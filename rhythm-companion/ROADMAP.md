# Roadmap — Rhythm Companion

**Date de lancement : 24/10/2026.** Phases suivies dans les Issues GitHub et les documents du dossier. Les versions sont des **cibles prévisionnelles**, pas des livraisons annoncées.

| Phase | Cible | Livrable mesurable | État |
| --- | --- | --- | --- |
| **[J01 — Chat original](https://github.com/Patdemille/spicetify-assets/issues/1)** | V0.1 | Identité visuelle, poses sources, boucle animée contrôlable et test de lisibilité à 50–80 px | **EN COURS — conception initiale** |
| [J02 — Affichage](https://github.com/Patdemille/spicetify-assets/issues/2) | V0.2 | Extension Spicetify sans Cat Jam Synced : affiche 1 chat, position et taille, duo miroir optionnel, réglages persistants | À faire |
| [J03 — Rythme](https://github.com/Patdemille/spicetify-assets/issues/3) | V0.3 | Modes libre / tempo connu / synchronisation avancée seulement si signal de beat disponible ; pause/reprise fiables | À faire |
| [J04 — Interface](https://github.com/Patdemille/spicetify-assets/issues/4) | V0.4 | Paramètres dans Spotify : personnage, côtés, taille, décalage, mode, vitesse ; aucune modification JS pour les réglages usuels | À faire |
| [J05 — Publication](https://github.com/Patdemille/spicetify-assets/issues/5) | V1.0 candidate | Tests Main puis Laptop, installation/desinstallation, doc, attributions, droits, diffusion GitHub, étude Marketplace | À faire |

**Suivi détaillé J01 :** [#6 Design](https://github.com/Patdemille/spicetify-assets/issues/6) · [#7 Animation](https://github.com/Patdemille/spicetify-assets/issues/7) · [#8 Tests](https://github.com/Patdemille/spicetify-assets/issues/8).

## Principaux risques / dépendances

- **Cadence ≠ beat détecté** : ne pas confondre une animation à vitesse variable avec une synchronisation précise des battements.
- **GIF** : sa vitesse n'est pas directement réglable via un élément `img` ; WebM / sprites sont candidats, à comparer.
- **Spotify/Spicetify** : les classes CSS changent selon les versions ; cibler sélecteurs stables lorsque disponibles.
- **Performance** : éviter les recalculs continus de disposition; benchmark 1 et 2 personnages.
- **Droits** : créer une identité et des fichiers originaux, documenter la provenance et les conditions de diffusion.
- **Bender/BMO** : des visuels et personnages préexistants imposent un examen séparé des droits avant toute publication ; leur conversion au moteur reste un **chantier ultérieur et facultatif**.

## Séquence de validation

- **J01** : direction artistique provisoire → validation créative → poses clés → animation source → export(s) → essai de lisibilité / vitesse → validation de sortie.
- **J02** : branche prototype distincte → essai sur Main → correction → puis Laptop, après accord.
- **J03-J05** : ne pas promettre de fonctions d'analyse audio non vérifiées.

## Décisions

Voir [DECISIONS.md](docs/DECISIONS.md) pour les choix confirmés, hypothèses et points non tranchés. Toute fin de jalon exige un test ou un livrable vérifiable, pas seulement l'écriture du plan.
