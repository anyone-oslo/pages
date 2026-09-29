import { Node } from "@tiptap/core";
import type { CommandProps } from "@tiptap/core";
import { ReactNodeViewRenderer } from "@tiptap/react";

import AsideView from "../views/AsideView";

/**
 * Fact box. Stored as a bare <aside> so existing site CSS applies
 * (frittord has 198 of these). Holds any block content.
 */
export const Aside = Node.create({
  name: "aside",
  group: "block",
  content: "block+",
  defining: true,

  parseHTML() {
    return [{ tag: "aside" }];
  },

  renderHTML() {
    return ["aside", 0];
  },

  addNodeView() {
    return ReactNodeViewRenderer(AsideView);
  },

  addCommands() {
    return {
      toggleAside:
        () =>
        ({ commands }: CommandProps) =>
          commands.toggleWrap(this.name)
    };
  }
});

declare module "@tiptap/core" {
  interface Commands<ReturnType> {
    aside: {
      toggleAside: () => ReturnType;
    };
  }
}
