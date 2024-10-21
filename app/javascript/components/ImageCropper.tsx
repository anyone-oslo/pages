import * as Crop from "../types/Crop";
import Image from "./ImageCropper/Image";
import Toolbar from "./ImageCropper/Toolbar";
import { ImageCropperContext } from "./ImageCropper/useImageCropperContext";
import useContainerSize from "./ImageCropper/useContainerSize";

export { default as useCrop, cropParams } from "./ImageCropper/useCrop";

type Props = {
  croppedImage: string;
  state: Crop.State;
  dispatch: React.Dispatch<Crop.Action>;
};

export default function ImageCropper({ croppedImage, state, dispatch }: Props) {
  const [containerRef, containerSize] = useContainerSize();

  return (
    <ImageCropperContext.Provider
      value={{
        state: state,
        dispatch: dispatch
      }}>
      <div className="visual">
        <Toolbar />
        <div className="image-container" ref={containerRef}>
          {!croppedImage && (
            <div className="loading">Loading image&hellip;</div>
          )}
          {croppedImage && containerSize && (
            <Image containerSize={containerSize} croppedImage={croppedImage} />
          )}
        </div>
      </div>
    </ImageCropperContext.Provider>
  );
}
