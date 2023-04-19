import React, { createRef, ChangeEvent, Component, RefObject } from "react";
import RichTextToolbarButton from "./RichTextToolbarButton";

interface RichTextAreaProps {
  id: string;
  className: string;
  name: string;
  value: string;
  rows: number;
  simple: boolean;
  lang: string;
  dir: string;
  onChange: (str: string) => void;
}

interface RichTextAreaState {
  value: string;
  rows: number;
}

type ActionFn = (str: string) => [string, string, string];

interface Action {
  name: string;
  className: string;
  fn: ActionFn;
  hotkey?: string;
}

export default class RichTextArea extends Component<
  RichTextAreaProps,
  RichTextAreaState
> {
  inputRef: RefObject<HTMLTextAreaElement>;

  constructor(props: RichTextAreaProps) {
    super(props);
    this.state = {
      value: props.value || "",
      rows: props.rows || 5
    };
    this.inputRef = createRef<HTMLTextAreaElement>();
  }

  actions = () => {
    const simple: Action[] = [
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

    const advanced: Action[] = [
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
        fn: (str: string) => ["", this.strToList(str, "*"), ""]
      },
      {
        name: "Ordered list",
        className: "list-ol",
        fn: (str: string) => ["", this.strToList(str, "#"), ""]
      },
      { name: "Link", className: "link", fn: this.link },
      { name: "Email link", className: "envelope", fn: this.emailLink }
    ];

    return this.props.simple ? simple : [...simple, ...advanced];
  };

  applyAction(fn: ActionFn) {
    const [prefix, replacement, postfix] = fn(this.getSelection());
    this.replaceSelection(prefix, replacement, postfix);
  }

  emailLink = (selection: string) => {
    const address = prompt("Enter email address", "");
    const name = selection.length > 0 ? selection : address;
    return ['"', name, `":mailto:${address}`];
  };

  getSelection = (): string => {
    const { selectionStart, selectionEnd, value } = this.inputRef.current;
    return value.substr(selectionStart, selectionEnd - selectionStart);
  };

  handleChange = (evt: ChangeEvent<HTMLTextAreaElement>) => {
    this.updateValue(evt.target.value);
  };

  handleKeyPress = (evt: KeyboardEvent) => {
    let key: string;
    if (evt.which >= 65 && evt.which <= 90) {
      key = String.fromCharCode(evt.keyCode).toLowerCase();
    } else if (evt.keyCode === 13) {
      key = "enter";
    }

    const hotkeys: Record<string, ActionFn> = {};
    this.actions().forEach((a) => {
      if (a.hotkey) {
        hotkeys[a.hotkey] = a.fn;
      }
    });

    if ((evt.metaKey || evt.ctrlKey) && key in keys) {
      evt.preventDefault();
      this.applyAction(hotkeys[key]);
    }
  };

  link = (selection: string) => {
    const name = selection.length > 0 ? selection : "Link text";
    const url = prompt("Enter link URL", "");
    if (url) {
      return ['"', name, `":${this.relativeUrl(url)}`];
    } else {
      return ["", name, ""];
    }
  };

  localeOptions() {
    const opts = {};

    if (this.props.lang) {
      opts.lang = this.props.lang;
    }

    if (this.props.dir) {
      opts.dir = this.props.dir;
    }

    return opts;
  }

  relativeUrl(str: string): string {
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
      url.hostname == document.location.hostname &&
      (document.location.port || "80") == (url.port || "80")
    ) {
      return url.pathname;
    }
    return str;
  }

  render() {
    const { rows } = this.state;
    const { id, name } = this.props;
    const value = this.getValue();

    const clickHandler = (fn: ActionFn) => (evt: Event) => {
      evt.preventDefault();
      this.applyAction(fn);
    };

    return (
      <div className="rich-text-area">
        <div className="rich-text toolbar">
          {this.actions().map((a) => (
            <RichTextToolbarButton
              key={a.name}
              name={a.name}
              className={a.className}
              onClick={clickHandler(a.fn)}
            />
          ))}
        </div>
        <textarea
          className={this.props.className || "rich"}
          ref={this.inputRef}
          id={id}
          name={name}
          value={value}
          rows={rows}
          onChange={this.handleChange}
          onKeyDown={this.handleKeyPress}
          {...this.localeOptions()}
        />
      </div>
    );
  }

  replaceSelection = (prefix: string, replacement: string, postfix: string) => {
    const textarea = this.inputRef.current;
    const { selectionStart, selectionEnd, value } = textarea;

    textarea.value =
      value.substr(0, selectionStart) +
      prefix +
      replacement +
      postfix +
      value.substr(selectionEnd, value.length);

    textarea.focus({ preventScroll: true });
    textarea.setSelectionRange(
      selectionStart + prefix.length,
      selectionStart + prefix.length + replacement.length
    );
    this.updateValue(textarea.value);
  };

  strToList(str: string, prefix: string) {
    return str
      .split("\n")
      .map((l) => prefix + " " + l)
      .join("\n");
  }

  getValue() {
    if (this.props.onChange) {
      return this.props.value;
    } else {
      return this.state.value;
    }
  }

  updateValue(str: string) {
    if (this.props.onChange) {
      this.props.onChange(str);
    } else {
      this.setState({ value: str });
    }
  }
}
