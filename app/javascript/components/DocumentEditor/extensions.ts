import type { Extensions } from "@tiptap/core";
import { Extension, InputRule } from "@tiptap/core";
import Heading from "@tiptap/extension-heading";
import Link from "@tiptap/extension-link";
import Placeholder from "@tiptap/extension-placeholder";
import Superscript from "@tiptap/extension-superscript";
import StarterKit from "@tiptap/starter-kit";
import Typography from "@tiptap/extension-typography";

import { Aside } from "./nodes/Aside";
import { PagesFile } from "./nodes/PagesFile";
import { PagesImage } from "./nodes/PagesImage";
import { PagesVideo } from "./nodes/PagesVideo";
import { RawHtml } from "./nodes/RawHtml";
import { isAllowedHref } from "./urls";

export type DocumentFormat = "document" | "inline";

const linkExtension = Link.configure({
  openOnClick: false,
  enableClickSelection: true,
  HTMLAttributes: { target: null, rel: null },
  isAllowedUri: (href) => isAllowedHref(href)
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

const NO_RULES = {
  leftArrow: false,
  rightArrow: false,
  copyright: false,
  trademark: false,
  servicemark: false,
  registeredTrademark: false,
  oneHalf: false,
  plusMinus: false,
  notEqual: false,
  laquo: false,
  raquo: false,
  multiplication: false,
  superscriptTwo: false,
  superscriptThree: false,
  oneQuarter: false,
  threeQuarters: false
} as const;

const OPEN_DOUBLE = /(?:^|[\s{[(<'"\u2018\u201C])(")$/;
const CLOSE_DOUBLE = /"$/;

const isNorwegian = (lang: string) => /^(nb|nn|no)\b/i.test(lang);

/**
 * Double quotes follow the editor's current `lang` (« » for Norwegian),
 * which changes on a locale switch without rebuilding the editor.
 */
const DoubleQuotes = Extension.create({
  name: "doubleQuotes",
  addInputRules() {
    const rule = (find: RegExp, open: boolean) =>
      new InputRule({
        find,
        handler: ({ state, range, match }) => {
          const norwegian = isNorwegian(this.editor.view.dom.lang || "");
          let insert = open ? (norwegian ? "«" : "“") : norwegian ? "»" : "”";
          let start = range.from;
          const end = range.to;
          if (match[1]) {
            const offset = match[0].lastIndexOf(match[1]);
            insert += match[0].slice(offset + match[1].length);
            start += offset;
            const cutOff = start - end;
            if (cutOff > 0) {
              insert = match[0].slice(offset - cutOff, offset) + insert;
              start = end;
            }
          }
          state.tr.insertText(insert, start, end);
        }
      });
    return [rule(OPEN_DOUBLE, true), rule(CLOSE_DOUBLE, false)];
  }
});

/**
 * Typed dashes, ellipses and quotes, as RedCloth did for Textile. The
 * other rules (arrows, fractions, (c)) stay off.
 */
const typography = Typography.configure({
  ...NO_RULES,
  openDoubleQuote: false,
  closeDoubleQuote: false
});

/*
 * Constrained schema: headings 2–4, bold, italic, strike, superscript,
 * underline, quote, lists, links, hr, image, file, video. Keep in sync
 * with PagesCore::DocumentConverter (KEPT_TAGS, VIDEO_HOSTS).
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
      Placeholder.configure({ placeholder: placeholder || "" }),
      typography,
      DoubleQuotes
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
    // Same folding as DocumentConverter::RENAMES: h1 -> h2, h5/h6 -> h4.
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
    RawHtml,
    typography,
    DoubleQuotes
  ];
}
