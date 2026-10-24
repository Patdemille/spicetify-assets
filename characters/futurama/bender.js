// Futurama / Bender — extension Spicetify indépendante (extrait du pack historique).
// Activer seule ou avec Adventure Time / BMO et Cat-Jam Mirror.
(() => {
  "use strict";
  const STYLE_ID = "spicetify-character-futurama-bender";
  if (document.getElementById(STYLE_ID)) return;

  const css = `
.playback-bar [data-testid="playback-progressbar"] {
  position: relative !important;
  overflow: visible !important;
}
.playback-bar [data-testid="playback-progressbar"]::after {
  content: "" !important;
  position: absolute !important;
  width: 60px !important;
  height: 60px !important;
  bottom: 12px !important;
  left: -8px !important;
  right: auto !important;
  background-image: url("https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/Bender_danse_nettoye_anime.gif") !important;
  background-size: contain !important;
  background-position: center bottom !important;
  background-repeat: no-repeat !important;
  z-index: 999 !important;
  pointer-events: none !important;
  transform: none !important;
}
`;
  const style = document.createElement("style");
  style.id = STYLE_ID;
  style.textContent = css;
  document.head.appendChild(style);
})();
