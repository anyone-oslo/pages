type Replacement = [string, string, string];

export type ActionFn = (str: string) => Replacement;

type Action = {
  name: string;
  className: string;
  fn: ActionFn;
  hotkey?: string;
};

function strToList(str: string, prefix: string): string {
  return str
    .split("\n")
    .map((line) => prefix + " " + line)
    .join("\n");
}

function relativeUrl(str: string): string {
  let url: URL = null;

  if (!str.match(/^https:\/\//) || !document || !document.location) {
    return str;
  }

  try {
    url = new URL(str);
  } catch (error) {
    console.log("Error parsing URL: ", error);
  }

  if (
    url &&
    url.hostname === document.location.hostname &&
    (document.location.port || "80") === (url.port || "80")
  ) {
    return url.pathname;
  }
  return str;
}

function emailLink(selection: string): Replacement {
  const address = prompt("Enter email address", "");
  const name = selection.length > 0 ? selection : address;
  return ['"', name, `":mailto:${address}`];
}

function link(selection: string): Replacement {
  const name = selection.length > 0 ? selection : "Link text";
  const url = prompt("Enter link URL", "");
  if (url) {
    return ['"', name, `":${relativeUrl(url)}`];
  } else {
    return ["", name, ""];
  }
}

export const simpleActions: Action[] = [
  {
    name: "bold",
    className: "bold",
    hotkey: "b",
    fn: (str: string) => ["<b>", str, "</b>"]
  },
  {
    name: "italic",
    className: "italic",
    hotkey: "i",
    fn: (str: string) => ["<i>", str, "</i>"]
  }
];

export const advancedActions: Action[] = [
  {
    name: "Heading 2",
    className: "header h2",
    fn: (str: string) => ["h2. ", str, ""]
  },
  {
    name: "Heading 3",
    className: "header h3",
    fn: (str: string) => ["h3. ", str, ""]
  },
  {
    name: "Heading 4",
    className: "header h4",
    fn: (str: string) => ["h4. ", str, ""]
  },
  {
    name: "Blockquote",
    className: "quote-left",
    fn: (str: string) => ["bq. ", str, ""]
  },
  {
    name: "List",
    className: "list-ul",
    fn: (str: string) => ["", strToList(str, "*"), ""]
  },
  {
    name: "Ordered list",
    className: "list-ol",
    fn: (str: string) => ["", strToList(str, "#"), ""]
  },
  { name: "Link", className: "link", fn: link },
  { name: "Email link", className: "envelope", fn: emailLink }
];
