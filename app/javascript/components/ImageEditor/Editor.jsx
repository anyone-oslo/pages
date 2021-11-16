import React, { useEffect, useRef, useState } from "react";
import PropTypes from "prop-types";

import Image from "./Image";
import Toolbar from "./Toolbar";

function focalPoint(state) {
  if (state.crop_gravity_x === null || state.crop_gravity_y === null) {
    return null;
  } else {
    return {
      x: ((state.crop_gravity_x - state.crop_start_x) / state.crop_width) * 100,
      y: ((state.crop_gravity_y - state.crop_start_y) / state.crop_height) * 100
    };
  }
}

export default function Editor(props) {
  const containerRef = useRef();
  const [containerSize, setContainerSize] = useState(null);

  const handleResize = () => {
    let elem = containerRef.current;
    if (elem) {
      setContainerSize({ width: elem.offsetWidth - 2,
                         height: elem.offsetHeight - 2 });
    }
  };

  useEffect(() => {
    window.addEventListener("resize", handleResize);
    return function cleanup() {
      window.removeEventListener("resize", handleResize);
    };
  });

  useEffect(handleResize, []);

  const setAspect = (aspect) => {
    props.dispatch({ type: "setAspect", payload: aspect });
  };

  const setCrop = (crop) => {
    props.dispatch({ type: "setCrop", payload: crop });
  };

  const setFocal = (focal) => {
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
      <Toolbar cropState={props.cropState}
               image={props.cropState.image}
               setAspect={setAspect}
               toggleCrop={toggleCrop}
               toggleFocal={() => props.dispatch({ type: "toggleFocal" })} />
      <div className="image-container" ref={containerRef}>
        {!props.croppedImage &&
         <div className="loading">
           Loading image&hellip;
         </div>}
        {props.croppedImage && containerSize &&
         <Image cropState={props.cropState}
                containerSize={containerSize}
                croppedImage={props.croppedImage}
                focalPoint={focalPoint(props.cropState)}
                setCrop={setCrop}
                setFocal={setFocal} />}
      </div>
    </div>
  );
}

Editor.propTypes = {
  croppedImage: PropTypes.string,
  cropState: PropTypes.object,
  dispatch: PropTypes.func
};
