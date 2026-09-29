import { toEmbedUrl } from "./urls";

const DROPPED = "script, style, form, object, embed";

/**
 * For blocks without the `html` option: pasted markup that would end up in
 * an HTML block is dropped or flattened to text instead. Iframes stay when
 * they are a supported video.
 */
export function stripPastedHtml(html: string): string {
  const template = document.createElement("template");
  template.innerHTML = html;
  const root = template.content;

  root.querySelectorAll(DROPPED).forEach((el) => el.remove());
  root.querySelectorAll("iframe").forEach((el) => {
    if (!toEmbedUrl(el.getAttribute("src") || "")) el.remove();
  });
  root.querySelectorAll("table").forEach((table) => {
    const rows = Array.from(table.querySelectorAll("tr"))
      .map((tr) =>
        Array.from(tr.children)
          .map((cell) => (cell.textContent || "").replace(/\s+/g, " ").trim())
          .filter(Boolean)
          .join(" ")
      )
      .filter(Boolean);
    table.replaceWith(
      ...rows.map((text) => {
        const p = document.createElement("p");
        p.textContent = text;
        return p;
      })
    );
  });

  return template.innerHTML;
}
