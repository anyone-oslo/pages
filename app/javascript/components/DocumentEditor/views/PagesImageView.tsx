import { NodeViewWrapper, type NodeViewProps } from "@tiptap/react";
import { useState } from "react";

import AssetPicker from "../AssetPicker";
import useAssets from "../useAssets";

/** Size classes sites already use via [image:123 class="small"]. */
const IMAGE_CLASSES = [
  { value: "", label: "Default" },
  { value: "small", label: "Small" },
  { value: "medium", label: "Medium" },
  { value: "large", label: "Large" },
  { value: "left", label: "Left" },
  { value: "right", label: "Right" }
];

export default function PagesImageView({
  node,
  selected,
  updateAttributes,
  deleteNode
}: NodeViewProps) {
  const [open, setOpen] = useState(false);
  const [picking, setPicking] = useState(false);
  const { imageById } = useAssets();

  const imageId = node.attrs.imageId as number | string | null;
  const className = (node.attrs.className as string) || "";
  const link = (node.attrs.link as string) || "";
  const asset = imageById(imageId);

  const code = (() => {
    const parts = [`[image:${imageId ?? "?"}`];
    if (className) parts.push(` class="${className}"`);
    if (link) parts.push(` link="${link}"`);
    return parts.join("") + "]";
  })();

  return (
    <NodeViewWrapper
      as="figure"
      className={["doc-image", className, selected || open ? "is-selected" : ""]
        .filter(Boolean)
        .join(" ")}
      contentEditable={false}>
      <button
        type="button"
        className="doc-image__hit"
        title="Edit image"
        onMouseDown={(e) => {
          e.preventDefault();
          e.stopPropagation();
          setOpen(!open);
        }}>
        {asset ? (
          <img
            src={asset.thumbnail}
            alt={asset.alternative}
            draggable={false}
          />
        ) : (
          <div className="doc-image__missing">
            Image #{imageId ?? "?"} is not on this page
          </div>
        )}
        <code className="doc-embed__code">{code}</code>
      </button>

      {open ? (
        <div className="doc-popover doc-popover--embed" role="dialog">
          <fieldset>
            <legend>Class</legend>
            <div className="doc-popover__choices">
              {IMAGE_CLASSES.map((c) => (
                <button
                  key={c.value || "default"}
                  type="button"
                  className={className === c.value ? "active" : ""}
                  onClick={() => updateAttributes({ className: c.value })}>
                  {c.label}
                </button>
              ))}
            </div>
          </fieldset>
          <label>
            Link (optional)
            <input
              type="text"
              value={link}
              onChange={(e) => updateAttributes({ link: e.target.value })}
              placeholder="https://… or /path"
            />
          </label>
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
          kind="image"
          onClose={() => setPicking(false)}
          onPick={(img) => {
            updateAttributes({ imageId: img.id });
            setPicking(false);
          }}
        />
      ) : null}
    </NodeViewWrapper>
  );
}
