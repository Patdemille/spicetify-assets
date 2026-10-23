// Now Playing Toast v0.4 - Spicetify extension, sends metadata ONLY to 127.0.0.1
// Requires the separate NowPlayingToast.ps1 companion to be running.
(() => {
  "use strict";
  if (window.__nowPlayingToastBridge) return;
  window.__nowPlayingToastBridge = true;

  const ENDPOINT = "http://127.0.0.1:43827/track";
  let lastUri = "";
  let lastSuccessful = false;
  let lastFailureLog = 0;
  const albumCache = new Map();

  const text = (value) => typeof value === "string" ? value.trim() : "";
  const numberOrZero = (value) => Number.isFinite(Number(value)) ? Math.max(0, Number(value)) : 0;

  function httpsCover(url) {
    const s = text(url);
    if (s.startsWith("https://")) return s;
    if (/^spotify:image:[0-9A-Za-z]+$/.test(s)) {
      return "https://i.scdn.co/image/" + s.split(":").pop();
    }
    return "";
  }

  function playerSnapshot() {
    const player = Spicetify?.Player;
    const data = player?.data;
    const item = data?.item;
    if (!item?.uri) return null;
    const m = item.metadata || {};
    const artists = [text(m.artist_name), text(m["artist_name:1"]), text(m["artist_name:2"])]
      .filter((name, index, all) => name && all.indexOf(name) === index);
    let artist = artists.join(", ") || text(item.artists?.map(a => a.name).join(", ")) || "Unknown artist";
    let release = text(m.release_date || m.album_release_date || m.album_date || m.year);
    let year = /^\d{4}/.test(release) ? release.slice(0, 4) : "";
    const albumUri = text(m.album_uri || item.album?.uri);
    if (!year && albumUri && albumCache.has(albumUri)) year = albumCache.get(albumUri);
    const duration = numberOrZero(player.getDuration?.() ?? data.duration ?? m.duration);
    const progress = numberOrZero(player.getProgress?.() ?? data.position ?? 0);
    return {
      uri: text(item.uri),
      title: text(item.name || m.title) || "Unknown track",
      artist, album: text(m.album_title || item.album?.name) || "Unknown album",
      year,
      durationMs: duration,
      progressMs: progress,
      playing: typeof player.isPlaying === "function" ? !!player.isPlaying() : !data.isPaused,
      coverUrl: httpsCover(
        m.image_xlarge_url || m.image_large_url || m.image_url ||
        item.images?.[0]?.url || item.album?.images?.[0]?.url
      ),
      albumUri
    };
  }

  async function send(snapshot, action) {
    if (!snapshot) return;
    const payload = { ...snapshot, action };
    delete payload.albumUri;
    try {
      const response = await fetch(ENDPOINT, {
        method: "POST",
        mode: "cors",
        credentials: "omit",
        cache: "no-store",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
      });
      if (!response.ok) throw new Error("HTTP " + response.status);
      if (!lastSuccessful) console.info("[Now Playing Toast] Connected to local Windows companion.");
      lastSuccessful = true;
    } catch (e) {
      lastSuccessful = false;
      if (Date.now() - lastFailureLog > 30000) {
        console.warn("[Now Playing Toast] No local bridge available or blocked by CSP/CORS:", String(e));
        lastFailureLog = Date.now();
      }
    }
  }

  async function findAlbumYear(snapshot) {
    if (!snapshot?.albumUri || snapshot.year || albumCache.has(snapshot.albumUri)) return;
    const id = snapshot.albumUri.split(":").pop();
    if (!/^[A-Za-z0-9]{22}$/.test(id)) return;
    try {
      const album = await Spicetify.CosmosAsync.get("https://api.spotify.com/v1/albums/" + id);
      const date = text(album?.release_date || album?.album?.release_date);
      const year = /^\d{4}/.test(date) ? date.slice(0, 4) : "";
      albumCache.set(snapshot.albumUri, year);
      if (year && snapshot.uri === lastUri) {
        const latest = playerSnapshot();
        if (latest && latest.uri === snapshot.uri) {
          latest.year = year;
          await send(latest, "update"); // Do not create a second popup.
        }
      }
    } catch (e) {
      albumCache.set(snapshot.albumUri, "");
      console.debug("[Now Playing Toast] Album year unavailable:", String(e));
    }
  }

  async function update(action = "update") {
    const snapshot = playerSnapshot();
    if (!snapshot) return;
    if (lastUri !== snapshot.uri) {
      lastUri = snapshot.uri;
      action = "show";
      findAlbumYear(snapshot); // Background enrichment; may not be available.
    }
    await send(snapshot, action);
  }

  function start() {
    if (typeof Spicetify === "undefined" || !Spicetify.Player?.addEventListener) {
      setTimeout(start, 500);
      return;
    }
    Spicetify.Player.addEventListener("songchange", () => update("show"));
    update("update");
    // Periodic lightweight progress snapshot for the on-demand hotkey.
    setInterval(() => update("update"), 4000);
    console.info("[Now Playing Toast] Spicetify bridge ready.");
  }
  start();
})();