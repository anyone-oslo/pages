import React, { RefObject } from "react";

interface Props {
  container: RefObject<HTMLDivElement>;
  draggable: Drag.Item<ImageRecord>;
  dragState: Drag.State;
}

export default function DragElement(props: Props) {
  const { draggable, dragState, container } = props;

  if (draggable === "Files") {
    return "";
  } else if (typeof draggable !== "string") {
    const record = draggable.record;
    const containerSize = container.current.getBoundingClientRect();
    const x = dragState.x - (containerSize.x || containerSize.left);
    const y = dragState.y - (containerSize.y || containerSize.top);
    const translateStyle = {
      transform: `translate3d(${x}px, ${y}px, 0)`
    };
    return (
      <div className="drag-image" style={translateStyle}>
        {record.image && <img src={record.src || record.image.thumbnail_url} />}
      </div>
    );
  }
}
