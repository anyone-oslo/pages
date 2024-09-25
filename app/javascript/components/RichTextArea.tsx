import { useState, useRef, ChangeEvent } from "react";
import RichTextToolbarButton from "./RichTextToolbarButton";

type Props = {
  id: string;
  name: string;
  value: string;
  rows: number;
  className?: string;
  simple?: boolean;
  lang?: string;
  dir?: string;
  onChange?: (str: string) => void;
};

type Replacement = [string, string, string];
type ActionFn = (str: string) => Replacement;

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

const simpleActions: Action[] = [
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

const advancedActions: Action[] = [
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

export default function RichTextArea({
  id,
  name,
  value: initialValue,
  rows: initialRows,
  className,
  simple,
  lang,
  dir,
  onChange
}: Props) {
  const [value, setValue] = useState<string>(initialValue || "");
  const rows = initialRows || 5;
  const inputRef = useRef<HTMLTextAreaElement>(null);

  const actions = simple
    ? simpleActions
    : [...simpleActions, ...advancedActions];

  const applyAction = (fn: ActionFn) => {
    const [prefix, replacement, postfix] = fn(getSelection());
    replaceSelection(prefix, replacement, postfix);
  };

  const getSelection = (): string => {
    const textarea = inputRef.current;
    const { selectionStart, selectionEnd, value } = textarea;
    return value.substring(selectionStart, selectionEnd);
  };

  const handleChange = (evt: ChangeEvent<HTMLTextAreaElement>) => {
    updateValue(evt.target.value);
  };

  const handleKeyPress = (evt: React.KeyboardEvent) => {
    let key: string;
    if (evt.key >= "A" && evt.key <= "Z") {
      key = evt.key.toLowerCase();
    } else if (evt.key === "Enter") {
      key = "enter";
    }

    const hotkeys: Record<string, ActionFn> = {};
    actions.forEach((a) => {
      if (a.hotkey) {
        hotkeys[a.hotkey] = a.fn;
      }
    });

    if ((evt.metaKey || evt.ctrlKey) && key in hotkeys) {
      evt.preventDefault();
      applyAction(hotkeys[key]);
    }
  };

  const localeOptions = (): React.HTMLProps<HTMLTextAreaElement> => {
    const opts: React.HTMLProps<HTMLTextAreaElement> = {};

    if (lang) {
      opts.lang = lang;
    }

    if (dir) {
      opts.dir = dir;
    }

    return opts;
  };

  const replaceSelection = (
    prefix: string,
    replacement: string,
    postfix: string
  ) => {
    const textarea = inputRef.current;
    const { selectionStart, selectionEnd, value } = textarea;

    textarea.value =
      value.substring(0, selectionStart) +
      prefix +
      replacement +
      postfix +
      value.substring(selectionEnd);

    textarea.focus({ preventScroll: true });
    textarea.setSelectionRange(
      selectionStart + prefix.length,
      selectionStart + prefix.length + replacement.length
    );
    updateValue(textarea.value);
  };

  const getValue = (): string => {
    return onChange ? initialValue : value;
  };

  const updateValue = (str: string) => {
    if (onChange) {
      onChange(str);
    } else {
      setValue(str);
    }
  };

  const clickHandler = (fn: ActionFn) => (evt: React.MouseEvent) => {
    evt.preventDefault();
    applyAction(fn);
  };

  return (
    <div className="rich-text-area">
      <div className="rich-text toolbar">
        {actions.map((action) => (
          <RichTextToolbarButton
            key={action.name}
            name={action.name}
            className={action.className}
            onClick={clickHandler(action.fn)}
          />
        ))}
      </div>
      <textarea
        className={className || "rich"}
        ref={inputRef}
        id={id}
        name={name}
        value={getValue()}
        rows={rows}
        onChange={handleChange}
        onKeyDown={handleKeyPress}
        {...localeOptions()}
      />
    </div>
  );
}
