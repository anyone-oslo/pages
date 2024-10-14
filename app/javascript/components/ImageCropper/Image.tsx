import ReactCrop from "react-image-crop";

import * as Crop from "../../types/Crop";

import { cropSize } from "./useCrop";
import useImageCropperContext from "./useImageCropperContext";
import FocalPoint from "./FocalPoint";

type Props = {
  containerSize: Crop.Size;
  croppedImage: string;
  focalPoint: Crop.Position;
};

export default function Image({
  containerSize,
  croppedImage,
  focalPoint
}: Props) {
  const { state, dispatch } = useImageCropperContext();

  const imageSize = () => {
    const { image, cropping, crop_width, crop_height } = state;
    if (cropping) {
      return { width: image.real_width, height: image.real_height };
    } else {
      return { width: crop_width, height: crop_height };
    }
  };

  const setCrop = (crop: Crop.CropSize) => {
    dispatch({ type: "setCrop", payload: crop });
  };

  const setFocal = (focal: Crop.Position) => {
    dispatch({ type: "setFocal", payload: focal });
  };

  const maxWidth = containerSize.width;
  const maxHeight = containerSize.height;
  const aspect = imageSize().width / imageSize().height;

  let width = maxWidth;
  let height = maxWidth / aspect;

  if (height > maxHeight) {
    height = maxHeight;
    width = maxHeight * aspect;
  }

  const style = { width: `${width}px`, height: `${height}px` };

  if (state.cropping) {
    return (
      <div className="image-wrapper" style={style}>
        <ReactCrop
          src={state.image.uncropped_url}
          crop={cropSize(state)}
          minWidth={10}
          minHeight={10}
          onChange={setCrop}
        />
      </div>
    );
  } else {
    return (
      <div className="image-wrapper" style={style}>
        {focalPoint && (
          <FocalPoint
            width={width}
            height={height}
            x={focalPoint.x}
            y={focalPoint.y}
            onChange={setFocal}
          />
        )}
        <img src={croppedImage} />
      </div>
    );
  }
}
