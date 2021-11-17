import React from "react";
import PropTypes from "prop-types";

export default function DragElement(props) {
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
        {draggable.record.image && (
          <img src={draggable.record.src || draggable.record.image.thumbnail_url} />
        )}
      </div>
    );
  }
}

DragElement.propTypes = {
  draggable: PropTypes.oneOfType([PropTypes.object, PropTypes.string]),
  dragState: PropTypes.object,
  container: PropTypes.object
};
