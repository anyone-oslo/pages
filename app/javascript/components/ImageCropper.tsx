import * as Crop from "../types/Crop";
import Image from "./ImageCropper/Image";
import Toolbar from "./ImageCropper/Toolbar";
import { ImageCropperContext } from "./ImageCropper/useImageCropperContext";
import useContainerSize from "./ImageCropper/useContainerSize";

export { default as useCrop, cropParams } from "./ImageCropper/useCrop";

type Props = {
  croppedImage: string;
  cropState: Crop.State;
  dispatch: React.Dispatch<Crop.Action>;
};

function focalPoint(state: Crop.State): Crop.Position {
  if (state.crop_gravity_x === null || state.crop_gravity_y === null) {
    return null;
  } else {
    return {
      x: ((state.crop_gravity_x - state.crop_start_x) / state.crop_width) * 100,
      y: ((state.crop_gravity_y - state.crop_start_y) / state.crop_height) * 100
    };
  }
}

export default function ImageCropper({
  croppedImage,
  cropState,
  dispatch
}: Props) {
  const [containerRef, containerSize] = useContainerSize();

  return (
    <ImageCropperContext.Provider
      value={{
        state: cropState,
        dispatch: dispatch
      }}>
      <div className="visual">
        <Toolbar />
        <div className="image-container" ref={containerRef}>
          {!croppedImage && (
            <div className="loading">Loading image&hellip;</div>
          )}
          {croppedImage && containerSize && (
            <Image
              containerSize={containerSize}
              croppedImage={croppedImage}
              focalPoint={focalPoint(cropState)}
            />
          )}
        </div>
      </div>
    </ImageCropperContext.Provider>
  );
}
