// Now Playing Toast v0.4.2 - Spicetify extension, sends metadata ONLY to 127.0.0.1
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

  // The player metadata often has an album URI but not the album release date.
  // Use Spotify's client GraphQL album query first and a Cosmos/Web API fallback.
  function yearOf(value) {
    if (value == null) return "";
    if (typeof value === "number" && value >= 1800 && value <= 2100) return String(value);
    const s = text(String(value));
    const match = s.match(/^(18|19|20)\d{2}(?=$|[-/T ])/);
    return match ? match[0] : "";
  }

  async function findAlbumYear(snapshot) {
    if (!snapshot?.albumUri || snapshot.year || albumCache.has(snapshot.albumUri)) return;
    const uri = snapshot.albumUri;
    const id = uri.split(":").pop();
    if (!/^[A-Za-z0-9]{22}$/.test(id)) {
      console.debug("[Now Playing Toast] Album URI not supported:", uri);
      return;
    }

    // Store the in-flight promise so periodic updates don't launch duplicates.
    const task = (async () => {
      let year = "";

      if (Spicetify.GraphQL?.Definitions?.getAlbum && Spicetify.GraphQL?.Request) {
        try {
          const result = await Spicetify.GraphQL.Request(
            Spicetify.GraphQL.Definitions.getAlbum,
            { uri, locale: "en", offset: 0, limit: 50 }
          );
          const a = result?.data?.albumUnion || result?.albumUnion || {};
          year = yearOf(a.date?.isoString) ||
                 yearOf(a.date?.year) ||
                 yearOf(a.releaseDate?.isoString) ||
                 yearOf(a.release_date) ||
                 yearOf(a.releaseYear);
        } catch (error) {
          console.debug("[Now Playing Toast] GraphQL album query failed:", String(error));
        }
      }

      if (!year && Spicetify.CosmosAsync?.get) {
        try {
          const a = await Spicetify.CosmosAsync.get(
            "https://api.spotify.com/v1/albums/" + id
          );
          year = yearOf(a?.release_date) ||
                 yearOf(a?.album?.release_date) ||
                 yearOf(a?.body?.release_date);
        } catch (error) {
          console.debug("[Now Playing Toast] Cosmos album query failed:", String(error));
        }
      }

      albumCache.set(uri, year);
      if (!year) {
        console.warn("[Now Playing Toast] Release year unavailable for album:", uri);
        return;
      }
      console.info("[Now Playing Toast] Album release year:", year);
      if (snapshot.uri === lastUri) {
        const current = playerSnapshot();
        if (current?.uri === snapshot.uri) {
          current.year = year;
          await send(current, "update"); // Enrich the open toast without reopening it.
        }
      }
    })();

    albumCache.set(uri, task);
    try { await task; }
    finally {
      // Replaced by the resolved year (or "") inside the task.
      if (albumCache.get(uri) === task) albumCache.delete(uri);
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