import assert from "node:assert/strict";
import { test } from "node:test";

import { isDocument, toEditorHtml, toStored } from "./serializer.ts";

const roundTrip = (stored: string) => toStored(toEditorHtml(stored));

const doc = (body: string) => `<notextile>\n${body}\n</notextile>`;

test("keeps attachment codes", () => {
  const stored = doc("<p>Get [attachment:5]</p>");
  assert.equal(roundTrip(stored), stored);
});

test("keeps legacy file codes as text", () => {
  const stored = doc("<p>Get [file:5]</p>");
  assert.equal(roundTrip(stored), stored);
});

const rawMarkup =
  "<table><tr><td><ul><li><p>x</p></li></ul><p></p></td></tr></table>";

test("keeps raw HTML blocks verbatim", () => {
  const escaped = rawMarkup.replace(/</g, "&lt;").replace(/>/g, "&gt;");
  const editorHtml = `<p>a</p><div data-raw-html="${escaped}"></div>`;
  assert.equal(toStored(editorHtml), doc(`<p>a</p>${rawMarkup}`));
});

test("keeps raw HTML blocks verbatim when < is not escaped", () => {
  const editorHtml = `<p>a</p><div data-raw-html="${rawMarkup}"></div>`;
  assert.equal(toStored(editorHtml), doc(`<p>a</p>${rawMarkup}`));
});

test("keeps ampersands in image codes", () => {
  const stored = doc('[image:1 class="a&b" link="/a?b=1&c=2"]');
  assert.equal(roundTrip(roundTrip(stored)), stored);
});

test("treats stored editor output as a document", () => {
  assert.equal(isDocument(toStored("<p>a</p>")), true);
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
