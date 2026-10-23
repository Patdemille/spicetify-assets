# Now Playing Toast — prototype V0.2 (Windows 11)

Une **démo locale** pour valider le design et le raccourci global **Ctrl + Alt + .**.

## Ce que fait cette version
- Affiche un toast anthracite en **bas à droite**, avec bordure discrète et **coins arrondis (16 px)**.
- Pochette de substitution carrée avec **coins légèrement arrondis (11 px)**, alignée sur la hauteur du texte.
- Affiche des **données fictives** Get Lucky / Daft Punk / Random Access Memories / 2013 / 6:09.
- Disparaît après **5 secondes**.
- Réapparaît pendant 5 secondes en appuyant sur **Ctrl + Alt + .**, même si Spotify est réduit.
- Ne modifie **ni Spotify, ni Spicetify, ni SpotX**. Aucun accès au compte Spotify.

## Essai sur Main
1. Télécharger le dépôt via **Code → Download ZIP**, puis extraire le dossier `now-playing-toast/prototype`.
2. Ouvrir PowerShell **sans droits administrateur**, dans le dossier contenant le fichier.
3. Exécuter :

   ```powershell
   powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File ".\NowPlayingToast-Demo.ps1"
   ```

4. Observer le bandeau en bas à droite. Après sa disparition, appuyer sur **Ctrl + Alt + .** pour le revoir.
5. Garder PowerShell ouvert pour le test. **Ctrl + C** dans la console pour arrêter le prototype.

Attention : le raccourci peut être déjà utilisé par une autre application ou fonctionner différemment sur certains claviers. Si l'enregistrement est refusé, un avertissement est affiché.

## Ce qui reste à faire
- Remplacer la pochette de substitution par la **vraie pochette**.
- Récupérer titre, artiste, album, année, durée et progression via Spicetify.
- Afficher automatiquement la notification à chaque changement de morceau.
- Ajouter transition, couleur d'accent calculée depuis la pochette, gestion multi-écran et configuration du raccourci.
- Tester réellement sur le PC Main.

La V0.2 est un prototype autonome, **pas une application Spotify connectée ni une installation permanente**.
