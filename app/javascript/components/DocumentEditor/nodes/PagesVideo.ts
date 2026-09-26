import { Node, mergeAttributes } from "@tiptap/core";
import type { CommandProps } from "@tiptap/core";
import { ReactNodeViewRenderer } from "@tiptap/react";

import PagesVideoView from "../views/PagesVideoView";

/**
 * Turns a pasted YouTube/Vimeo URL (watch, short, or embed form) into an
 * embed URL. Returns null for any other host — that is the allowlist.
 */
export function toEmbedUrl(input: string): string | null {
  let url: URL;
  try {
    url = new URL(input.trim());
  } catch {
    return null;
  }
  const host = url.hostname.replace(/^www\./, "");

  if (host === "youtube.com" || host === "youtube-nocookie.com") {
    if (url.pathname.startsWith("/embed/")) return url.toString();
    const v = url.searchParams.get("v");
    return v ? `https://www.youtube-nocookie.com/embed/${v}` : null;
  }
  if (host === "youtu.be") {
    const id = url.pathname.slice(1);
    return id ? `https://www.youtube-nocookie.com/embed/${id}` : null;
  }
  if (host === "player.vimeo.com") {
    return url.pathname.startsWith("/video/") ? url.toString() : null;
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

export const VIDEO_REPLACE_EVENT = "pagesVideoReplace";

export const PagesVideo = Node.create({
  name: "pagesVideo",
  group: "block",
  atom: true,
  draggable: true,
  selectable: true,

  addAttributes() {
    return {
      src: {
        default: null,
        parseHTML: (element: HTMLElement) => {
          const iframe =
            element.tagName === "IFRAME"
              ? element
              : element.querySelector("iframe");
          return iframe?.getAttribute("src") || null;
        },
        renderHTML: (attributes: { src?: string | null }) =>
          attributes.src ? { src: attributes.src } : {}
      }
    };
  },

  parseHTML() {
    return [
      {
        tag: "iframe[src]",
        getAttrs: (el: HTMLElement) =>
          toEmbedUrl(el.getAttribute("src") || "") ? null : false
      },
      {
        tag: "div.video-embed",
        getAttrs: (el: HTMLElement) =>
          toEmbedUrl(el.querySelector("iframe")?.getAttribute("src") || "")
            ? null
            : false
      }
    ];
  },

  renderHTML({ HTMLAttributes }: { HTMLAttributes: Record<string, unknown> }) {
    return [
      "div",
      { class: "video-embed" },
      [
        "iframe",
        mergeAttributes(HTMLAttributes, {
          width: "560",
          height: "315",
          frameborder: "0",
          allowfullscreen: "true",
          allow:
            "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
        })
      ]
    ];
  },

  addNodeView() {
    return ReactNodeViewRenderer(PagesVideoView);
  },

  addCommands() {
    return {
      insertPagesVideo:
        (attrs: { src: string }) =>
        ({ commands }: CommandProps) =>
          commands.insertContent({ type: this.name, attrs }),
      updatePagesVideo:
        (attrs: { src: string }) =>
        ({ commands }: CommandProps) =>
          commands.updateAttributes("pagesVideo", attrs)
    };
  }
});

declare module "@tiptap/core" {
  interface EditorEvents {
    pagesVideoReplace: Record<string, never>;
  }

  interface Commands<ReturnType> {
    pagesVideo: {
      insertPagesVideo: (attrs: { src: string }) => ReturnType;
      updatePagesVideo: (attrs: { src: string }) => ReturnType;
    };
  }
}
