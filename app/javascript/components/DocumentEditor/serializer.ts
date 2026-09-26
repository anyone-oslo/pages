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
const ATTACHMENT_CODE = /\[(?:attachment|file):(\d+(?:,\d+)*)\]/g;

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

export function isDocument(stored: string | null | undefined): boolean {
  return !!stored && stored.trimStart().startsWith(WRAPPER_OPEN);
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

/** Editor HTML → stored value. */
export function toStored(editorHtml: string): string {
  const body = editorHtml
    .replace(
      /<figure[^>]*data-image="(\d+)"[^>]*>(?:<\/figure>)?/g,
      (m, id: string) => {
        const className = attr(m, "data-class");
        const link = attr(m, "data-link");
        const size = attr(m, "data-size");
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
    // RawHtml block: stored as the markup itself.
    .replace(/<div data-raw-html="([^"]*)"><\/div>/g, (_m, html: string) =>
      unescapeAttr(html).trim()
    )
    // Tiptap wraps list item text in <p>; Textile output is bare <li>.
    // Unwrap single-paragraph items so site CSS renders lists the same.
    .replace(
      /<li>\s*<p>((?:(?!<\/?p>)[\s\S])*)<\/p>\s*(?=<\/li>|<ul>|<ol>)/g,
      "<li>$1"
    )
    // Textile collapsed blank lines, so empty paragraphs never rendered.
    .replace(/<p><\/p>\s*/g, "")
    .trim();

  if (!body || body === "<p></p>") return "";
  return `${WRAPPER_OPEN}\n${body}\n${WRAPPER_CLOSE}`;
}
