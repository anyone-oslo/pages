/*
 * String-only helpers for the stored form (see serializer.ts). Nothing here
 * touches the DOM, so the Node tests can import this file.
 */

export const WRAPPER_OPEN = "<notextile>";
export const WRAPPER_CLOSE = "</notextile>";

// [file:ID] is a PageFile id, not an Attachment id. DocumentConverter maps
// legacy file codes on conversion; any left over stay as plain text.
const CODE = /\[image:\d+[^\]]*\]|\[attachment:\d+(?:,\d+)*\]/g;

// Private-use characters: cannot come from the editor or stored text.
export const CODE_MARK = /\uE001(\d+)\uE001/g;
export const RAW_MARK = /\uE000(\d+)\uE000/g;

export type ImageOptions = { className?: string; link?: string; size?: string };

function attr(options: string, name: string): string {
  const m = options.match(new RegExp(`${name}="([^"]*)"`));
  return m ? m[1] : "";
}

export function escapeAttr(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/"/g, "&quot;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

export function escapeText(str: string): string {
  return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

// RedCloth passes the whole value through only when one notextile block
// wraps all of it; any Textile between two blocks is still rendered.
export function isDocument(stored: string | null | undefined): boolean {
  const html = (stored || "").trim();
  if (!html.startsWith(WRAPPER_OPEN) || !html.endsWith(WRAPPER_CLOSE)) {
    return false;
  }
  return !html
    .slice(WRAPPER_OPEN.length, -WRAPPER_CLOSE.length)
    .includes(WRAPPER_CLOSE);
}

/** Swap [image:] / [attachment:] codes for markers; returns the codes. */
export function extractCodes(html: string): { html: string; codes: string[] } {
  const codes: string[] = [];
  const marked = html.replace(CODE, (code) => {
    codes.push(code);
    return `\uE001${codes.length - 1}\uE001`;
  });
  return { html: marked, codes };
}

export function parseImageOptions(options: string): ImageOptions {
  return {
    className: attr(options, "class"),
    link: attr(options, "link"),
    size: attr(options, "size")
  };
}

/** One code → the placeholder markup Tiptap's parseHTML understands. */
export function codeToPlaceholder(code: string): string {
  const image = code.match(/^\[image:(\d+)([^\]]*)\]$/);
  if (image) {
    const { className, link, size } = parseImageOptions(image[2]);
    return (
      `<figure data-image="${image[1]}"` +
      (className ? ` data-class="${escapeAttr(className)}"` : "") +
      (link ? ` data-link="${escapeAttr(link)}"` : "") +
      (size ? ` data-size="${escapeAttr(size)}"` : "") +
      "></figure>"
    );
  }
  const files = code.match(/^\[attachment:(\d+(?:,\d+)*)\]$/);
  if (files) {
    return files[1]
      .split(",")
      .map((id) => `<a class="file" data-file="${id}"></a>`)
      .join(", "); // AttachmentEmbedder joins multi-id codes with ", "
  }
  return escapeText(code);
}

export function imageCode(id: string, options: ImageOptions): string {
  const parts = [`[image:${id}`];
  if (options.className) parts.push(` class="${options.className}"`);
  if (options.link) parts.push(` link="${options.link}"`);
  if (options.size) parts.push(` size="${options.size}"`);
  return parts.join("") + "]";
}

export function attachmentCode(id: string): string {
  return `[attachment:${id}]`;
}
