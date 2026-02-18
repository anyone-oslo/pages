import { useRef, useState } from "react";

import useImageCropperContext from "./useImageCropperContext";
import * as Crop from "../../types/Crop";

type Props = {
  width: number;
  height: number;
};

function clamp(val: number, min: number, max: number): number {
  if (val < min) {
    return min;
  } else if (val > max) {
    return max;
  } else {
    return val;
  }
}

export default function FocalPoint(props: Props) {
  const { width, height } = props;
  const { state, dispatch } = useImageCropperContext();

  const [dragging, setDragging] = useState(false);
  const [position, setPosition] = useState<Crop.Position>(state.focalPoint);

  const containerRef = useRef<HTMLDivElement>(null);
  const pointRef = useRef<HTMLDivElement>(null);

  const dragStart = (evt: React.MouseEvent | React.TouchEvent) => {
    evt.preventDefault();
    evt.stopPropagation();
    if (evt.target == pointRef.current) {
      setDragging(true);
    }
  };

  const dragEnd = () => {
    if (dragging) {
      setDragging(false);
      dispatch({ type: "setFocal", payload: position });
    }
  };

  const drag = (evt: React.MouseEvent | React.TouchEvent) => {
    if (dragging) {
      let x: number, y: number;
      const containerSize = containerRef.current.getBoundingClientRect();
      evt.preventDefault();

      if ("touches" in evt && evt.type == "touchmove") {
        x = evt.touches[0].clientX - (containerSize.x || containerSize.left);
        y = evt.touches[0].clientY - (containerSize.y || containerSize.top);
      } else if ("clientX" in evt) {
        x = evt.clientX - (containerSize.x || containerSize.left);
        y = evt.clientY - (containerSize.y || containerSize.top);
      }

      x = clamp(x, 0, width);
      y = clamp(y, 0, height);

      setPosition({
        x: (x / width) * 100,
        y: (y / height) * 100
      });
    }
  };

  const x = width * (position.x / 100);
  const y = height * (position.y / 100);
  const pointStyle = {
    transform: `translate3d(${x}px, ${y}px, 0)`
  };

  return (
    <div
      className="focal-editor"
      ref={containerRef}
      onTouchStart={dragStart}
      onTouchEnd={dragEnd}
      onTouchMove={drag}
      onMouseDown={dragStart}
      onMouseUp={dragEnd}
      onMouseMove={drag}>
      <div className="focal-point" style={pointStyle} ref={pointRef} />
    </div>
  );
}
