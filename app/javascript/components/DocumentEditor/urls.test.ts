import assert from "node:assert/strict";
import { test } from "node:test";

import { toEmbedUrl } from "./urls.ts";

test("rejects javascript: URLs on a video host", () => {
  assert.equal(
    toEmbedUrl("javascript://www.youtube.com/embed/%0aalert(1)"),
    null
  );
});

test("rejects data: URLs", () => {
  assert.equal(toEmbedUrl("data:text/html,<script>alert(1)</script>"), null);
});

test("upgrades http embeds to https", () => {
  assert.equal(
    toEmbedUrl("http://www.youtube.com/embed/abc_12-3"),
    "https://www.youtube.com/embed/abc_12-3"
  );
});

test("keeps the Vimeo privacy hash", () => {
  assert.equal(
    toEmbedUrl("https://player.vimeo.com/video/123?h=abc"),
    "https://player.vimeo.com/video/123?h=abc"
  );
});

test("turns a watch URL into an embed URL", () => {
  assert.equal(
    toEmbedUrl("https://www.youtube.com/watch?v=abc_12-3&t=5"),
    "https://www.youtube-nocookie.com/embed/abc_12-3"
  );
});

test("rejects a watch URL with an odd id", () => {
  assert.equal(toEmbedUrl('https://www.youtube.com/watch?v=a"b'), null);
});

test("rejects an embed URL with an odd id", () => {
  assert.equal(toEmbedUrl("https://www.youtube.com/embed/a%22b"), null);
});
