import { NodeViewWrapper, type NodeViewProps } from "@tiptap/react";
import { File as FileIcon } from "lucide-react";
import { useState } from "react";

import AssetPicker from "../AssetPicker";
import useAssets from "../useAssets";

export default function PagesFileView({
  node,
  selected,
  updateAttributes,
  deleteNode
}: NodeViewProps) {
  const [open, setOpen] = useState(false);
  const [picking, setPicking] = useState(false);
  const { fileById } = useAssets();

  const fileId = node.attrs.fileId as number | string | null;
  const asset = fileById(fileId);

  return (
    <NodeViewWrapper
      as="span"
      className={"doc-file" + (selected || open ? " is-selected" : "")}
      contentEditable={false}>
      <button
        type="button"
        className="doc-file__hit"
        title="Edit file"
        onMouseDown={(e) => {
          e.preventDefault();
          e.stopPropagation();
          setOpen(!open);
        }}>
        <FileIcon size={16} strokeWidth={1.75} aria-hidden />
        <span>
          {asset ? asset.name : `File #${fileId ?? "?"} is not on this page`}
        </span>
        <code className="doc-embed__code">[attachment:{fileId ?? "?"}]</code>
      </button>

      {open ? (
        <div className="doc-popover doc-popover--embed" role="dialog">
          <p>
            Shown as a download link. Rename it in the <strong>Files</strong>{" "}
            tab.
          </p>
          <div className="doc-popover__actions">
            <button
              type="button"
              className="primary"
              onClick={() => setOpen(false)}>
              Done
            </button>
            <button type="button" onClick={() => setPicking(true)}>
              Replace…
            </button>
            <button
              type="button"
              className="danger"
              onClick={() => deleteNode()}>
              Remove
            </button>
          </div>
        </div>
      ) : null}

      {picking ? (
        <AssetPicker
          kind="file"
          onClose={() => setPicking(false)}
          onPick={(file) => {
            updateAttributes({ fileId: file.id });
            setPicking(false);
          }}
        />
      ) : null}
    </NodeViewWrapper>
  );
}
