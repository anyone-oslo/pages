class ImageEditor extends React.Component {
  constructor(props) {
    super(props);
    let image = props.image;
    this.state = {
      caption: image.caption,
      alternative: image.alternative,
      width: image.real_width,
      height: image.real_height,
      cropping: false,
      crop: {
        x: ((image.crop_start_x || 0) / image.real_width) * 100,
        y: ((image.crop_start_y || 0) / image.real_height) * 100,
        width: ((image.crop_width || image.real_width) / image.real_width) * 100,
        height: ((image.crop_height || image.real_height) / image.real_height) * 100
      },
      croppedImage: null
    };

    this.aspectRatios = [
      ["Free", null], ["1:1", 1],    ["3:2", 3/2], ["2:3", 2/3],
      ["4:3", 4/3],   ["3:4", 3/4],  ["5:4", 5/4], ["4:5", 4/5],
      ["16:9", 16/9], ["9:16", 9/16]
    ];

    this.imageContainer = React.createRef();
    this.handleResize = this.handleResize.bind(this);
    this.completeCrop = this.completeCrop.bind(this);
  }

  componentWillMount() {
  }

  componentDidMount() {
    let component = this;
    this.img = new Image;
    this.img.onload = function() {
      component.setState({ croppedImage: component.getCroppedImage() });
    }
    this.img.src = this.props.image.uncropped_url;
    window.addEventListener("resize", this.handleResize);
    this.handleResize();
  }

  componentWillUnmount() {
    window.removeEventListener("resize", this.handleResize);
  }

  handleResize() {
    let elem = this.imageContainer.current;
    this.setState({
      containerSize: { width: elem.offsetWidth, height: elem.offsetHeight }
    });
  }

  completeCrop() {
    this.setState({ cropping: false,
                    croppedImage: this.getCroppedImage() });
  }

  imageSize() {
    let image = this.props.image;
    let crop = this.cropSize();
    if (this.state.cropping) {
      return { width: image.real_width, height: image.real_height };
    } else {
      return { width: (image.real_width * (crop.width / 100)),
               height: (image.real_height * (crop.height / 100)) };
    }
  }

  renderImage() {
    if (!this.state.croppedImage || !this.state.containerSize) {
      return;
    }
    let image = this.props.image;
    let maxWidth = this.state.containerSize.width;
    let maxHeight = this.state.containerSize.height;
    let aspect = this.imageSize().width / this.imageSize().height;

    var width = maxWidth;
    var height = maxWidth / aspect;

    if (height > maxHeight) {
      height = maxHeight;
      width = maxHeight * aspect;
    }

    let style = { width: `${width}px`, height: `${height}px` };

    if (this.state.cropping) {
      return (
        <div className="image-wrapper" style={style}>
          <ReactCrop src={image.uncropped_url}
                     crop={this.state.crop}
                     minWidth="10"
                     minHeight="10"
                     onChange={crop => this.setState({ crop: crop })} />
        </div>
      );
    } else {
      return (
        <div className="image-wrapper" style={style}>
          <img src={this.state.croppedImage} />
        </div>
      );
    }
  }

  setAspect(aspect) {
    this.state.crop.aspect = aspect;
    let crop = this.cropSize();
    let image = this.props.image;
    let imageAspect = image.real_width / image.real_height;

    // Maximize and center crop area
    if (aspect) {
      crop.aspect = aspect;
      crop.width = 100;
      crop.height = (100 / aspect) * imageAspect;

      if (crop.height > 100) {
        crop.height = 100;
        crop.width = (100 * aspect) / imageAspect;
      }

      crop.x = (100 - crop.width) / 2;
      crop.y = (100 - crop.height) / 2;
    }

    this.setState({crop: crop});
  }

  renderToolbar() {
    let component = this;
    let updateAspect = function (evt, aspect) {
      evt.preventDefault();
      component.setAspect(aspect);
    }

    if (!this.state.cropping) {
      return (
        <div className="toolbar">
          <button onClick={() => this.setState({ cropping: true })}>
            Crop
          </button>
        </div>
      );
    } else {
      return (
        <div className="toolbar">
          <button onClick={this.completeCrop}>Done</button>
          Aspect ratio:
          {this.aspectRatios.map(ratio => (
            <a key={"ratio-" + ratio[1]}
               href="#"
               className={ratio[1] == this.state.crop.aspect ? "current" : ""}
               onClick={evt => updateAspect(evt, ratio[1])}>
              {ratio[0]}
            </a>
          ))}
        </div>
      );
    }
  }

  render() {
    return (
      <div className="image-editor">
        {this.renderToolbar()}
        <div className="image-container" ref={this.imageContainer}>
          {!this.state.croppedImage && (
             <div className="loading">
               Loading image&hellip;
             </div>
          )}
          {this.renderImage()}
        </div>
        {!this.state.cropping && (
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
        )}
      </div>
    );
  }

  cropSize() {
    let image = this.props.image;
    let imageAspect = image.real_width / image.real_height;

    var { x, y, width, height, aspect } = this.state.crop;

    if (aspect && width) {
      height = (width / aspect) * imageAspect;
    } else if (aspect && height) {
      width = (height * aspect) / imageAspect;
    }

    // Don't crop if dimensions are below the threshold
    if (width < 5 || height < 5) {
      return { x: 0, y: 0, width: 100, height: 100 };
    } else {
      return { x: x, y: y, width: width, height: height };
    }

  }

  getCroppedImage() {
    let crop = this.cropSize();
    let img = this.img;
    let canvas = document.createElement("canvas");
    canvas.width = (img.naturalWidth * (crop.width / 100));
    canvas.height = (img.naturalHeight * (crop.height / 100));
    let ctx = canvas.getContext("2d");
    ctx.drawImage(
      img,
      (img.naturalWidth * (crop.x / 100)),
      (img.naturalHeight * (crop.y / 100)),
      (img.naturalWidth * (crop.width / 100)),
      (img.naturalHeight * (crop.height / 100)),
      0,
      0,
      (img.naturalWidth * (crop.width / 100)),
      (img.naturalHeight * (crop.height / 100))
    );
    return canvas.toDataURL("image/jpeg");
  }
}
