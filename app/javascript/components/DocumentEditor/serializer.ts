/*
 * Spike: the editor stores HTML in the existing text column, wrapped in
 * <notextile> so RedCloth passes it through untouched. Image and file
 * embeds are stored as the existing [image:ID …] / [attachment:ID] codes,
 * which HtmlFormatter expands before RedCloth runs. On load the codes are
 * turned into placeholder elements Tiptap's parseHTML understands.
 */

const WRAPPER_OPEN = "<notextile>";
const WRAPPER_CLOSE = "</notextile>";

const IMAGE_CODE = /\[image:(\d+)([^\]]*)\]/g;
// [file:ID] is a PageFile id, not an Attachment id. DocumentConverter maps
// legacy file codes on conversion; any left over stay as plain text.
const ATTACHMENT_CODE = /\[attachment:(\d+(?:,\d+)*)\]/g;

function attr(options: string, name: string): string {
  const m = options.match(new RegExp(`${name}="([^"]*)"`));
  return m ? m[1] : "";
}

function escapeAttr(str: string): string {
  return str.replace(/&/g, "&amp;").replace(/"/g, "&quot;");
}

function unescapeAttr(str: string): string {
  return str
    .replace(/&quot;/g, '"')
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&amp;/g, "&");
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

/** Stored value → HTML the editor can parse. */
export function toEditorHtml(stored: string | null | undefined): string {
  if (!stored) return "";
  let html = stored.trim();
  if (isDocument(html)) {
    html = html.slice(WRAPPER_OPEN.length);
    if (html.endsWith(WRAPPER_CLOSE)) {
      html = html.slice(0, -WRAPPER_CLOSE.length);
    }
  }
  return html
    .replace(IMAGE_CODE, (_m, id: string, options: string) => {
      const className = attr(options, "class");
      const link = attr(options, "link");
      const size = attr(options, "size");
      return (
        `<figure data-image="${id}"` +
        (className ? ` data-class="${escapeAttr(className)}"` : "") +
        (link ? ` data-link="${escapeAttr(link)}"` : "") +
        (size ? ` data-size="${escapeAttr(size)}"` : "") +
        "></figure>"
      );
    })
    .replace(ATTACHMENT_CODE, (_m, ids: string) => {
      return ids
        .split(",")
        .map((id) => `<a class="file" data-file="${id}"></a>`)
        .join(", "); // AttachmentEmbedder joins multi-id codes with ", "
    });
}

const RAW_BLOCK = /<div data-raw-html="([^"]*)"><\/div>/g;
// Private-use characters: cannot come from the editor, so no clean-up
// below can match inside a set-aside raw block.
const RAW_PLACEHOLDER = /\uE000(\d+)\uE000/g;

/** Editor HTML → stored value. */
export function toStored(editorHtml: string): string {
  // RawHtml block: stored as the markup itself, untouched by the clean-ups.
  const rawBlocks: string[] = [];
  const body = editorHtml
    .replace(RAW_BLOCK, (_m, html: string) => {
      rawBlocks.push(unescapeAttr(html).trim());
      return `\uE000${rawBlocks.length - 1}\uE000`;
    })
    .replace(
      /<figure[^>]*data-image="(\d+)"[^>]*>(?:<\/figure>)?/g,
      (m, id: string) => {
        const className = unescapeAttr(attr(m, "data-class"));
        const link = unescapeAttr(attr(m, "data-link"));
        const size = unescapeAttr(attr(m, "data-size"));
        const parts = [`[image:${id}`];
        if (className) parts.push(` class="${className}"`);
        if (link) parts.push(` link="${link}"`);
        if (size) parts.push(` size="${size}"`);
        return parts.join("") + "]";
      }
    )
    .replace(
      /<a[^>]*data-file="(\d+)"[^>]*>.*?<\/a>/g,
      (_m, id: string) => `[attachment:${id}]`
    )
    // Tiptap wraps list item text in <p>; Textile output is bare <li>.
    // Unwrap single-paragraph items so site CSS renders lists the same.
    .replace(
      /<li>\s*<p>((?:(?!<\/?p>)[\s\S])*)<\/p>\s*(?=<\/li>|<ul>|<ol>)/g,
      "<li>$1"
    )
    // Textile collapsed blank lines, so empty paragraphs never rendered.
    .replace(/<p><\/p>\s*/g, "")
    .replace(RAW_PLACEHOLDER, (_m, i: string) => rawBlocks[Number(i)])
    .trim();

  if (!body || body === "<p></p>") return "";
  return `${WRAPPER_OPEN}\n${body}\n${WRAPPER_CLOSE}`;
}
