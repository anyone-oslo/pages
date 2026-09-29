import { getMarkRange } from "@tiptap/core";
import { TextSelection } from "@tiptap/pm/state";
import { EditorContent, useEditor } from "@tiptap/react";
import { useEffect, useRef, useState } from "react";

import { postJson } from "../lib/request";
import type { DocumentFormat } from "./DocumentEditor/extensions";
import { documentExtensions } from "./DocumentEditor/extensions";
import {
  isDocument,
  toEditorHtml,
  toStored
} from "./DocumentEditor/serializer";
import { stripPastedHtml } from "./DocumentEditor/paste";
import Toolbar from "./DocumentEditor/Toolbar";

type Props = {
  id: string;
  value: string;
  onChange: (value: string) => void;
  lang?: string;
  dir?: string;
  placeholder?: string;
  allowFiles?: boolean;
  minRows?: number;
  format?: DocumentFormat;
  allowHtml?: boolean;
};

/**
 * Spike: constrained rich text editor over the existing text column.
 * See DocumentEditor/serializer.ts for the stored form.
 */
export default function DocumentEditor({
  id,
  value,
  onChange,
  lang,
  dir,
  placeholder,
  allowFiles = true,
  minRows = 5,
  format = "document",
  allowHtml = true
}: Props) {
  const [linkOpen, setLinkOpen] = useState(false);
  const [showSource, setShowSource] = useState(false);
  const [converted, setConverted] = useState<{
    raw: string[];
    removed: string[];
  } | null>(null);
  const [loadError, setLoadError] = useState(false);
  const lastEmitted = useRef<string>(value || "");
  const loadRequest = useRef(0);
  const legacy = !!value && !isDocument(value);

  const editor = useEditor({
    extensions: documentExtensions(placeholder, format),
    // Legacy Textile is loaded empty and filled by the conversion below;
    // parsing Textile source as HTML would flatten it.
    content: legacy ? "" : toEditorHtml(value),
    immediatelyRender: true,
    editorProps: {
      ...(allowHtml ? {} : { transformPastedHTML: stripPastedHtml }),
      attributes: {
        id,
        class: "rich doc-content doc-content--" + format,
        style: `min-height: ${minRows * 1.6}em`,
        spellcheck: "true",
        ...(lang ? { lang } : {}),
        ...(dir ? { dir } : {})
      },
      handleClick: (view, pos, event) => {
        const target = event.target as HTMLElement | null;
        if (!target) return false;
        if (target.closest(".doc-image, .doc-file, .doc-video")) return false;

        const anchor = target.closest("a");
        if (!anchor || !view.dom.contains(anchor)) return false;
        event.preventDefault();

        const linkType = view.state.schema.marks.link;
        if (linkType) {
          const range = getMarkRange(view.state.doc.resolve(pos), linkType);
          if (range) {
            view.dispatch(
              view.state.tr.setSelection(
                TextSelection.create(view.state.doc, range.from, range.to)
              )
            );
          }
        }
        setLinkOpen(true);
        return true;
      }
    },
    onUpdate: ({ editor: ed }) => {
      const stored = toStored(ed.getHTML());
      lastEmitted.current = stored;
      onChange(stored);
    }
  });

  // Load the value into the editor. Legacy Textile goes through the server
  // (RedCloth + artifact policy) and is only shown converted: the stored
  // value stays Textile until the first edit emits a document.
  useEffect(() => {
    if (!editor) return;

    // Loading is not an edit: no onChange, and not undoable.
    // setEditable emits an update unless told not to.
    const setSilently = (html: string) =>
      editor
        .chain()
        .setMeta("addToHistory", false)
        .setContent(html, { emitUpdate: false })
        .run();

    const load = (stored: string) => {
      const request = ++loadRequest.current;
      setLoadError(false);
      if (isDocument(stored) || !stored.trim()) {
        setSilently(toEditorHtml(stored));
        editor.setEditable(true, false);
        return;
      }
      // Locked until the conversion arrives: a keystroke in the empty
      // editor would store an empty document over the Textile.
      setSilently("");
      editor.setEditable(false, false);
      postJson("/admin/document_conversions.json", {
        text: stored,
        block_format: format
      })
        .then(
          (response: { html: string; raw: string[]; removed: string[] }) => {
            if (request !== loadRequest.current) return;
            if (typeof response.html !== "string")
              throw new Error("bad response");
            setSilently(toEditorHtml(response.html));
            editor.setEditable(true, false);
            setConverted({
              raw: response.raw || [],
              removed: response.removed || []
            });
          }
        )
        .catch(() => {
          if (request !== loadRequest.current) return;
          // Never let Textile source be edited as HTML: saving would
          // flatten it. Keep the block locked and the stored value as-is.
          setLoadError(true);
        });
    };

    if (!isDocument(value) && !!value && lastEmitted.current === value) {
      load(value); // first mount with Textile
      return;
    }
    if ((value || "") === lastEmitted.current) return;
    // External change (locale switch, save response)
    lastEmitted.current = value || "";
    setConverted(null);
    load(value || "");
  }, [editor, value, format]);

  return (
    <div className="rich-text-area doc-editor">
      <Toolbar
        editor={editor}
        linkOpen={linkOpen}
        onLinkOpenChange={setLinkOpen}
        allowFiles={allowFiles}
        format={format}
        allowHtml={allowHtml}
      />
      {loadError ? (
        <p className="doc-editor__notice doc-editor__notice--error">
          This text could not be converted from Textile, so editing is disabled.
          The stored text is unchanged. Reload the page to try again.
        </p>
      ) : null}
      {converted && converted.removed.length > 0 ? (
        <div className="doc-editor__notice">
          <p>
            Some formatting was simplified when this text was converted:{" "}
            {converted.removed.join(", ")}. Nothing is stored until you edit
            this block.
          </p>
          {allowHtml && converted.raw.length > 0 ? (
            <p>
              <strong>Kept as HTML blocks:</strong> {converted.raw.join(", ")}.
            </p>
          ) : null}
        </div>
      ) : null}
      <EditorContent editor={editor} />
      <div className="doc-editor__footer">
        {allowHtml ? (
          <button
            type="button"
            className="doc-editor__source-toggle"
            onClick={() => setShowSource(!showSource)}>
            {showSource ? "Hide stored source" : "Show stored source"}
          </button>
        ) : null}
        {allowHtml && showSource ? (
          <pre className="doc-editor__source">{value || "(empty)"}</pre>
        ) : null}
      </div>
    </div>
  );
}
