import {
  NodeViewContent,
  NodeViewWrapper,
  type NodeViewProps
} from "@tiptap/react";

import EmbedHead from "../EmbedHead";

/** Editor chrome only. Stored HTML stays a bare <aside>. */
export default function AsideView({
  editor,
  getPos,
  selected
}: NodeViewProps) {
  return (
    <NodeViewWrapper
      as="aside"
      className={"doc-aside" + (selected ? " is-selected" : "")}>
      <EmbedHead
        label="Fact box"
        onRemove={() => {
          const pos = getPos();
          if (typeof pos !== "number") return;
          editor.chain().focus().setTextSelection(pos + 1).toggleAside().run();
        }}
      />
      <NodeViewContent className="doc-aside__body" />
    </NodeViewWrapper>
  );
}
