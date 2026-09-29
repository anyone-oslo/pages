import assert from "node:assert/strict";
import { test } from "node:test";

import { isAllowedHref, normalizeHref, toEmbedUrl } from "./urls.ts";

test("allows links regardless of scheme case", () => {
  assert.equal(isAllowedHref("HTTP://example.com"), true);
  assert.equal(isAllowedHref("MAILTO:a@example.com"), true);
});

test("allows tel: links", () => {
  assert.equal(isAllowedHref("tel:+4712345678"), true);
});

test("allows paths and anchors", () => {
  assert.equal(isAllowedHref("/about"), true);
  assert.equal(isAllowedHref("#top"), true);
});

test("rejects other schemes", () => {
  assert.equal(isAllowedHref("javascript:alert(1)"), false);
  assert.equal(isAllowedHref("JavaScript:alert(1)"), false);
  assert.equal(isAllowedHref("ftp://example.com"), false);
});

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

test("adds https:// to a bare domain", () => {
  assert.equal(normalizeHref("www.foo.no"), "https://www.foo.no");
  assert.equal(normalizeHref("foo.no/x?y=1"), "https://foo.no/x?y=1");
});

test("trims the input", () => {
  assert.equal(normalizeHref("  foo.no "), "https://foo.no");
});

test("keeps allowed links as they are", () => {
  for (const href of [
    "https://foo.no",
    "HTTP://X.NO",
    "/about",
    "#top",
    "tel:+4712345678",
    "mailto:a@example.com"
  ]) {
    assert.equal(normalizeHref(href), href);
  }
});

test("rejects links outside the allowlist", () => {
  for (const href of [
    "javascript:alert(1)",
    "data:text/html,x",
    "ftp://foo.no",
    "name@example.com",
    "two words.no",
    "localhost:3000",
    "foo",
    ""
  ]) {
    assert.equal(normalizeHref(href), null, href);
  }
});
