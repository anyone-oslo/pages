import ReactCrop from "react-image-crop";

import * as Crop from "../../types/Crop";

import { cropSize } from "./useCrop";
import FocalPoint from "./FocalPoint";

type Props = {
  containerSize: Crop.Size;
  croppedImage: string;
  cropState: Crop.State;
  focalPoint: Crop.Position;
  setCrop: (crop: Crop.CropSize) => void;
  setFocal: (focal: Crop.Position) => void;
}

export default function Image(props: Props) {
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

  let width = maxWidth;
  let height = maxWidth / aspect;

  if (height > maxHeight) {
    height = maxHeight;
    width = maxHeight * aspect;
  }

  const style = { width: `${width}px`, height: `${height}px` };

  if (props.cropState.cropping) {
    return (
      <div className="image-wrapper" style={style}>
        <ReactCrop
          src={props.cropState.image.uncropped_url}
          crop={cropSize(props.cropState)}
          minWidth={10}
          minHeight={10}
          onChange={props.setCrop}
        />
      </div>
    );
  } else {
    return (
      <div className="image-wrapper" style={style}>
        {props.focalPoint && (
          <FocalPoint
            width={width}
            height={height}
            x={props.focalPoint.x}
            y={props.focalPoint.y}
            onChange={props.setFocal}
          />
        )}
        <img src={props.croppedImage} />
      </div>
    );
  }
}
