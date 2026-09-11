import { Node, mergeAttributes } from "@tiptap/core";
import type { CommandProps } from "@tiptap/core";
import { ReactNodeViewRenderer } from "@tiptap/react";

import PagesFileView from "../views/PagesFileView";

/**
 * Mirrors [attachment:ID] — rendered by PagesCore.config.attachment_embedder.
 * Inline: the corpus mostly has codes inside text ("[attachment:1] (pdf)",
 * inside <strong> or <li>), so a block node would split or drop them.
 */
export const PagesFile = Node.create({
  name: "pagesFile",
  group: "inline",
  inline: true,
  atom: true,
  draggable: true,
  selectable: true,

  addAttributes() {
    return {
      fileId: {
        default: null,
        parseHTML: (element: HTMLElement) => element.getAttribute("data-file"),
        renderHTML: (attributes: { fileId?: string | number | null }) =>
          attributes.fileId ? { "data-file": attributes.fileId } : {}
      }
    };
  },

  parseHTML() {
    return [{ tag: "a[data-file]" }, { tag: "figure[data-file]" }];
  },

  renderHTML({ HTMLAttributes }: { HTMLAttributes: Record<string, unknown> }) {
    return ["a", mergeAttributes(HTMLAttributes, { class: "file" })];
  },

  addNodeView() {
    return ReactNodeViewRenderer(PagesFileView);
  },

  addCommands() {
    return {
      insertPagesFile:
        (attrs: { fileId: number }) =>
        ({ commands }: CommandProps) =>
          commands.insertContent({ type: this.name, attrs })
    };
  }
});

declare module "@tiptap/core" {
  interface Commands<ReturnType> {
    pagesFile: {
      insertPagesFile: (attrs: { fileId: number }) => ReturnType;
    };
  }
}
