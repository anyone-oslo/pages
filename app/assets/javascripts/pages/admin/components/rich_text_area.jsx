class RichTextArea extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: props.value,
      rows: props.rows || 5
    };
    this.inputRef = React.createRef();
    this.handleChange = this.handleChange.bind(this);
    this.list = this.list.bind(this);
    this.orderedList = this.orderedList.bind(this);
  }

  adjustSelection(callback) {
    let length = this.getSelection().length;
    let [start, end] = this.getSelectionRange();
    let [replacementLength, prefixLength] = callback();
    let newEnd = (end + (replacementLength - length) + prefixLength);
    let newStart = start === end ? newEnd : (start + prefixLength);
    this.setSelectionRange(newStart, newEnd);
  };

  getSelection() {
    return $(this.inputRef.current).getSelection().text;
  }

  getSelectionRange() {
    if (typeof this.inputRef.current.selectionStart !== "undefined") {
      return [this.inputRef.current.selectionStart, this.inputRef.current.selectionEnd];
    } else {
      return [0, 0];
    }
  };

  replaceSelection(prefix, replacement, postfix) {
    this.adjustSelection(() => {
      $(this.inputRef.current).replaceSelection(prefix + replacement + postfix);
      if (typeof this.inputRef.current.focus !== "undefined") {
        this.inputRef.current.focus({ preventScroll: true });
      }
      return [replacement.length, prefix.length];
    });
    this.setValue(this.inputRef.current.value);
  };

  // Sets a new selection range for object
  setSelectionRange(start, end) {
    if (typeof this.inputRef.current.setSelectionRange !== "undefined") {
      this.inputRef.current.setSelectionRange(start, end);
    }
  };

  blockquote(str) { return ["bq. ", str, ""]; }
  bold(str)       { return ["<b>", str, "</b>"]; }
  emphasis(str)   { return ["<i>", str, "</i>"]; }
  h1(str)         { return ["h1. ", str, ""]; }
  h2(str)         { return ["h2. ", str, ""]; }
  h3(str)         { return ["h3. ", str, ""]; }
  h4(str)         { return ["h4. ", str, ""]; }
  h5(str)         { return ["h5. ", str, ""]; }
  h6(str)         { return ["h6. ", str, ""]; }

  link(selection) {
    let name = selection.length > 0 ? selection : "Link text";
    var url = prompt("Enter link URL", "");
    url = url.length > 0 ? url : "http://example.com/";
    url = url.replace(/^(?!(f|ht)tps?:\/\/)/, 'http://');
    return ["\"", name, `\":${url}`];
  }

  emailLink(selection) {
    var address = prompt("Enter email address", "");
    let name = selection.length > 0 ? selection : address;
    return ["\"", name, `\":mailto:${address}`];
  }

  strToList(str, prefix) {
    return str.split("\n").map(l => prefix +  " " + l).join("\n");
  }

  list(str) {
    return ["", this.strToList(str, "*"), ""];
  }

  orderedList(str) {
    return ["", this.strToList(str, "#"), ""];
  }

  button(name, className, handler) {
    let clickHandler = (evt) => {
      evt.preventDefault();
      let [prefix, replacement, postfix] = handler(this.getSelection());
      this.replaceSelection(prefix, replacement, postfix);
    };

    return (
      <a title={name}
         className={"button " + className}
         onClick={clickHandler}>
        <i className={"fa fa-" + className} />
      </a>
    );
  };

  handleChange(evt) {
    this.setValue(evt.target.value);
  }

  render() {
    let { value, rows } = this.state;
    let { id, name } = this.props;
    return (
      <div className="rich-text-area">
        <div className="rich-text toolbar">
          {this.button("Bold", "bold", this.bold)}
          {this.button("Italics", "italic", this.emphasis)}
          {this.button("Heading 2", "header h2", this.h2)}
          {this.button("Heading 3", "header h3", this.h3)}
          {this.button("Heading 4", "header h4", this.h4)}
          {this.button("Blockquote", "quote-left", this.blockquote)}
          {this.button("List", "list-ul", this.list)}
          {this.button("Ordered list", "list-ol", this.orderedList)}
          {this.button("Link", "link", this.link)}
          {this.button("Email link", "envelope", this.emailLink)}
        </div>
        <textarea className="rich"
                  ref={this.inputRef}
                  id={id}
                  name={name}
                  value={value}
                  rows={rows}
                  onChange={this.handleChange} />
      </div>
    );
  }

  setValue(value) {
    this.setState({ value: value });
  }
}
