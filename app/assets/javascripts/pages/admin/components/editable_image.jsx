class EditableImage extends React.Component {
  constructor(props) {
    let image = props.image;
    super(props);
    this.state = {
      image:  image,
      src:    props.src,
      width:  image.crop_width || image.real_width,
      height: image.crop_height || image.real_height
    };
    this.openEditor = this.openEditor.bind(this);
    this.update = this.update.bind(this);
  }

  openEditor() {
    ModalActions.open(
      <ImageEditor image={this.state.image}
                   caption={this.props.caption}
                   locale={this.props.locale}
                   locales={this.props.locales}
                   onUpdate={this.update} />);
  }

  height() {
    let image = this.state.image;
    let width = image.crop_width || image.real_width;
    let height = image.crop_height || image.real_height;
    return (height / width) * this.props.width;
  }

  update(image, croppedImage) {
    this.setState({image: mergeObject(this.state.image, image),
                   src: croppedImage});
  }

  render() {
    return (
      <img className="editable-image"
           src={this.state.src}
           width={this.props.width}
           height={this.height()}
           onClick={this.openEditor} />
    );
  }
}
