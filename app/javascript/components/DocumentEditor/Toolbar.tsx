import type { Editor } from "@tiptap/react";
import { useEditorState } from "@tiptap/react";
import type { LucideIcon } from "lucide-react";
import {
  Bold,
  CodeXml,
  Eraser,
  FilePlus,
  Heading2,
  Heading3,
  Heading4,
  ImagePlus,
  Italic,
  Link as LinkIcon,
  List,
  ListOrdered,
  Minus,
  Quote,
  Redo2,
  SquareDashed,
  Strikethrough,
  Superscript,
  Underline,
  Undo2,
  Video
} from "lucide-react";
import { useState } from "react";

import AssetPicker from "./AssetPicker";
import type { DocumentFormat } from "./extensions";
import { toEmbedUrl } from "./nodes/PagesVideo";
import UrlPopover from "./UrlPopover";

type Props = {
  editor: Editor | null;
  linkOpen: boolean;
  onLinkOpenChange: (open: boolean) => void;
  allowFiles: boolean;
  format: DocumentFormat;
};

function Button({
  title,
  active,
  disabled,
  onClick,
  icon: Icon
}: {
  title: string;
  active?: boolean;
  disabled?: boolean;
  onClick: () => void;
  icon: LucideIcon;
}) {
  return (
    <button
      type="button"
      title={title}
      aria-label={title}
      disabled={disabled}
      className={"button" + (active ? " active" : "")}
      onMouseDown={(e) => {
        e.preventDefault();
        if (!disabled) onClick();
      }}>
      <Icon size={18} strokeWidth={2.25} aria-hidden />
    </button>
  );
}

// Tiptap 3 does not re-render on every transaction; this selector makes
// the toolbar follow the selection (active marks, undo/redo availability).
function useToolbarState(editor: Editor | null) {
  return useEditorState({
    editor,
    selector: ({ editor: ed }) => {
      if (!ed) return null;
      return {
        editable: ed.isEditable,
        canUndo: ed.can().undo(),
        canRedo: ed.can().redo(),
        h2: ed.isActive("heading", { level: 2 }),
        h3: ed.isActive("heading", { level: 3 }),
        h4: ed.isActive("heading", { level: 4 }),
        bold: ed.isActive("bold"),
        italic: ed.isActive("italic"),
        underline: ed.isActive("underline"),
        strike: ed.isActive("strike"),
        superscript: ed.isActive("superscript"),
        bulletList: ed.isActive("bulletList"),
        orderedList: ed.isActive("orderedList"),
        blockquote: ed.isActive("blockquote"),
        aside: ed.isActive("aside"),
        link: ed.isActive("link"),
        image: ed.isActive("pagesImage"),
        file: ed.isActive("pagesFile"),
        video: ed.isActive("pagesVideo"),
        raw: ed.isActive("rawHtml")
      };
    }
  });
}

