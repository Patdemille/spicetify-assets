(() => {
  "use strict";
  if (document.getElementById("spicetify-characters-laptop")) return;
  const css = `
.playback-bar [data-testid="playback-progressbar"] { position: relative !important; overflow: visible !important; }
.playback-bar [data-testid="playback-progressbar"]::before,
.playback-bar [data-testid="playback-progressbar"]::after {
  content: "" !important; position: absolute !important; bottom: 12px !important;
  background-size: contain !important; background-position: center bottom !important;
  background-repeat: no-repeat !important; z-index: 999 !important;
  pointer-events: none !important; transform: none !important;
}
.playback-bar [data-testid="playback-progressbar"]::after {
  width: 60px !important; height: 60px !important; left: -8px !important; right: auto !important;
  background-image: url("https://raw.githubusercontent.com/Patdemille/spicetify-assets/main/Bender_danse_nettoye_anime.gif") !important;
}
.playback-bar [data-testid="playback-progressbar"]::before {
  width: 50px !important; height: 50px !important; right: -8px !important; left: auto !important;
  background-image: url("https://64.media.tumblr.com/38ff0368992c9f601ee746469f9a19c1/tumblr_mqf4asbozS1qmkil9o1_500.gif") !important;
}`;
  const style = document.createElement("style");
  style.id = "spicetify-characters-laptop";
  style.textContent = css;
  document.head.appendChild(style);
})();
