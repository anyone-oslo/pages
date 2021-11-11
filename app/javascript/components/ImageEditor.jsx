import React from "react";
import PropTypes from "prop-types";
import ReactCrop from "react-image-crop";
import ModalStore from "./ModalStore";
import { putJson } from "../lib/request";

import FocalPoint from "./ImageEditor/FocalPoint";
import Form from "./ImageEditor/Form";
import Toolbar from "./ImageEditor/Toolbar";

export default class ImageEditor extends React.Component {
  constructor(props) {
    super(props);
    let image = props.image;

    this.state = {
      locale:         this.props.locale,
      caption:        image.caption || {},
      alternative:    image.alternative || {},
      aspect:         null,
      cropping:       false,
      crop_start_x:   image.crop_start_x || 0,
      crop_start_y:   image.crop_start_y || 0,
      crop_width:     image.crop_width || image.real_width,
      crop_height:    image.crop_height || image.real_height,
      crop_gravity_x: image.crop_gravity_x,
      crop_gravity_y: image.crop_gravity_y,
      croppedImage:   null
    };

    this.imageContainer = React.createRef();
    this.copyEmbedCode = this.copyEmbedCode.bind(this);
    this.handleResize = this.handleResize.bind(this);
    this.completeCrop = this.completeCrop.bind(this);
    this.setCrop = this.setCrop.bind(this);
    this.setFocal = this.setFocal.bind(this);
    this.toggleCrop = this.toggleCrop.bind(this);
    this.toggleFocal = this.toggleFocal.bind(this);
    this.save = this.save.bind(this);
    this.updateLocalized = this.updateLocalized.bind(this);
  }

  componentDidMount() {
    let component = this;
    this.img = new Image;
    this.img.onload = function() {
      component.setState({ croppedImage: component.getCroppedImage() });
    };
    this.img.src = this.props.image.uncropped_url;
    window.addEventListener("resize", this.handleResize);
    this.handleResize();
  }

  componentDidUpdate() {
    let size = this.containerSize();
    if (size.width != this.state.containerSize.width ||
        size.height != this.state.containerSize.height) {
      this.handleResize();
    }
  }

  componentWillUnmount() {
    window.removeEventListener("resize", this.handleResize);
  }

  containerSize() {
    let elem = this.imageContainer.current;
    return { width: elem.offsetWidth - 2, height: elem.offsetHeight - 2 };
  }

  handleResize() {
    this.setState({containerSize: this.containerSize()});
  }

  completeCrop() {
    let { crop_start_x,
          crop_start_y,
          crop_width,
          crop_height,
          crop_gravity_x,
          crop_gravity_y } = this.state;

    // Disable focal point if it's out of bounds.
    if (crop_gravity_x < crop_start_x ||
        crop_gravity_x > (crop_start_x + crop_width) ||
        crop_gravity_y < crop_start_y ||
        crop_gravity_y > (crop_start_y + crop_height)) {
      crop_gravity_x = null;
      crop_gravity_y = null;
    }

    this.setState({crop_gravity_x: crop_gravity_x,
                   crop_gravity_y: crop_gravity_y,
                   cropping: false,
                   croppedImage: this.getCroppedImage()});
  }

  imageSize() {
    let image = this.props.image;
    let { crop_width, crop_height } = this.state;
    if (this.state.cropping) {
      return { width: image.real_width, height: image.real_height };
    } else {
      return { width: crop_width, height: crop_height };
    }
  }

