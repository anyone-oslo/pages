/*
 * Spike: the editor stores HTML in the existing text column, wrapped in
 * <notextile> so RedCloth passes it through untouched. Image and file
 * embeds are stored as the existing [image:ID …] / [attachment:ID] codes,
 * which HtmlFormatter expands before RedCloth runs. On load the codes are
 * turned into placeholder elements Tiptap's parseHTML understands.
 *
 * Both directions parse with <template>, so nothing here runs in Node;
 * the string-only parts are in codes.ts.
 */
import {
  CODE_MARK,
  RAW_MARK,
  WRAPPER_CLOSE,
  WRAPPER_OPEN,
  attachmentCode,
  codeToPlaceholder,
  escapeAttr,
  escapeText,
  extractCodes,
  imageCode,
  isDocument
} from "./codes";

export { isDocument };

// Markup RawHtml.ts keeps verbatim; codes inside it are not embeds.
const RAW_SELECTOR =
  "script, style, form, table, object, embed, iframe, div.video-embed";

function parse(html: string): HTMLTemplateElement {
  const tpl = document.createElement("template");
  tpl.innerHTML = html;
  return tpl;
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

  // Codes are set aside before parsing so the HTML parser cannot decode
  // an ampersand inside them (`&reg` in a link, say).
  const { html: marked, codes } = extractCodes(html);
  const tpl = parse(marked);

  const walker = document.createTreeWalker(tpl.content, NodeFilter.SHOW_TEXT);
  const texts: Text[] = [];
  while (walker.nextNode()) texts.push(walker.currentNode as Text);

  texts.forEach((node) => {
    if (!node.data.includes("\uE001")) return;
    const inRaw = !!node.parentElement?.closest(RAW_SELECTOR);
    const holder = parse(
      escapeText(node.data).replace(CODE_MARK, (_m, i: string) =>
        inRaw
          ? escapeText(codes[Number(i)])
          : codeToPlaceholder(codes[Number(i)])
      )
    );
    node.replaceWith(holder.content);
  });

  // Codes inside attributes stay as written.
  return tpl.innerHTML.replace(CODE_MARK, (_m, i: string) =>
    escapeAttr(codes[Number(i)])
  );
}

/** Editor HTML → stored value. */
export function toStored(editorHtml: string): string {
  const tpl = parse(editorHtml);
  const root = tpl.content;

  // Raw blocks and codes are put back after serializing, so nothing
  // below can rewrite them and `&` stays as the embedder expects it.
  const raw: string[] = [];
  const stash = (el: Element, text: string) => {
    raw.push(text);
    el.replaceWith(`\uE000${raw.length - 1}\uE000`);
  };

  root.querySelectorAll("div[data-raw-html]").forEach((el) => {
    stash(el, (el.getAttribute("data-raw-html") || "").trim());
  });

  root.querySelectorAll("figure[data-image]").forEach((el) => {
    const id = el.getAttribute("data-image") || "";
    if (!/^\d+$/.test(id)) return;
    stash(
      el,
      imageCode(id, {
        className: el.getAttribute("data-class") || "",
        link: el.getAttribute("data-link") || "",
        size: el.getAttribute("data-size") || ""
      })
    );
  });

  root.querySelectorAll("a[data-file]").forEach((el) => {
    const id = el.getAttribute("data-file") || "";
    if (/^\d+$/.test(id)) stash(el, attachmentCode(id));
  });

  // Tiptap wraps list item text in <p>; Textile output is bare <li>.
  // Unwrap single-paragraph items so site CSS renders lists the same.
  root.querySelectorAll("li").forEach((li) => {
    const [first, ...rest] = Array.from(li.children);
    const onlyNested = rest.every((el) => ["UL", "OL"].includes(el.tagName));
    if (first?.tagName === "P" && onlyNested) {
      first.replaceWith(...Array.from(first.childNodes));
    }
  });

  // Textile collapsed blank lines, so empty paragraphs never rendered.
  root.querySelectorAll("p").forEach((p) => {
    if (p.innerHTML === "") p.remove();
  });

  const body = tpl.innerHTML
    .replace(RAW_MARK, (_m, i: string) => raw[Number(i)])
    .trim();

  if (!body || body === "<p></p>") return "";
  return `${WRAPPER_OPEN}\n${body}\n${WRAPPER_CLOSE}`;
}
