/* Cat-Jam Mirror : module facultatif et séparé des personnages Bender/BMO.
 * Dépend de Cat Jam Synced (BlafKing) pour trouver #catjam-webm.
 * Réglages issus du dernier état Main confirmé, encore à revalider sur Laptop.
 */
(() => {
  "use strict";
  if (window.__catjamMirrorInstalled) return;
  window.__catjamMirrorInstalled = true;
  const CONFIG = { left: "-55px", bottom: "4px", size: "65px", rightOffset: "-158px", syncInterval: 150, maxDrift: 0.12 };
  let mirror = null, original = null, originalTransform = null;
  function removeMirror() {
    if (mirror) { mirror.pause(); mirror.remove(); }
    mirror = null;
    if (original && originalTransform !== null) original.style.transform = originalTransform;
    original = null; originalTransform = null;
  }
  function initialize() {
    const cat = document.getElementById("catjam-webm");
    const bar = document.querySelector(".playback-bar");
    if (!cat || !bar) { if (mirror) removeMirror(); return; }
    if (mirror && mirror.isConnected && original === cat) return;
    removeMirror();
    original = cat;
    originalTransform = cat.style.transform;
    cat.style.transform = `translateX(${CONFIG.rightOffset})`;
    mirror = document.createElement("video");
    mirror.id = "catjam-mirror";
    mirror.src = cat.currentSrc || cat.src;
    mirror.muted = true; mirror.loop = true;
    mirror.playsInline = true; mirror.preload = "auto";
    Object.assign(mirror.style, {
      position: "absolute", width: CONFIG.size, height: CONFIG.size,
      left: CONFIG.left, bottom: CONFIG.bottom, transform: "scaleX(-1)",
      objectFit: "contain", pointerEvents: "none", zIndex: "20"
    });
    bar.style.position = "relative";
    bar.style.overflow = "visible";
    bar.appendChild(mirror);
  }
  function synchronize() {
    initialize();
    if (!mirror || !original) return;
    const source = original.currentSrc || original.src;
    if (source && mirror.src !== source) { mirror.src = source; mirror.load(); }
    if (original.playbackRate > 0) mirror.playbackRate = original.playbackRate;
    if (original.readyState >= 2 && mirror.readyState >= 1 &&
        Math.abs(mirror.currentTime - original.currentTime) > CONFIG.maxDrift) {
      try { mirror.currentTime = original.currentTime; } catch (_) {}
    }
    if (original.paused) {
      if (!mirror.paused) mirror.pause();
    } else if (mirror.paused) {
      mirror.play().catch(() => {});
    }
  }
  const timer = setInterval(synchronize, CONFIG.syncInterval);
  window.__catjamMirrorStop = () => {
    clearInterval(timer); removeMirror(); window.__catjamMirrorInstalled = false;
  };
})();
