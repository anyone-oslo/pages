import assert from "node:assert/strict";
import { test } from "node:test";

import {
  codeToPlaceholder,
  extractCodes,
  imageCode,
  isDocument,
  parseImageOptions
} from "./codes.ts";

const doc = (body: string) => `<notextile>\n${body}\n</notextile>`;

test("turns multi-id attachment codes into file placeholders", () => {
  assert.equal(
    codeToPlaceholder("[attachment:5,6]"),
    '<a class="file" data-file="5"></a>, <a class="file" data-file="6"></a>'
  );
});

test("leaves legacy file codes as text", () => {
  const { html, codes } = extractCodes("<p>Get [file:5]</p>");
  assert.deepEqual([html, codes], ["<p>Get [file:5]</p>", []]);
});

test("keeps ampersands in image codes", () => {
  const code = '[image:1 class="a&b" link="/a?b=1&c=2"]';
  const options = parseImageOptions(code.slice("[image:1".length, -1));
  assert.equal(imageCode("1", options), code);
});

test("escapes image options for the placeholder attributes", () => {
  assert.match(
    codeToPlaceholder('[image:1 link="/a?b=1&c=2"]'),
    /data-link="\/a\?b=1&amp;c=2"/
  );
});

test("keeps a legacy image size", () => {
  const options = parseImageOptions(' size="100x100"');
  assert.equal(imageCode("1", options), '[image:1 size="100x100"]');
});

test("adds no size to a new image", () => {
  assert.equal(imageCode("1", {}), "[image:1]");
});

test("treats a document as a document", () => {
  assert.equal(isDocument(doc("<p>a</p>")), true);
});

test("allows whitespace around a document", () => {
  assert.equal(isDocument(`\n  ${doc("<p>a</p>")}\n`), true);
});

test("treats Textile between notextile blocks as Textile", () => {
  const textile = "<notextile>\n<p>a</p>\n</notextile>\n\nThen *bold*\n\n";
  assert.equal(isDocument(`${textile}${doc("<p>c</p>")}`), false);
});

test("treats Textile after a leading notextile block as Textile", () => {
  assert.equal(isDocument("<notextile><p>a</p></notextile>\n\n*b*"), false);
});
