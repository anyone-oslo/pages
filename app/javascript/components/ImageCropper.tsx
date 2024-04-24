import React, { useEffect, useRef, useState } from "react";

import Image from "./ImageCropper/Image";
import Toolbar from "./ImageCropper/Toolbar";

export { default as useCrop, cropParams } from "./ImageCropper/useCrop";

interface Props {
  croppedImage: string;
  cropState: Crop.State;
  dispatch: (action: Crop.Action) => void;
}

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

export default function ImageCropper(props: Props) {
  const containerRef = useRef<HTMLDivElement>();
  const [containerSize, setContainerSize] = useState<Crop.Size>();

  const handleResize = () => {
    const elem = containerRef.current;
    if (elem) {
      setContainerSize({
        width: elem.offsetWidth - 2,
        height: elem.offsetHeight - 2
      });
    }
  };

  useEffect(() => {
    window.addEventListener("resize", handleResize);
    return function cleanup() {
      window.removeEventListener("resize", handleResize);
    };
  });

  useEffect(handleResize, []);

  const setAspect = (aspect: number) => {
    props.dispatch({ type: "setAspect", payload: aspect });
  };

  const setCrop = (crop: Crop.CropSize) => {
    props.dispatch({ type: "setCrop", payload: crop });
  };

  const setFocal = (focal: Crop.Position) => {
    props.dispatch({ type: "setFocal", payload: focal });
  };

  const toggleCrop = () => {
    if (props.cropState.cropping) {
      props.dispatch({ type: "completeCrop" });
    } else {
      props.dispatch({ type: "startCrop" });
    }
  };

  return (
    <div className="visual">
      <Toolbar
        cropState={props.cropState}
        image={props.cropState.image}
        setAspect={setAspect}
        toggleCrop={toggleCrop}
        toggleFocal={() => props.dispatch({ type: "toggleFocal" })}
      />
      <div className="image-container" ref={containerRef}>
        {!props.croppedImage && (
          <div className="loading">Loading image&hellip;</div>
        )}
        {props.croppedImage && containerSize && (
          <Image
            cropState={props.cropState}
            containerSize={containerSize}
            croppedImage={props.croppedImage}
            focalPoint={focalPoint(props.cropState)}
            setCrop={setCrop}
            setFocal={setFocal}
          />
        )}
      </div>
    </div>
  );
}
