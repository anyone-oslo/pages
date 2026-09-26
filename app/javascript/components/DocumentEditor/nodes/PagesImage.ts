import { Node, mergeAttributes } from "@tiptap/core";
import type { CommandProps } from "@tiptap/core";
import { ReactNodeViewRenderer } from "@tiptap/react";

import PagesImageView from "../views/PagesImageView";

export type PagesImageAttrs = {
  imageId: number | string | null;
  className: string;
  link: string;
  size: string;
};

function dataAttr(name: string, key: keyof PagesImageAttrs) {
  return {
    default: key === "imageId" ? null : "",
    parseHTML: (element: HTMLElement) => element.getAttribute(name) || "",
    renderHTML: (attributes: Partial<PagesImageAttrs>) => {
      const value = attributes[key];
      return value ? { [name]: value } : {};
    }
  };
}

/** Mirrors PagesCore::ImageEmbedder: [image:ID class="…" link="…" size="WxH"] */
export const PagesImage = Node.create({
  name: "pagesImage",
  group: "block",
  atom: true,
  draggable: true,
  selectable: true,

  addAttributes() {
    return {
      imageId: dataAttr("data-image", "imageId"),
      className: dataAttr("data-class", "className"),
      link: dataAttr("data-link", "link"),
      size: dataAttr("data-size", "size")
    };
  },

  parseHTML() {
    return [{ tag: "figure[data-image]" }];
  },

  renderHTML({ HTMLAttributes }: { HTMLAttributes: Record<string, unknown> }) {
    return [
      "figure",
      mergeAttributes(HTMLAttributes, { class: "pages-image" })
    ];
  },

  addNodeView() {
    return ReactNodeViewRenderer(PagesImageView);
  },

  addCommands() {
    return {
      insertPagesImage:
        (attrs: Partial<PagesImageAttrs>) =>
        ({ commands }: CommandProps) =>
          commands.insertContent({ type: this.name, attrs })
    };
  }
});

declare module "@tiptap/core" {
  interface Commands<ReturnType> {
    pagesImage: {
      insertPagesImage: (attrs: Partial<PagesImageAttrs>) => ReturnType;
    };
  }
}
