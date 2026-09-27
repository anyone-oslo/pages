import assert from "node:assert/strict";
import { test } from "node:test";

import { toEditorHtml, toStored } from "./serializer.ts";

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
