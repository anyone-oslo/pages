import { NodeViewWrapper, type NodeViewProps } from "@tiptap/react";
import { useState } from "react";

import AssetPicker from "../AssetPicker";
import EmbedHead from "../EmbedHead";
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
  const [picking, setPicking] = useState(false);
  const { imageById } = useAssets();

  const imageId = node.attrs.imageId as number | string | null;
  const className = (node.attrs.className as string) || "";
  // Kept for round-trip of existing [image:… link="…"] codes; not editable.
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
      className={["doc-image", className, selected ? "is-selected" : ""]
        .filter(Boolean)
        .join(" ")}
      contentEditable={false}>
      <EmbedHead
        label="Image"
        onReplace={() => setPicking(true)}
        onRemove={() => deleteNode()}
      />
      <div className="doc-embed__controls">
        <div className="doc-embed__sizes" role="group" aria-label="Size">
          {IMAGE_CLASSES.map((c) => (
            <button
              key={c.value || "default"}
              type="button"
              className={className === c.value ? "active" : ""}
              onMouseDown={(e) => e.preventDefault()}
              onClick={() => updateAttributes({ className: c.value })}>
              {c.label}
            </button>
          ))}
        </div>
      </div>
      <div className="doc-image__frame">
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
      </div>
      {asset?.caption ? (
        <figcaption className="doc-image__caption">{asset.caption}</figcaption>
      ) : null}
      <div className="doc-image__meta">
        {asset ? (
          asset.alternative ? (
            <span className="doc-image__alt">Alt: {asset.alternative}</span>
          ) : (
            <span className="doc-image__alt doc-image__alt--missing">
              Missing alt text — add it in the Images tab
            </span>
          )
        ) : null}
        <code className="doc-embed__code">{code}</code>
      </div>

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
