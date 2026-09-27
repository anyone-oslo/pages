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

test("keeps ampersands in image codes", () => {
  const stored = doc('[image:1 class="a&b" link="/a?b=1&c=2"]');
  assert.equal(roundTrip(roundTrip(stored)), stored);
});
