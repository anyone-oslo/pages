class GridImage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      src: (props.record.src || null)
    };
    this.copyEmbed = this.copyEmbed.bind(this);
    this.deleteImage = this.deleteImage.bind(this);
    this.dragStart = this.dragStart.bind(this);
  }

  componentDidMount() {
    let file = this.props.record.file;
    if (file) {
      this.reader = new FileReader();
      this.reader.onload = () => this.setState({src: this.reader.result });
      this.reader.readAsDataURL(this.props.record.file);
    }
  }

  copyEmbed(evt) {
    let image = this.props.record.image;
    evt.preventDefault();
    const el = document.createElement("textarea");
    el.value = `[image:${image.id}]`;
    document.body.appendChild(el);
    el.select();
    document.execCommand("copy");
    document.body.removeChild(el);
    ToastStore.dispatch({
      type: "NOTICE", message: "Embed code copied to clipboard"
    });
  }

  deleteImage(evt) {
    evt.preventDefault();
    if (this.props.deleteImage) {
      this.props.deleteImage(this.props.record);
    }
  }

  dragStart(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    if (this.props.startDrag) {
      this.props.startDrag(evt, this.props.record);
    }
  }

  renderImage() {
    let image = this.props.record.image;
    return(
      <EditableImage image={image}
                     src={this.state.src || image.thumbnail_url}
                     width={250}
                     caption={true}
                     locale={this.props.locale}
                     locales={this.props.locales}
                     csrf_token={this.props.csrf_token}
                     onUpdate={this.props.onUpdate} />
    );
  }

  renderPlaceholder() {
    let src = this.state.src;
    if (src) {
      return (
        <div className="temp-image">
          <img src={src} />
          <span>Uploading...</span>
        </div>
      );
    } else {
      return (
        <div className="file-placeholder">
          <span>Uploading...</span>
        </div>
      );
    }
  }

  render() {
    let attributeName = this.props.attributeName;
    let record = this.props.record;
    let image = record.image;
    let classes = ["grid-image"];
    if (this.props.placeholder) {
      classes.push("placeholder");
    }
    if (this.props.record.file) {
      classes.push("uploading");
    }
    return (
      <div className={classes.join(" ")}
           onDragStart={this.dragStart}
           ref={this.props.record.ref}>
        <input name={`${attributeName}[id]`}
               type="hidden" value={record.id || ""} />
        <input name={`${attributeName}[image_id]`}
               type="hidden" value={(image && image.id) || ""} />
        <input name={`${attributeName}[position]`}
               type="hidden" value={this.props.position} />
        {this.props.enablePrimary && (
           <input name={`${attributeName}[primary]`}
                  type="hidden" value={this.props.primary} />
        )}
        {!image && this.renderPlaceholder()}
        {image && this.renderImage()}
        {image && (
           <div className="actions">
             {this.props.showEmbed && (
                <button onClick={this.copyEmbed}>
                  Embed
                </button>
             )}
             {this.props.deleteImage && (
                <button onClick={this.deleteImage}>
                  Remove
                </button>
             )}
           </div>
        )}
      </div>
    );
  }
}
