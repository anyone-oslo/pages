class FileUploadButton extends React.Component {
  constructor(props) {
    super(props);
    this.inputRef = React.createRef();
    this.handleChange = this.handleChange.bind(this);
    this.triggerDialog = this.triggerDialog.bind(this);
  }

  handleChange(evt) {
    let fileList = evt.target.files;
    let files = [];
    for (var i = 0; i < fileList.length; i++) {
      files.push(fileList[i]);
    }
    if (files.length > 0) {
      this.props.callback(files);
    }
  }

  render() {
    return (
      <div className="upload-button">
        <span>
          Drag and drop {this.props.type || "file"}
          {this.props.multiple && "s"} here, or
          {this.props.multiline && <br />}
          <button onClick={this.triggerDialog}>
            choose a file
          </button>
        </span>
        <input type="file"
               onChange={this.handleChange}
               ref={this.inputRef}
               style={{ display: "none" }}
               multiple={this.props.multiple || false} />
      </div>
    );
  }

  triggerDialog(evt) {
    evt.preventDefault();
    this.inputRef.current.click();
  }
}
