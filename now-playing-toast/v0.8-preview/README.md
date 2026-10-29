# Now Playing Toast v0.8-preview — raccourci fiable lorsque Spotify est minimisé

**Statut : correctif expérimental, pas encore testé sur Laptop ni Main (29 octobre 2026).**
La version stable utilisée sur Main/Laptop reste **v0.7** jusqu'à validation.

## Bug constaté

Après avoir minimisé Spotify quelque temps, **Ctrl + Maj + W** peut cesser d'afficher le Toast. Restaurer puis minimiser Spotify le rétablit. La V0.7 du compagnon refusait l'affichage lorsque le dernier message de l'extension Spotify avait plus de **20 secondes** :

```powershell
if (-not $script:hasTrack -or ([DateTime]::UtcNow - $script:lastMessageAt).TotalSeconds -gt 20) { return }
```

L'extension V0.7 envoie des données toutes les **4 secondes** avec un timer JavaScript, susceptible d'être ralenti/suspendu quand la fenêtre est en arrière-plan. Cette combinaison fournit une cause vraisemblable du symptôme, mais **n'exclut pas** d'autres problèmes de raccourci/processus.

## Correctif v0.8-preview

- **Le raccourci Windows `Ctrl + Maj + W` peut afficher le Toast même si le dernier échantillon dépasse 20 s.**
- Quand les données sont anciennes : affichage de la dernière pochette/titre reçus avec le message **`Infos Spotify en attente de mise a jour`** ; boutons **Suivant** et **Titres likés** temporairement inactifs, afin d'éviter d'agir sur des données périmées.
- Quand le JavaScript Spotify recommence à fournir les données, les boutons se réactivent et les informations sont actualisées.
- L'affichage spontané au changement de morceau conserve la vérification de fraîcheur ; ce correctif ne prétend pas contourner la mise en veille du moteur de Spotify.
- Le compagnon utilise toujours le port local **127.0.0.1:43827**, le même raccourci Windows et le même fichier `position.json`.
- Le fichier JavaScript V0.7 **ne change pas**. **Pas de modification de Spotify ou SpotX**, ni des autres extensions.

## Test manuel sans risque pour le Laptop

1. **Ne rien appliquer tant que l'installation v0.7 fonctionne et que le test n'est pas souhaité.**
2. Copier le compagnon actuel `%LOCALAPPDATA%\NowPlayingToast\NowPlayingToast.ps1` en sauvegarde horodatée.
3. Télécharger **uniquement** [`NowPlayingToast.ps1`](NowPlayingToast.ps1) dans un dossier de staging ; vérifier son en-tête v0.8-preview et la taille.
4. Arrêter **uniquement** le processus PowerShell/WPF qui héberge le compagnon sur le port 43827, en vérifiant sa ligne de commande.
5. Copier le compagnon v0.8-preview dans l'emplacement habituel ; ne pas relancer `spicetify apply` (JS inchangé).
6. Démarrer avec le raccourci Windows déjà présent ; vérifier `http://127.0.0.1:43827/health`, les boutons et le raccourci, y compris après une longue période avec Spotify minimisé.
7. En cas de régression : arrêter le compagnon, restaurer le fichier v0.7 sauvegardé et le relancer. La position et le raccourci sont inchangés.

## Limites et prochains contrôles

- Si le compagnon **meurt**, si le raccourci Windows n'a jamais été enregistré, ou si les événements de clavier n'atteignent pas le compagnon, cette modification ne suffit pas. Vérifier alors le processus, le port et les journaux.
- La notification peut afficher **le dernier morceau connu, pas forcément le morceau actuel**, si Spotify n'envoie plus de métadonnées : le message l'indique explicitement.
- Un test utilisateur doit confirmer la résolution avant promotion en version stable.
