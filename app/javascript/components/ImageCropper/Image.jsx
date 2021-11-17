import React from "react";
import PropTypes from "prop-types";
import ReactCrop from "react-image-crop";

import { cropSize } from "./useCrop";
import FocalPoint from "./FocalPoint";

export default function Image(props) {
  const imageSize = () => {
    const { image, cropping, crop_width, crop_height } = props.cropState;
    if (cropping) {
      return { width: image.real_width, height: image.real_height };
    } else {
      return { width: crop_width, height: crop_height };
    }
  };

  const maxWidth = props.containerSize.width;
  const maxHeight = props.containerSize.height;
  const aspect = imageSize().width / imageSize().height;

  var width = maxWidth;
  var height = maxWidth / aspect;

  if (height > maxHeight) {
    height = maxHeight;
    width = maxHeight * aspect;
  }

  const style = { width: `${width}px`, height: `${height}px` };

  if (props.cropState.cropping) {
    return (
      <div className="image-wrapper" style={style}>
        <ReactCrop src={props.cropState.image.uncropped_url}
                   crop={cropSize(props.cropState)}
                   minWidth={10}
                   minHeight={10}
                   onChange={props.setCrop} />
      </div>
    );
  } else {
    return (
      <div className="image-wrapper" style={style}>
        {props.focalPoint && (
          <FocalPoint width={width} height={height}
                      x={props.focalPoint.x}
                      y={props.focalPoint.y}
                      onChange={props.setFocal} />
        )}
        <img src={props.croppedImage} />
      </div>
    );
  }

}

Image.propTypes = {
  containerSize: PropTypes.object,
  croppedImage: PropTypes.string,
  cropState: PropTypes.object,
  focalPoint: PropTypes.object,
  setCrop: PropTypes.func,
  setFocal: PropTypes.func
};
