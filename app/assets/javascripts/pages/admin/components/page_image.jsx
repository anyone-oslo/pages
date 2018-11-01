class PageImage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      src: (props.pageImage.src || null)
    };
    this.copyEmbed = this.copyEmbed.bind(this);
    this.deleteImage = this.deleteImage.bind(this);
    this.dragStart = this.dragStart.bind(this);
  }

  componentDidMount() {
    let file = this.props.pageImage.file;
    if (file) {
      this.reader = new FileReader();
      this.reader.onload = () => this.setState({src: this.reader.result });
      this.reader.readAsDataURL(this.props.pageImage.file);
    }
  }

  copyEmbed(evt) {
    let image = this.props.pageImage.image;
    evt.preventDefault();
    const el = document.createElement("textarea");
    el.value = `[image:${image.id}]`;
    document.body.appendChild(el);
    el.select();
    document.execCommand("copy");
    document.body.removeChild(el);
  }

  deleteImage(evt) {
    evt.preventDefault();
    if (this.props.deleteImage) {
      this.props.deleteImage(this.props.pageImage);
    }
  }

  dragStart(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    if (this.props.startDrag) {
      this.props.startDrag(evt, this.props.pageImage);
    }
  }

  renderImage() {
    let image = this.props.pageImage.image;
    return(
      <EditableImage image={image}
                     src={this.state.src || image.thumbnail_url}
                     width={250}
                     caption={true}
                     locale={this.props.locale}
                     locales={this.props.locales}
                     csrf_token={this.props.csrf_token}
                     onUpdate={this.props.onUpdate} />
    )
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
    let index = this.props.index;
    let pageImage = this.props.pageImage;
    let image = pageImage.image;
    let classes = ["page-image"];
    if (this.props.placeholder) {
      classes.push("placeholder");
    }
    if (this.props.pageImage.file) {
      classes.push("uploading");
    }
    return (
      <div className={classes.join(" ")}
           onDragStart={this.dragStart}
           ref={this.props.pageImage.ref}>
        <input name={`page[page_images_attributes][${index}][id]`}
               type="hidden" value={pageImage.id || ""} />
        <input name={`page[page_images_attributes][${index}][image_id]`}
               type="hidden" value={(image && image.id) || ""} />
        <input name={`page[page_images_attributes][${index}][position]`}
               type="hidden" value={index + 1} />
        <input name={`page[page_images_attributes][${index}][primary]`}
               type="hidden" value={this.props.primary} />
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
