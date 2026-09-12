import { NodeViewWrapper, type NodeViewProps } from "@tiptap/react";
import { useState } from "react";

import { toEmbedUrl } from "../nodes/PagesVideo";
import UrlPopover from "../UrlPopover";

/** Admin preview only: YouTube thumbnail, no live iframe. */
function youtubeThumb(src: string): string | null {
  try {
    const url = new URL(src);
    const host = url.hostname.replace(/^www\./, "");
    if (host === "youtu.be") {
      const id = url.pathname.split("/").filter(Boolean)[0];
      return id ? `https://img.youtube.com/vi/${id}/hqdefault.jpg` : null;
    }
    if (host === "youtube.com" || host === "youtube-nocookie.com") {
      const embed = url.pathname.match(/^\/embed\/([^/?]+)/);
      const id = embed?.[1] || url.searchParams.get("v");
      return id ? `https://img.youtube.com/vi/${id}/hqdefault.jpg` : null;
    }
  } catch {
    return null;
  }
  return null;
}

export default function PagesVideoView({
  node,
  selected,
  updateAttributes,
  deleteNode
}: NodeViewProps) {
  const [open, setOpen] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const src = (node.attrs.src as string) || "";
  const thumb = src ? youtubeThumb(src) : null;

  return (
    <NodeViewWrapper
      as="div"
      className={"doc-video" + (selected || open ? " is-selected" : "")}
      contentEditable={false}>
      <div className="doc-video__frame">
        {thumb ? (
          <img src={thumb} alt="" className="doc-video__thumb" />
        ) : src ? (
          <div className="doc-video__placeholder" />
        ) : (
          <div className="doc-video__missing">No video URL</div>
        )}
        <button
          type="button"
          className="doc-video__hit"
          title="Edit video"
          onMouseDown={(e) => {
            e.preventDefault();
            e.stopPropagation();
            setOpen(!open);
          }}>
          <code className="doc-embed__code">{src}</code>
        </button>
      </div>

      {open ? (
        <UrlPopover
          title="Video URL (YouTube or Vimeo)"
          initialUrl={src}
          placeholder="https://www.youtube.com/watch?v=… or https://vimeo.com/…"
          error={error}
          onApply={(url) => {
            const embed = toEmbedUrl(url);
            if (!embed) {
              setError("Only YouTube and Vimeo links are supported.");
              return;
            }
            updateAttributes({ src: embed });
            setError(null);
            setOpen(false);
          }}
          onRemove={() => deleteNode()}
          onClose={() => setOpen(false)}
        />
      ) : null}
    </NodeViewWrapper>
  );
}