export default function Toolbar({
  editor,
  linkOpen,
  onLinkOpenChange,
  allowFiles,
  format
}: Props) {
  const [picker, setPicker] = useState<"image" | "file" | "video" | null>(null);
  const [videoError, setVideoError] = useState<string | null>(null);
  const state = useToolbarState(editor);

  if (!editor || !state) return null;
  const full = format === "document";
  const locked = !state.editable;

  const applyLink = (url: string) => {
    if (!url) {
      editor.chain().focus().extendMarkRange("link").unsetLink().run();
    } else {
      editor
        .chain()
        .focus()
        .extendMarkRange("link")
        .setLink({ href: url })
        .run();
    }
    onLinkOpenChange(false);
  };

  return (
    <div className="doc-toolbar-wrap">
      <div className="rich-text toolbar doc-toolbar" role="toolbar">
        <Button
          title="Undo"
          icon={Undo2}
          disabled={locked || !state.canUndo}
          onClick={() => editor.chain().focus().undo().run()}
        />
        <Button
          title="Redo"
          icon={Redo2}
          disabled={locked || !state.canRedo}
          onClick={() => editor.chain().focus().redo().run()}
        />
        {full ? (
          <Button
            title="Heading 2"
            icon={Heading2}
            active={state.h2}
            disabled={locked}
            onClick={() =>
              editor.chain().focus().toggleHeading({ level: 2 }).run()
            }
          />
        ) : null}
        {full ? (
          <Button
            title="Heading 3"
            icon={Heading3}
            active={state.h3}
            disabled={locked}
            onClick={() =>
              editor.chain().focus().toggleHeading({ level: 3 }).run()
            }
          />
        ) : null}
        {full ? (
          <Button
            title="Heading 4"
            icon={Heading4}
            active={state.h4}
            disabled={locked}
            onClick={() =>
              editor.chain().focus().toggleHeading({ level: 4 }).run()
            }
          />
        ) : null}
        <Button
          title="Bold"
          icon={Bold}
          active={state.bold}
          disabled={locked}
          onClick={() => editor.chain().focus().toggleBold().run()}
        />
        <Button
          title="Italic"
          icon={Italic}
          active={state.italic}
          disabled={locked}
          onClick={() => editor.chain().focus().toggleItalic().run()}
        />
        {full ? (
          <Button
            title="Underline"
            icon={Underline}
            active={state.underline}
            disabled={locked}
            onClick={() => editor.chain().focus().toggleUnderline().run()}
          />
        ) : null}
        {full ? (
          <Button
            title="Strikethrough"
            icon={Strikethrough}
            active={state.strike}
            disabled={locked}
            onClick={() => editor.chain().focus().toggleStrike().run()}
          />
        ) : null}
        <Button
          title="Superscript"
          icon={Superscript}
          active={state.superscript}
          disabled={locked}
          onClick={() => editor.chain().focus().toggleSuperscript().run()}
        />
        {full ? (
          <Button
            title="Bullet list"
            icon={List}
            active={state.bulletList}
            disabled={locked}
            onClick={() => editor.chain().focus().toggleBulletList().run()}
          />
        ) : null}
        {full ? (
          <Button
            title="Numbered list"
            icon={ListOrdered}
            active={state.orderedList}
            disabled={locked}
            onClick={() => editor.chain().focus().toggleOrderedList().run()}
          />
        ) : null}
        {full ? (
          <Button
            title="Quote"
            icon={Quote}
            active={state.blockquote}
            disabled={locked}
            onClick={() => editor.chain().focus().toggleBlockquote().run()}
          />
        ) : null}
        {full ? (
          <Button
            title="Fact box"
            icon={SquareDashed}
            active={state.aside}
            disabled={locked}
            onClick={() => editor.chain().focus().toggleAside().run()}
          />
        ) : null}
        {full ? (
          <Button
            title="Horizontal rule"
            icon={Minus}
            disabled={locked}
            onClick={() => editor.chain().focus().setHorizontalRule().run()}
          />
        ) : null}
        <Button
          title="Link"
          icon={LinkIcon}
          active={state.link || linkOpen}
          disabled={locked}
          onClick={() => onLinkOpenChange(true)}
        />
        {full ? (
          <Button
            title="Insert image"
            icon={ImagePlus}
            active={state.image}
            disabled={locked}
            onClick={() => setPicker("image")}
          />
        ) : null}
        {full && allowFiles ? (
          <Button
            title="Insert file"
            icon={FilePlus}
            active={state.file}
            disabled={locked}
            onClick={() => setPicker("file")}
          />
        ) : null}
        {full ? (
          <Button
            title="Insert video (YouTube/Vimeo)"
            icon={Video}
            active={state.video}
            disabled={locked}
            onClick={() => setPicker("video")}
          />
        ) : null}
        {full ? (
          <Button
            title="HTML block (embed code, script, table)"
            icon={CodeXml}
            active={state.raw}
            disabled={locked}
            onClick={() => editor.chain().focus().insertRawHtml().run()}
          />
        ) : null}
        <Button
          title="Remove formatting"
          icon={Eraser}
          disabled={locked}
          onClick={() =>
            editor.chain().focus().unsetAllMarks().clearNodes().run()
          }
        />
      </div>

      {linkOpen ? (
        <UrlPopover
          title="Link URL"
          initialUrl={(editor.getAttributes("link").href as string) || ""}
          onApply={applyLink}
          onRemove={() => {
            editor.chain().focus().extendMarkRange("link").unsetLink().run();
            onLinkOpenChange(false);
          }}
          onClose={() => onLinkOpenChange(false)}
        />
      ) : null}

      {picker === "video" ? (
        <UrlPopover
          title="Video URL (YouTube or Vimeo)"
          initialUrl=""
          placeholder="https://www.youtube.com/watch?v=… or https://vimeo.com/…"
          error={videoError}
          onApply={(url) => {
            const embed = toEmbedUrl(url);
            if (!embed) {
              setVideoError("Only YouTube and Vimeo links are supported.");
              return;
            }
            editor.chain().focus().insertPagesVideo({ src: embed }).run();
            setVideoError(null);
            setPicker(null);
          }}
          onClose={() => {
            setVideoError(null);
            setPicker(null);
          }}
        />
      ) : null}

      {picker === "image" ? (
        <AssetPicker
          kind="image"
          onClose={() => setPicker(null)}
          onPick={(img) => {
            editor.chain().focus().insertPagesImage({ imageId: img.id }).run();
            setPicker(null);
          }}
        />
      ) : null}

      {picker === "file" ? (
        <AssetPicker
          kind="file"
          onClose={() => setPicker(null)}
          onPick={(file) => {
            editor.chain().focus().insertPagesFile({ fileId: file.id }).run();
            setPicker(null);
          }}
        />
      ) : null}
    </div>
  );
}
