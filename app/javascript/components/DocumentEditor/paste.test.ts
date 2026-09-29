import assert from "node:assert/strict";
import { before, describe, test } from "node:test";

import { build } from "esbuild";
import { JSDOM } from "jsdom";

type Doc = { toJSON(): unknown; textContent: string };
type Parse = (html: string, allowHtml: boolean, format?: string) => Doc;

// The editor code imports without file extensions and reads the global
// document, so bundle it and run it against jsdom.
async function setup(): Promise<Parse> {
  const dom = new JSDOM("<!doctype html><body></body>");
  Object.assign(globalThis, {
    window: dom.window,
    document: dom.window.document,
    Node: dom.window.Node
  });

  const bundle = async (file: string) => {
    const result = await build({
      entryPoints: [new URL(file, import.meta.url).pathname],
      bundle: true,
      write: false,
      format: "esm",
      platform: "node",
      logLevel: "silent"
    });
    return import(
      "data:text/javascript;base64," +
        Buffer.from(result.outputFiles[0].text).toString("base64")
    );
  };

  const { documentExtensions } = await bundle("./extensions.ts");
  const { stripPastedHtml } = await bundle("./paste.ts");
  const { getSchema } = await import("@tiptap/core");
  const { DOMParser } = await import("@tiptap/pm/model");

  return (html, allowHtml, format = "document") => {
    const schema = getSchema(documentExtensions("", format));
    const source = allowHtml ? html : stripPastedHtml(html);
    const holder = document.createElement("div");
    holder.innerHTML = source;
    return DOMParser.fromSchema(schema).parse(holder);
  };
}

const WORD = `<!--[if gte mso 9]><xml><o:OfficeDocumentSettings/></xml><![endif]-->
<p class="MsoNormal" style="margin:0cm"><span style="font-family:Calibri;mso-bidi-font-weight:bold"><b>Bold</b> and plain</span><o:p></o:p></p>
<p class="MsoListParagraph" style="mso-list:l0 level1 lfo1"><span style="mso-list:Ignore">1.<span>&nbsp;</span></span>Item</p>`;

const GOOGLE_DOCS =
  '<meta charset="utf-8"><b style="font-weight:normal;" id="docs-internal-guid-1234"><p dir="ltr" style="line-height:1.38"><span style="font-size:11pt;font-weight:700;">Heading text</span></p><p dir="ltr"><span style="font-size:11pt;font-style:italic;">Slanted</span></p></b>';

const WEB =
  '<h1>Title</h1><p>Text <a href="javascript:alert(1)">bad</a> <a href="https://example.com">good</a></p><table><tr><td>a</td><td>b</td></tr></table><script>alert(1)</script><style>p{color:red}</style>';

const json = (doc: Doc) => JSON.stringify(doc.toJSON());

describe("pasted HTML", () => {
  let parse: Parse;
  before(async () => {
    parse = await setup();
  });

  for (const allowHtml of [true, false]) {
    describe(`allowHtml ${allowHtml}`, () => {
      test("Word: keeps bold text, drops styles and Office markup", () => {
        const out = json(parse(WORD, allowHtml));
        assert.match(out, /"marks":\[\{"type":"bold"\}\]/);
        assert.doesNotMatch(out, /mso-|MsoNormal|Calibri|o:p/);
        assert.match(out, /Item/);
      });

      test("Google Docs: wrapper <b> is not bold, spans keep their marks", () => {
        const doc = parse(GOOGLE_DOCS, allowHtml);
        const out = json(doc);
        assert.match(out, /Heading text/);
        assert.match(out, /"type":"italic"/);
        assert.doesNotMatch(out, /docs-internal-guid|font-size/);
        // Only the 700-weight span is bold, not the "Slanted" paragraph.
        const slanted = JSON.stringify(
          (
            doc.toJSON() as {
              content: { content: { text: string; marks?: unknown[] }[] }[];
            }
          ).content[1].content[0]
        );
        assert.doesNotMatch(slanted, /bold/);
      });

      test("web: h1 becomes h2, unsafe href is dropped", () => {
        const out = json(parse(WEB, allowHtml));
        assert.match(out, /"type":"heading","attrs":\{"level":2\}/);
        assert.match(out, /https:\/\/example\.com/);
        assert.doesNotMatch(out, /javascript:/);
      });
    });
  }

  test("script and style never reach the text", () => {
    for (const allowHtml of [true, false]) {
      const doc = parse(WEB, allowHtml);
      assert.doesNotMatch(doc.textContent, /alert\(1\)|color:red/);
    }
  });

  test("allowHtml false flattens the table to paragraphs", () => {
    const out = json(parse(WEB, false));
    assert.doesNotMatch(out, /rawHtml/);
    assert.match(out, /a b/);
  });

  test("allowHtml true keeps the table as a raw HTML block", () => {
    assert.match(json(parse(WEB, true)), /rawHtml/);
  });

  test("inline format flattens headings and lists to paragraphs", () => {
    const out = json(
      parse("<h2>Head</h2><ul><li>One</li></ul>", true, "inline")
    );
    assert.doesNotMatch(out, /heading|bulletList/);
    assert.match(out, /Head/);
    assert.match(out, /One/);
  });
});
