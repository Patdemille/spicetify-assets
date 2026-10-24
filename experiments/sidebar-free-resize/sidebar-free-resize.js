// Spicetify: experimental right sidebar drag resizer, v0.1.
// Separate from SpotX, Marketplace, existing themes and extensions.
(() => {
  "use strict";
  if (window.__sidebarFreeResizeV1) return;
  window.__sidebarFreeResizeV1 = true;

  const PANEL_ID = "Desktop_PanelContainer_Id";
  const STORE = "spicetify-sidebar-free-resize-width-v1";
  const MIN = 280;
  const MAX = 800;
  const maxAvailable = () => Math.max(MIN, Math.min(MAX, window.innerWidth - 500));
  const clamp = (value) => Math.max(MIN, Math.min(maxAvailable(), Math.round(value)));
  const saved = Number(localStorage.getItem(STORE));
  let width = Number.isFinite(saved) && saved >= MIN ? saved : 560;
  let dragging = false;
  let downX = 0;
  let downWidth = 0;
  let previousUserSelect = "";

  const style = document.createElement("style");
  style.id = "sidebar-free-resize-style";
  style.textContent = [
    'html[data-free-sidebar-resize="on"] #' + PANEL_ID + ',',
    'html[data-free-sidebar-resize="on"] div:has(> #' + PANEL_ID + ') {',
    '  width: var(--free-sidebar-width) !important;',
    '  min-width: var(--free-sidebar-width) !important;',
    '  max-width: none !important;',
    '}',
    '#sidebar-free-resize-handle {',
    '  position: fixed; width: 12px; z-index: 9999;',
    '  cursor: col-resize; touch-action: none; background: transparent;',
    '}',
    '#sidebar-free-resize-handle::after {',
    '  content: ""; position: absolute; top: 12%; bottom: 12%;',
    '  left: 5px; width: 2px; background: transparent; border-radius: 2px;',
    '}',
    '#sidebar-free-resize-handle:hover::after,',
    '#sidebar-free-resize-handle.dragging::after { background: #1ed760; }'
  ].join("\n");
  document.head.appendChild(style);

  const handle = document.createElement("div");
  handle.id = "sidebar-free-resize-handle";
  handle.title = "Redimensionner le panneau droit (280-800 px)";
  handle.setAttribute("aria-label", "Redimensionner le panneau droit");
  document.body.appendChild(handle);

  function applyWidth() {
    width = clamp(width);
    document.documentElement.style.setProperty("--free-sidebar-width", width + "px");
    document.documentElement.setAttribute("data-free-sidebar-resize", "on");
  }
  function updateHandle() {
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

  handle.addEventListener("pointerdown", (event) => {
    if (event.button !== 0) return;
    const panel = document.getElementById(PANEL_ID);
    if (!panel) return;
    event.preventDefault();
    event.stopPropagation();
    downX = event.clientX;
    downWidth = panel.getBoundingClientRect().width;
    dragging = true;
    previousUserSelect = document.body.style.userSelect;
    document.body.style.userSelect = "none";
    handle.classList.add("dragging");
    handle.setPointerCapture(event.pointerId);
  });
  handle.addEventListener("pointermove", (event) => {
    if (!dragging) return;
    width = clamp(downWidth + downX - event.clientX);
    applyWidth();
    updateHandle();
    event.preventDefault();
  });
  function finishDrag() {
    if (!dragging) return;
    dragging = false;
    handle.classList.remove("dragging");
    document.body.style.userSelect = previousUserSelect;
    localStorage.setItem(STORE, String(width));
    updateHandle();
  }
  handle.addEventListener("pointerup", finishDrag);
  handle.addEventListener("pointercancel", finishDrag);
  handle.addEventListener("lostpointercapture", finishDrag);

  function onResize() {
    applyWidth();
    updateHandle();
  }
  window.addEventListener("resize", onResize);
  applyWidth();
  updateHandle();
  // Spotify recreates panels when switching to Queue/Friends/Now Playing.
  const interval = setInterval(updateHandle, 800);
  window.__sidebarFreeResizeStop = () => {
    clearInterval(interval);
    window.removeEventListener("resize", onResize);
    finishDrag();
    style.remove();
    handle.remove();
    document.documentElement.removeAttribute("data-free-sidebar-resize");
    document.documentElement.style.removeProperty("--free-sidebar-width");
    delete window.__sidebarFreeResizeV1;
  };
  console.info("[Sidebar Free Resize] Test extension active.");
})();
