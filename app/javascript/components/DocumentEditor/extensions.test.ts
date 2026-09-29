import assert from "node:assert/strict";
import { test } from "node:test";

import { build } from "esbuild";

// extensions.ts imports React node views without file extensions, which
// node cannot load directly. Bundle it once and import the result.
async function load() {
  const result = await build({
    entryPoints: [new URL("./extensions.ts", import.meta.url).pathname],
    bundle: true,
    write: false,
    format: "esm",
    platform: "node",
    logLevel: "silent"
  });
  const code = result.outputFiles[0].text;
  return import(
    "data:text/javascript;base64," + Buffer.from(code).toString("base64")
  );
}

async function describe(format: "document" | "inline") {
  const { documentExtensions } = await load();
  const { flattenExtensions, getSchema, resolveExtensions } =
    await import("@tiptap/core");
  const extensions = documentExtensions("x", format);
  const schema = getSchema(extensions);

  const names = new Set(
    flattenExtensions(resolveExtensions(extensions)).map((ext) => ext.name)
  );

  return {
    nodes: Object.keys(schema.nodes).sort(),
    marks: Object.keys(schema.marks).sort(),
    extensions: [...names].sort()
  };
}

// Snapshot taken from the StarterKit-based config, before it was replaced
// with explicit extensions (the "starterKit" wrapper is the only name gone).
const DOCUMENT = {
  nodes: [
    "aside",
    "blockquote",
    "bulletList",
    "doc",
    "hardBreak",
    "heading",
    "horizontalRule",
    "listItem",
    "orderedList",
    "pagesFile",
    "pagesImage",
    "pagesVideo",
    "paragraph",
    "rawHtml",
    "text"
  ],
  marks: ["bold", "italic", "link", "strike", "superscript", "underline"],
  extensions: [
    "aside",
    "blockquote",
    "bold",
    "bulletList",
    "doc",
    "doubleQuotes",
    "hardBreak",
    "heading",
    "horizontalRule",
    "italic",
    "legacyOnly",
    "link",
    "listItem",
    "listItemBranchingDeleteKeymap",
    "listKeymap",
    "orderedList",
    "pagesFile",
    "pagesImage",
    "pagesVideo",
    "paragraph",
    "placeholder",
    "rawHtml",
    "strike",
    "superscript",
    "text",
    "trailingNode",
    "typography",
    "underline",
    "undoRedo"
  ]
};

const INLINE = {
  nodes: ["doc", "hardBreak", "paragraph", "text"],
  marks: ["bold", "italic", "link", "superscript"],
  extensions: [
    "bold",
    "doc",
    "doubleQuotes",
    "hardBreak",
    "italic",
    "link",
    "paragraph",
    "placeholder",
    "superscript",
    "text",
    "trailingNode",
    "typography",
    "undoRedo"
  ]
};

test("document format keeps the same schema and extensions", async () => {
  assert.deepEqual(await describe("document"), DOCUMENT);
});

test("inline format keeps the same schema and extensions", async () => {
  assert.deepEqual(await describe("inline"), INLINE);
});
