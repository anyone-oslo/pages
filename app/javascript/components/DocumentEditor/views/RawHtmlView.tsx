import { NodeViewWrapper, type NodeViewProps } from "@tiptap/react";

import { describeHtml } from "../nodes/RawHtml";

export default function RawHtmlView({
  node,
  selected,
  updateAttributes,
  deleteNode
}: NodeViewProps) {
  const html = (node.attrs.html as string) || "";
  const rows = Math.min(12, Math.max(3, html.split("\n").length + 1));

  return (
    <NodeViewWrapper
      as="div"
      className={"doc-raw" + (selected ? " is-selected" : "")}
      contentEditable={false}>
      <div className="doc-raw__head">
        <span className="doc-raw__label">HTML · {describeHtml(html)}</span>
        <button
          type="button"
          className="doc-raw__delete"
          onMouseDown={(e) => {
            e.preventDefault();
            deleteNode();
          }}>
          Remove
        </button>
      </div>
      <textarea
        className="doc-raw__code"
        value={html}
        rows={rows}
        spellCheck={false}
        placeholder="Paste embed code or HTML here"
        onChange={(e) => updateAttributes({ html: e.target.value })}
      />
    </NodeViewWrapper>
  );
}
