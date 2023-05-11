import React, { RefObject } from "react";

import { ImageResource } from "../../types";
import { DragState } from "../drag";

interface DragElementProps {
  container: RefObject<HTMLDivElement>;
  draggable: string | { record: { image: ImageResource; src?: string } };
  dragState: DragState;
}

export default function DragElement(props: DragElementProps) {
  const { draggable, dragState, container } = props;

  if (draggable === "Files") {
    return "";
  } else {
    const containerSize = container.current.getBoundingClientRect();
    const x = dragState.x - (containerSize.x || containerSize.left);
    const y = dragState.y - (containerSize.y || containerSize.top);
    const translateStyle = {
      transform: `translate3d(${x}px, ${y}px, 0)`
    };
    return (
      <div className="drag-image" style={translateStyle}>
        {"record" in draggable && draggable.record.image && (
          <img
            src={draggable.record.src || draggable.record.image.thumbnail_url}
          />
        )}
      </div>
    );
  }
}
