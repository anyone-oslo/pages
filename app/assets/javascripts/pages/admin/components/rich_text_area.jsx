class RichTextArea extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: props.value,
      rows: props.rows || 5
    };
    this.inputRef = React.createRef();
    this.handleChange = this.handleChange.bind(this);
    this.getSelection = this.getSelection.bind(this);
    this.replaceSelection = this.replaceSelection.bind(this);
  }

  getSelection() {
    let { selectionStart,
          selectionEnd,
          value } = this.inputRef.current;
    return value.substr(selectionStart, (selectionEnd - selectionStart));
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
    this.setValue(textarea.value);
  };

  handleChange(evt) {
    this.setValue(evt.target.value);
  }

  render() {
    let { value, rows } = this.state;
    let { id, name } = this.props;
    return (
      <div className="rich-text-area">
        <RichTextToolbar getSelection={this.getSelection}
                         replaceSelection={this.replaceSelection} />
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
