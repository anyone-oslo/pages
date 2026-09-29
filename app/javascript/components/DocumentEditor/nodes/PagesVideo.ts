import { Node, mergeAttributes } from "@tiptap/core";
import type { CommandProps } from "@tiptap/core";
import { ReactNodeViewRenderer } from "@tiptap/react";

import { toEmbedUrl } from "../urls";
import PagesVideoView from "../views/PagesVideoView";

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
          return toEmbedUrl(iframe?.getAttribute("src") || "");
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
