import { Node } from "@tiptap/core";
import type { CommandProps } from "@tiptap/core";
import { ReactNodeViewRenderer } from "@tiptap/react";

import RawHtmlView from "../views/RawHtmlView";
import { toEmbedUrl } from "./PagesVideo";

/*
 * Escape hatch for markup the schema has no node for: consent scripts,
 * newsletter forms, tables, embeds from hosts outside the video allowlist.
 * The markup is stored verbatim and shown as code in the editor, so
 * nothing is lost on load and nothing runs in admin.
 */
const RAW_TAGS = ["script", "style", "form", "table", "object", "embed"];

/** One-line description for the block label: "script · consent.cookiebot.com". */
export function describeHtml(html: string): string {
  const tpl = document.createElement("template");
  tpl.innerHTML = html.trim();
  const el = tpl.content.firstElementChild;
  if (!el) return html.trim() ? "text" : "empty";
  const tag = el.tagName.toLowerCase();
  const src =
    el.getAttribute("src") || el.querySelector("[src]")?.getAttribute("src");
  if (!src) return tag;
  try {
    return `${tag} · ${new URL(src, window.location.origin).hostname}`;
  } catch {
    return tag;
  }
}

export const RawHtml = Node.create({
  name: "rawHtml",
  group: "block",
  atom: true,
  draggable: true,
  selectable: true,

  addAttributes() {
    return {
      html: {
        default: "",
        parseHTML: (element: HTMLElement) => element.outerHTML,
        renderHTML: () => ({})
      }
    };
  },

  parseHTML() {
    const notVideo = (el: HTMLElement): false | Record<string, never> => {
      const src =
        el.tagName === "IFRAME"
          ? el.getAttribute("src")
          : el.querySelector("iframe")?.getAttribute("src");
      return toEmbedUrl(src || "") ? false : {};
    };
    return [
      ...RAW_TAGS.map((tag) => ({ tag })),
      { tag: "iframe", getAttrs: notVideo },
      { tag: "div.video-embed", getAttrs: notVideo }
    ];
  },

  // Carried out of getHTML() as an attribute; serializer.toStored unwraps
  // it so the stored value is the markup itself, no wrapper, and the site
  // renders it exactly as before conversion.
  renderHTML({ node }) {
    return ["div", { "data-raw-html": (node.attrs.html as string) || "" }];
  },

  addNodeView() {
    return ReactNodeViewRenderer(RawHtmlView);
  },

  addCommands() {
    return {
      insertRawHtml:
        (attrs: { html: string } = { html: "" }) =>
        ({ commands }: CommandProps) =>
          commands.insertContent({ type: this.name, attrs })
    };
  }
});

declare module "@tiptap/core" {
  interface Commands<ReturnType> {
    rawHtml: {
      insertRawHtml: (attrs?: { html: string }) => ReturnType;
    };
  }
}
