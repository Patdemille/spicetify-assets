// Spicetify right sidebar free resize v0.2 - smoother experimental preview.
// CSS only changes the right-panel container; no Spotify/SpotX modifications.
(() => {
  "use strict";
  if (window.__sidebarFreeResizeV1 || window.__sidebarFreeResizeV2) return;
  window.__sidebarFreeResizeV2 = true;

  const PANEL_ID = "Desktop_PanelContainer_Id";
  const STORE = "spicetify-sidebar-free-resize-width-v1"; // shared with v0.1
  const MIN = 280;
  const MAX = 800;
  const maxAvailable = () => Math.max(MIN, Math.min(MAX, window.innerWidth - 500));
  const clamp = (value) => Math.max(MIN, Math.min(maxAvailable(), Math.round(value)));
  const saved = Number(localStorage.getItem(STORE));
  let width = Number.isFinite(saved) && saved >= MIN ? saved : 560;
  let pendingWidth = width;
  let dragging = false;
  let downX = 0;
  let downWidth = 0;
  let downLeft = 0;
  let previousUserSelect = "";
  let frameId = 0;

  const style = document.createElement("style");
  style.id = "sidebar-free-resize-style-v2";
  style.textContent = [
    'html[data-free-sidebar-resize="on"] #' + PANEL_ID + ',',
    'html[data-free-sidebar-resize="on"] div:has(> #' + PANEL_ID + ') {',
    '  width: var(--free-sidebar-width) !important;',
    '  min-width: var(--free-sidebar-width) !important;',
    '  max-width: none !important;',
    '}',
    '#sidebar-free-resize-handle-v2 {',
    '  position: fixed; width: 12px; z-index: 9999;',
    '  cursor: col-resize; touch-action: none; background: transparent;',
    '}',
    '#sidebar-free-resize-handle-v2::after {',
    '  content: ""; position: absolute; top: 12%; bottom: 12%;',
    '  left: 5px; width: 2px; background: transparent; border-radius: 2px;',
    '}',
    '#sidebar-free-resize-handle-v2:hover::after,',
    '#sidebar-free-resize-handle-v2.dragging::after { background: #1ed760; }'
  ].join("\n");
  document.head.appendChild(style);

  const handle = document.createElement("div");
  handle.id = "sidebar-free-resize-handle-v2";
  handle.title = "Elargir le panneau droit (280-800 px)";
  handle.setAttribute("aria-label", "Redimensionner le panneau droit");
  document.body.appendChild(handle);

  function applyWidth(value) {
    width = clamp(value);
    document.documentElement.style.setProperty("--free-sidebar-width", width + "px");
    document.documentElement.setAttribute("data-free-sidebar-resize", "on");
  }
  function updateHandle() {
    if (dragging) return; // Never force layout reads during a drag.
    const panel = document.getElementById(PANEL_ID);
    if (!panel) {
      handle.style.display = "none";
      return;
    }
    const rect = panel.getBoundingClientRect();
    if (rect.width < 20 || rect.height < 20 || rect.right < 0 ||
        rect.left > window.innerWidth) {
      handle.style.display = "none";
      return;
    }
    handle.style.display = "block";
    handle.style.left = Math.round(rect.left - 6) + "px";
    handle.style.top = Math.round(rect.top) + "px";
    handle.style.height = Math.round(rect.height) + "px";
  }

  // Process at most one layout-changing update per animation frame.
  // Position the handle by pointer delta: avoids reading getBoundingClientRect()
  // immediately after setting CSS width (forced synchronous layout in v0.1).
  function renderFrame() {
    frameId = 0;
    applyWidth(pendingWidth);
    if (dragging) {
      handle.style.left = Math.round(downLeft - (width - downWidth) - 6) + "px";
    }
  }
  function requestFrame() {
    if (!frameId) frameId = window.requestAnimationFrame(renderFrame);
  }

  handle.addEventListener("pointerdown", (event) => {
    if (event.button !== 0) return;
    const panel = document.getElementById(PANEL_ID);
    if (!panel) return;
    event.preventDefault();
    event.stopPropagation();
    const rect = panel.getBoundingClientRect();
    dragging = true;
    downX = event.clientX;
    downWidth = rect.width;
    downLeft = rect.left;
    pendingWidth = width;
    previousUserSelect = document.body.style.userSelect;
    document.body.style.userSelect = "none";
    handle.classList.add("dragging");
    handle.setPointerCapture(event.pointerId);
  });

  handle.addEventListener("pointermove", (event) => {
    if (!dragging) return;
    pendingWidth = clamp(downWidth + downX - event.clientX);
    requestFrame();
    event.preventDefault();
  });

  function finishDrag() {
    if (!dragging) return;
    if (frameId) {
      window.cancelAnimationFrame(frameId);
      frameId = 0;
    }
    applyWidth(pendingWidth);
    dragging = false;
    handle.classList.remove("dragging");
    document.body.style.userSelect = previousUserSelect;
    localStorage.setItem(STORE, String(width));
    updateHandle(); // One final layout read when dragging ends.
  }
  handle.addEventListener("pointerup", finishDrag);
  handle.addEventListener("pointercancel", finishDrag);
  handle.addEventListener("lostpointercapture", finishDrag);

  function onResize() {
    pendingWidth = width;
    applyWidth(pendingWidth);
    updateHandle();
  }
  window.addEventListener("resize", onResize);

  applyWidth(width);
  updateHandle();
  // Spotify remounts panels as the user switches between views.
  const interval = setInterval(updateHandle, 800);

  window.__sidebarFreeResizeStop = () => {
    clearInterval(interval);
    window.removeEventListener("resize", onResize);
    if (frameId) window.cancelAnimationFrame(frameId);
    finishDrag();
    style.remove();
    handle.remove();
    document.documentElement.removeAttribute("data-free-sidebar-resize");
    document.documentElement.style.removeProperty("--free-sidebar-width");
    delete window.__sidebarFreeResizeStop;
    delete window.__sidebarFreeResizeV2;
  };
  console.info("[Sidebar Free Resize] v0.2 RAF prototype active.");
})();
