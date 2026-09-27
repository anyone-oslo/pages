const VIDEO_ID = /^[\w-]+$/;

/**
 * Turns a pasted YouTube/Vimeo URL (watch, short, or embed form) into an
 * https embed URL. Returns null for any other host or protocol — that is
 * the allowlist. Embed URLs keep their query (Vimeo ?h= for unlisted
 * videos, YouTube ?start=).
 */
export function toEmbedUrl(input: string): string | null {
  let url: URL;
  try {
    url = new URL(input.trim());
  } catch {
    return null;
  }
  if (url.protocol !== "https:" && url.protocol !== "http:") return null;
  url.protocol = "https:";
  const host = url.hostname.replace(/^www\./, "");

  if (host === "youtube.com" || host === "youtube-nocookie.com") {
    if (url.pathname.startsWith("/embed/")) {
      return /^\/embed\/[\w-]+$/.test(url.pathname) ? url.toString() : null;
    }
    const v = url.searchParams.get("v");
    return v && VIDEO_ID.test(v)
      ? `https://www.youtube-nocookie.com/embed/${v}`
      : null;
  }
  if (host === "youtu.be") {
    const id = url.pathname.slice(1);
    return VIDEO_ID.test(id)
      ? `https://www.youtube-nocookie.com/embed/${id}`
      : null;
  }
  if (host === "player.vimeo.com") {
    return /^\/video\/\d+$/.test(url.pathname) ? url.toString() : null;
  }
  if (host === "vimeo.com") {
    const m = url.pathname.match(/^\/(\d+)/);
    return m ? `https://player.vimeo.com/video/${m[1]}` : null;
  }
  return null;
}

/** Watch/share page for a stored embed URL. Opens in a new tab from admin. */
export function toWatchUrl(src: string): string {
  try {
    const url = new URL(src);
    const host = url.hostname.replace(/^www\./, "");
    if (host === "youtube.com" || host === "youtube-nocookie.com") {
      const id = url.pathname.match(/^\/embed\/([^/?]+)/)?.[1];
      if (id) return `https://www.youtube.com/watch?v=${id}`;
    }
    if (host === "player.vimeo.com") {
      const id = url.pathname.match(/^\/video\/(\d+)/)?.[1];
      if (id) return `https://vimeo.com/${id}`;
    }
  } catch {
    return src;
  }
  return src;
}
