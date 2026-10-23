# Now Playing Toast v0.5 — fenêtre déplaçable (préversion)

Cette version **expérimentale**, indépendante de la V0.4 installée, permet de déplacer le toast à la souris sans interrompre la musique.

## Fonctionnalités
- Clic gauche maintenu + glissement sur le toast entier.
- Lorsqu'on le survole ou qu'on le déplace, le compte à rebours est interrompu pour laisser le temps de choisir sa position ; ensuite il repart pour 7 secondes.
- Dernière position enregistrée dans `%LOCALAPPDATA%\NowPlayingToast\position.json`.
- Nouveau titre et `Ctrl + Maj + W` rouvrent la notification au même endroit.
- Fenêtre sans prise de focus grâce au traitement Win32 `WM_MOUSEACTIVATE → MA_NOACTIVATE`.
- Même afficheur et mêmes données Spotify que la V0.4 ; **aucune modification nécessaire de l'extension JS**.
- Aucun changement dans Spotify, SpotX ou Marketplace.

## Mise à l'essai sans remplacer V0.4

1. Télécharger la préversion sous un nom indépendant :
   
   ```powershell
   $dir = "$env:LOCALAPPDATA\NowPlayingToast"
   Invoke-WebRequest "https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/now-playing-toast/v0.5/NowPlayingToast.ps1" -OutFile "$dir\NowPlayingToast-DragPreview.ps1"
   ```

2. L'ancienne V0.4 **doit être arrêtée** avant le test : une seule instance peut utiliser `127.0.0.1:43827` et le raccourci. Identifier d'abord son processus PowerShell par sa ligne de commande, puis n'arrêter que celui-là. Ne jamais arrêter tous les `powershell.exe`.

3. Lancer cette préversion depuis PowerShell normal :
   
   ```powershell
   powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\NowPlayingToast\NowPlayingToast-DragPreview.ps1"
   ```

4. Spotify en cours de lecture : déclencher la notification par changement de morceau ou `Ctrl + Maj + W`, puis **cliquer-glisser sur le toast**. Attendre sa disparition et rappeler le toast pour vérifier la position conservée.

## Restaurer V0.4

Quitter le processus de préversion, puis relancer le raccourci Windows `Now Playing Toast.lnk` installé précédemment. Le fichier stable `NowPlayingToast.ps1` et son démarrage automatique n'ont pas été remplacés.

Pour retrouver la position par défaut en bas à droite, supprimer uniquement `%LOCALAPPDATA%\NowPlayingToast\position.json` après avoir fermé le compagnon. Ne pas supprimer `NowPlayingToast.ps1`.

## Limitations

**Non testé sur le Main PC à ce stade**. Certaines configurations multi-écrans ou différents facteurs d'échelle Windows peuvent nécessiter une correction supplémentaire de positionnement ; la validation doit se faire avant de promouvoir cette version à l'installation automatique.
