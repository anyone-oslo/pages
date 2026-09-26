import { NodeViewWrapper, type NodeViewProps } from "@tiptap/react";

import EmbedHead from "../EmbedHead";
import { toWatchUrl, VIDEO_REPLACE_EVENT } from "../nodes/PagesVideo";

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
  editor,
  getPos,
  node,
  selected,
  deleteNode
}: NodeViewProps) {
  const src = (node.attrs.src as string) || "";
  const thumb = src ? youtubeThumb(src) : null;
  const watch = src ? toWatchUrl(src) : "";

  return (
    <NodeViewWrapper
      as="div"
      className={"doc-video" + (selected ? " is-selected" : "")}
      contentEditable={false}>
      <EmbedHead
        label="Video"
        onReplace={() => {
          const pos = getPos();
          if (typeof pos !== "number") return;
          editor.chain().focus().setNodeSelection(pos).run();
          editor.emit(VIDEO_REPLACE_EVENT, {});
        }}
        onRemove={() => deleteNode()}
      />
      <div className="doc-video__frame">
        {thumb ? (
          <img src={thumb} alt="" className="doc-video__thumb" />
        ) : src ? (
          <div className="doc-video__placeholder" />
        ) : (
          <div className="doc-video__missing">No video URL</div>
        )}
        {src ? (
          <a
            className="doc-video__url"
            href={watch}
            target="_blank"
            rel="noopener noreferrer"
            title="Open video in a new tab">
            <code className="doc-embed__code">{src}</code>
          </a>
        ) : null}
      </div>
    </NodeViewWrapper>
  );
}
