import type { Extensions } from "@tiptap/core";
import { Extension } from "@tiptap/core";
import Heading from "@tiptap/extension-heading";
import Link from "@tiptap/extension-link";
import Placeholder from "@tiptap/extension-placeholder";
import Superscript from "@tiptap/extension-superscript";
import StarterKit from "@tiptap/starter-kit";

import { Aside } from "./nodes/Aside";
import { PagesFile } from "./nodes/PagesFile";
import { PagesImage } from "./nodes/PagesImage";
import { PagesVideo } from "./nodes/PagesVideo";
import { RawHtml } from "./nodes/RawHtml";

export type DocumentFormat = "document" | "inline";

const linkExtension = Link.configure({
  openOnClick: false,
  enableClickSelection: true,
  HTMLAttributes: { target: null, rel: null },
  isAllowedUri: (href) =>
    /^https?:\/\//.test(href) ||
    href.startsWith("/") ||
    href.startsWith("mailto:") ||
    href.startsWith("#")
});

// Underline and hr stay in the schema so existing content survives, but
// there is no toolbar button for them. This swallows Mod-U before the
// Underline extension sees it, so new underline cannot be typed either.
const legacyOnly = Extension.create({
  name: "legacyOnly",
  priority: 1000,
  addKeyboardShortcuts() {
    return { "Mod-u": () => true };
  }
});

/*
 * Constrained schema (SESSION.md decision 6 + the `proposed` profile in
 * .cursor/wysiwyg/schema.rb): headings 2–4, bold, italic, strike,
 * superscript, underline, quote, lists, links, hr, image, file, video.
 * Underline and hr are read-only legacy: parsed and kept, no toolbar
 * button, no shortcut.
 * No align, size, color, tables, code. Raw HTML only via the RawHtml block
 * (shown as code, stored verbatim).
 *
 * `inline` (block option `format: :inline`) is for standfirst, byline and
 * the like: paragraphs with bold, italic, superscript and links only.
 * Pasted headings, lists and embeds become plain paragraphs.
 */
export function documentExtensions(
  placeholder?: string,
  format: DocumentFormat = "document"
): Extensions {
  if (format === "inline") {
    return [
      StarterKit.configure({
        heading: false,
        code: false,
        codeBlock: false,
        blockquote: false,
        bulletList: false,
        orderedList: false,
        listItem: false,
        listKeymap: false,
        horizontalRule: false,
        strike: false,
        underline: false,
        dropcursor: false,
        gapcursor: false,
        link: false
      }),
      Superscript,
      linkExtension,
      Placeholder.configure({ placeholder: placeholder || "" })
    ];
  }

  return [
    StarterKit.configure({
      heading: false,
      code: false,
      codeBlock: false,
      dropcursor: false,
      gapcursor: false,
      link: false
    }),
    // Same folding as CANON in schema.rb: h1 -> h2, h5/h6 -> h4.
    Heading.extend({
      parseHTML() {
        return [1, 2, 3, 4, 5, 6].map((level) => ({
          tag: `h${level}`,
          attrs: { level: Math.min(Math.max(level, 2), 4) }
        }));
      }
    }).configure({ levels: [2, 3, 4] }),
    legacyOnly,
    Superscript,
    linkExtension,
    Placeholder.configure({ placeholder: placeholder || "" }),
    PagesImage,
    PagesFile,
    PagesVideo,
    Aside,
    RawHtml
  ];
}