  renderImage() {
    if (!this.state.croppedImage || !this.state.containerSize) {
      return "";
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
                     minWidth={10}
                     minHeight={10}
                     onChange={this.setCrop} />
        </div>
      );
    } else {
      let focal = this.getFocal();
      return (
        <div className="image-wrapper" style={style}>
          {focal && (
             <FocalPoint width={width} height={height}
                         x={focal.x} y={focal.y}
                         onChange={this.setFocal} />
          )}
          <img src={this.state.croppedImage} />
        </div>
      );
    }
  }

  setCrop(crop) {
    let image = this.props.image;

    // Don't crop if dimensions are below the threshold
    if (crop.width < 5 || crop.height < 5) {
      crop = { x: 0, y: 0, width: 100, height: 100 };
    }

    if (crop.aspect === null) {
      delete crop.aspect;
    }

    this.setState({crop:         crop,
                   aspect:       crop.aspect,
                   crop_start_x: image.real_width * (crop.x / 100),
                   crop_start_y: image.real_height * (crop.y / 100),
                   crop_width:   image.real_width * (crop.width / 100),
                   crop_height:  image.real_height * (crop.height / 100)});
  }

  getFocal() {
    var x, y;
    let { crop_gravity_x,
          crop_gravity_y,
          crop_start_x,
          crop_start_y,
          crop_width,
          crop_height } = this.state;

    if (crop_gravity_x === null || crop_gravity_y === null) {
      return null;
    } else {
      x = ((crop_gravity_x - crop_start_x) / crop_width) * 100;
      y = ((crop_gravity_y - crop_start_y) / crop_height) * 100;
      return { x: x, y: y };
    }
  }

  toggleCrop() {
    if (this.state.cropping) {
      this.completeCrop();
    } else {
      this.setState({cropping: true, crop: this.cropSize()});
    }
  }

  toggleFocal() {
    if (this.state.crop_gravity_x === null) {
      this.setFocal({x: 50, y: 50});
    } else {
      this.setState({crop_gravity_x: null, crop_gravity_y: null});
    }
  }

  setFocal(focal) {
    let {
      crop_start_x,
      crop_start_y,
      crop_width,
      crop_height
    } = this.state;
    this.setState({crop_gravity_x: (crop_width * (focal.x / 100)) + crop_start_x,
                   crop_gravity_y: (crop_height * (focal.y / 100)) + crop_start_y});
  }

  setAspect(aspect) {
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
    } else {
      delete crop.aspect;
    }
    this.setCrop(crop);
  }

  updateLocalized(name, value) {
    let locale = this.state.locale;
    this.setState({
      [name]: { ...this.state[name], [locale]: value }
    });
  }

  render() {
    return (
      <div className="image-editor">
        <div className="visual">
          <Toolbar cropState={this.state}
                   cropping={this.state.cropping}
                   image={this.props.image}
                   setAspect={this.setAspect}
                   toggleCrop={this.toggleCrop}
                   toggleFocal={this.toggleFocal} />
          <div className="image-container" ref={this.imageContainer}>
            {!this.state.croppedImage && (
               <div className="loading">
                 Loading image&hellip;
               </div>
            )}
            {this.renderImage()}
          </div>
        </div>
        {!this.state.cropping &&
         <Form alternative={this.state.alternative}
               caption={this.state.caption}
               image={this.props.image}
               locale={this.state.locale}
               locales={this.props.locales}
               setLocale={(l) => this.setState({ locale: l })}
               save={this.save}
               showCaption={this.props.caption}
               updateLocalized={this.updateLocalized} />}
      </div>
    );
  }

  save(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    let maybe = (func) => (val) => (val === null) ? val : func(val);
    let maybeRound = maybe(Math.round);
    let maybeCeil = maybe(Math.ceil);

    let data = { alternative:    this.state.alternative,
                 caption:        this.state.caption,
                 crop_start_x:   maybeRound(this.state.crop_start_x),
                 crop_start_y:   maybeRound(this.state.crop_start_y),
                 crop_width:     maybeCeil(this.state.crop_width),
                 crop_height:    maybeCeil(this.state.crop_height),
                 crop_gravity_x: maybeRound(this.state.crop_gravity_x),
                 crop_gravity_y: maybeRound(this.state.crop_gravity_y) };

    putJson(`/admin/images/${this.props.image.id}`, { image: data });

    if (this.props.onUpdate) {
      this.props.onUpdate(data, this.state.croppedImage);
    }
    ModalStore.dispatch({ type: "CLOSE" });
  }

  cropSize() {
    let image = this.props.image;
    let imageAspect = image.real_width / image.real_height;
    let { aspect,
          crop_start_x,
          crop_start_y,
          crop_width,
          crop_height } = this.state;
    let x = (crop_start_x / image.real_width) * 100;
    let y = (crop_start_y / image.real_height) * 100;
    var width = (crop_width / image.real_width) * 100;
    var height = (crop_height / image.real_height) * 100;

    if (aspect && width) {
      height = (width / aspect) * imageAspect;
    } else if (aspect && height) {
      width = (height * aspect) / imageAspect;
    }

    if (aspect === null) {
      return { x: x, y: y, width: width, height: height };
    } else {
      return { x: x, y: y, width: width, height: height, aspect: aspect };
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

    return this.imageDataUrl(canvas, ctx);
  }

  imageDataUrl(canvas, ctx) {
    let pixels = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
    for (var i = 0; i < (pixels.length / 4); i++) {
      if (pixels[(i * 4) + 3] !== 255) {
        return canvas.toDataURL("image/png");
      }
    }

    return canvas.toDataURL("image/jpeg");
  }
}

ImageEditor.propTypes = {
  image: PropTypes.object,
  locale: PropTypes.string,
  locales: PropTypes.object,
  caption: PropTypes.bool,
  onUpdate: PropTypes.func
};
