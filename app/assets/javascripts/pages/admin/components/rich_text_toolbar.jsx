class RichTextToolbar extends React.Component {
  constructor(props) {
    super(props);
  }

  link(selection) {
    let name = selection.length > 0 ? selection : "Link text";
    var url = prompt("Enter link URL", "");
    if (url) {
      return ["\"", name, `":${url}`];
    } else {
      return ["", name, ""];
    }
  }

  emailLink(selection) {
    var address = prompt("Enter email address", "");
    let name = selection.length > 0 ? selection : address;
    return ["\"", name, `":mailto:${address}`];
  }

  strToList(str, prefix) {
    return str.split("\n").map(l => prefix +  " " + l).join("\n");
  }

  button(name, className, handler) {
    let clickHandler = (evt) => {
      evt.preventDefault();
      let [prefix, replacement, postfix] = handler(this.props.getSelection());
      this.props.replaceSelection(prefix, replacement, postfix);
    };

    return (
      <a title={name}
         className={"button " + className}
         onClick={clickHandler}>
        <i className={"fa fa-" + className} />
      </a>
    );
  }

  render() {
    if (this.props.simple) {
      return (
        <div className="rich-text toolbar">
          {this.button("Bold", "bold", (str) => ["<b>", str, "</b>"])}
          {this.button("Italics", "italic", (str) => ["<i>", str, "</i>"])}
        </div>
      );
    } else {
      return (
        <div className="rich-text toolbar">
          {this.button("Bold", "bold", (str) => ["<b>", str, "</b>"])}
          {this.button("Italics", "italic", (str) => ["<i>", str, "</i>"])}
          {this.button("Heading 2", "header h2", (str) => ["h2. ", str, ""])}
          {this.button("Heading 3", "header h3", (str) => ["h3. ", str, ""])}
          {this.button("Heading 4", "header h4", (str) => ["h4. ", str, ""])}
          {this.button("Blockquote", "quote-left", (str) => ["bq. ", str, ""])}
          {this.button("List", "list-ul",
                       (str) => ["", this.strToList(str, "*"), ""])}
          {this.button("Ordered list", "list-ol",
                       (str) => ["", this.strToList(str, "#"), ""])}
          {this.button("Link", "link", this.link)}
          {this.button("Email link", "envelope", this.emailLink)}
        </div>
      );
    }
  }
}
