// Adventure Time / BMO — extension Spicetify indépendante (extrait du pack historique).
// Activer seule ou avec Futurama / Bender et Cat-Jam Mirror.
(() => {
  "use strict";
  const STYLE_ID = "spicetify-character-adventure-time-bmo";
  if (document.getElementById(STYLE_ID)) return;

  const css = `
.playback-bar [data-testid="playback-progressbar"] {
  position: relative !important;
  overflow: visible !important;
}
.playback-bar [data-testid="playback-progressbar"]::before {
  content: "" !important;
  position: absolute !important;
  width: 50px !important;
  height: 50px !important;
  bottom: 12px !important;
  right: -8px !important;
  left: auto !important;
  background-image: url("https://64.media.tumblr.com/38ff0368992c9f601ee746469f9a19c1/tumblr_mqf4asbozS1qmkil9o1_500.gif") !important;
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
