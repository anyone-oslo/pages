class ImageEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      caption: this.props.image.caption,
      alternative: this.props.image.alternative,
      width: this.props.image.real_width,
      height: this.props.image.real_height
    };
    this.imageContainer = React.createRef();
    this.handleResize = this.handleResize.bind(this);
  }

  componentDidMount() {
    this.handleResize();
    window.addEventListener("resize", this.handleResize);
  }

  componentWillUnmount() {
    window.removeEventListener("resize", this.handleResize);
  }

  handleResize() {
    this.setState({
      containerSize: { width: this.imageContainer.current.offsetWidth,
                       height: this.imageContainer.current.offsetHeight }
    });
  }

  renderImage() {
    let image = this.props.image;
    let maxWidth = this.state.containerSize.width;
    let maxHeight = this.state.containerSize.height;
    let aspect = this.state.width / this.state.height;

    var width = maxWidth;
    var height = maxWidth / aspect;

    if (height > maxHeight) {
      height = maxHeight;
      width = maxHeight * aspect;
    }

    let style = { width: `${width}px`, height: `${height}px` };

    return (
      <div className="image-wrapper" style={style}>
        <img src={image.uncropped_url} />
      </div>
    );
  }

  render() {
    let image = this.props.image;
    return (
      <div className="image-editor">
        <div className="image-container" ref={this.imageContainer}>
          {this.state.containerSize && this.renderImage()}
        </div>
        <form>
          <div className="field">
            <label>
              Caption
            </label>
            <input type="text"
                   value={this.state.caption}
                   onChange={e => this.setState({caption: e.target.value})} />
          </div>
          <div className="field">
            <label>
              Alternative text
            </label>
            <input type="text"
                   value={this.state.alternative}
                   onChange={e => this.setState({alternative: e.target.value})} />
          </div>
        </form>
      </div>
    );
  }
}
