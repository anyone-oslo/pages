class RichTextArea extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: props.value || "",
      rows: props.rows || 5
    };
    this.inputRef = React.createRef();
    this.handleChange = this.handleChange.bind(this);
    this.handleKeyPress = this.handleKeyPress.bind(this);
    this.getSelection = this.getSelection.bind(this);
    this.link = this.link.bind(this);
    this.replaceSelection = this.replaceSelection.bind(this);
  }

  actions() {
    const simple = [
      {
        name:      "bold",
        className: "bold",
        hotkey:    "b",
        fn:        (str) => ["<b>", str, "</b>"]
      },
      { name:      "italic",
        className: "italic",
        hotkey:    "i",
        fn:        (str) => ["<i>", str, "</i>"]
      },
    ];

    const advanced = [
      {
        name:      "Heading 2",
        className: "header h2",
        fn:        (str) => ["h2. ", str, ""]
      },
      {
        name:      "Heading 3",
        className: "header h3",
        fn:        (str) => ["h3. ", str, ""]
      },
      {
        name:      "Heading 4",
        className: "header h4",
        fn:        (str) => ["h4. ", str, ""]
      },
      {
        name:      "Blockquote",
        className: "quote-left",
        fn:        (str) => ["bq. ", str, ""]
      },
      {
        name:      "List",
        className: "list-ul",
        fn:        (str) => ["", this.strToList(str, "*"), ""]
      },
      {
        name:      "Ordered list",
        className: "list-ol",
        fn:        (str) => ["", this.strToList(str, "#"), ""]
      },
      {
        name:      "Link",
        className: "link",
        fn:        this.link
      },
      {
        name:      "Email link",
        className: "envelope",
        fn:        this.emailLink
      },
    ];

    return this.props.simple ? simple : [...simple, ...advanced];
  }

  applyAction(fn) {
    let [prefix, replacement, postfix] = fn(this.getSelection());
    this.replaceSelection(prefix, replacement, postfix);
  }

  emailLink(selection) {
    var address = prompt("Enter email address", "");
    let name = selection.length > 0 ? selection : address;
    return ["\"", name, `":mailto:${address}`];
  }

  getSelection() {
    let { selectionStart, selectionEnd, value } = this.inputRef.current;
    return value.substr(selectionStart, (selectionEnd - selectionStart));
  }

  handleChange(evt) {
    this.setState({ value: evt.target.value });
  }

  handleKeyPress(evt) {
    let key;
    if (evt.which >= 65 && evt.which <= 90) {
      key = String.fromCharCode(evt.keyCode).toLowerCase();
    } else if (evt.keyCode === 13) {
      key = "enter";
    }

    let hotkeys = {};
    this.actions().forEach(a => {
      if (a.hotkey) {
        hotkeys[a.hotkey] = a.fn;
      }
    });

    if ((evt.metaKey || evt.ctrlKey) && Object.prototype.hasOwnProperty.call(hotkeys, key)) {
      evt.preventDefault();
      this.applyAction(hotkeys[key]);
    }
  }

  link(selection) {
    let name = selection.length > 0 ? selection : "Link text";
    var url = prompt("Enter link URL", "");
    if (url) {
      return ["\"", name, `":${this.relativeUrl(url)}`];
    } else {
      return ["", name, ""];
    }
  }

  relativeUrl(str) {
    let url = null;

    if (!str.match(/^https:\/\//) || !document || !document.location) {
      return str;
    }

    try {
      url = new URL(str);
    } catch (error) {
      console.log("Error parsing URL: ", error);
    }

    if (url &&
        url.hostname == document.location.hostname &&
        (document.location.port || "80") == (url.port || "80")) {
      return url.pathname;
    }
    return str;
  }

  render() {
    let { value, rows } = this.state;
    let { id, name, simple } = this.props;

    const clickHandler = (fn) => (evt) => {
      evt.preventDefault();
      this.applyAction(fn);
    };

    return (
      <div className="rich-text-area">
        <div className="rich-text toolbar">
          {this.actions().map(a =>
            <RichTextToolbarButton
              key={a.name}
              name={a.name}
              className={a.className}
              onClick={clickHandler(a.fn)} />)}
        </div>
        <textarea
          className="rich"
          ref={this.inputRef}
          id={id}
          name={name}
          value={value}
          rows={rows}
          onChange={this.handleChange}
          onKeyDown={this.handleKeyPress} />
      </div>
    );
  }

  replaceSelection(prefix, replacement, postfix) {
    let textarea = this.inputRef.current;
    let { selectionStart, selectionEnd, value } = textarea;

    textarea.value =
      value.substr(0, selectionStart) +
      prefix + replacement + postfix +
      value.substr(selectionEnd, value.length);

    textarea.focus({ preventScroll: true });
    textarea.setSelectionRange(
      selectionStart + prefix.length,
      selectionStart + prefix.length + replacement.length
    );
    this.setState({ value: textarea.value });
  }

  strToList(str, prefix) {
    return str.split("\n").map(l => prefix +  " " + l).join("\n");
  }
}
