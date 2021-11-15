import { useEffect, useState } from "react";

function containsFiles(evt) {
  if (!evt.dataTransfer || !evt.dataTransfer.types) {
    return false;
  }
  const types = evt.dataTransfer.types;
  for (var i = 0; i < types.length; i++) {
    if (types[i] === "Files" || types[i] === "application/x-moz-file") {
      return true;
    }
  }
  return false;
}

function getFiles(dt) {
  var files = [];
  if (dt.items) {
    for (let i = 0; i < dt.items.length; i++) {
      if (dt.items[i].kind == "file") {
        files.push(dt.items[i].getAsFile());
      }
    }
  } else {
    for (let i = 0; i < dt.files.length; i++) {
      files.push(dt.files[i]);
    }
  }
  return files;
}

function mousePosition(evt) {
  var x, y;
  if (evt.type == "touchmove") {
    x = evt.touches[0].clientX;
    y = evt.touches[0].clientY;
  } else {
    x = evt.clientX;
    y = evt.clientY;
  }
  return { x: x, y: y };
}

export default function useDragUploader(collections, onDragEnd) {
  const [dragState, setDragState] = useState({ dragging: false,
                                               x: null, y: null });

  const updatePositions = (dragging) => {
    collections.forEach(c => c.dispatch({ type: "updatePositions",
                                          payload: dragging }));
  };

  const initiateDrag = (evt, draggable) => {
    updatePositions(draggable);
    setDragState({ dragging: draggable, ...mousePosition(evt) });
  };

  const drag = (evt) => {
    if (dragState.dragging) {
      evt.stopPropagation();
      evt.preventDefault();
      setDragState({ ...dragState, ...mousePosition(evt) });
    } else {
      if (containsFiles(evt)) {
        initiateDrag(evt, "Files");
      }
    }
  };

  const dragEnd = (evt) => {
    if (dragState.dragging) {
      const prevDragState = dragState;
      var files = [];
      evt.preventDefault();
      evt.stopPropagation();
      if (dragState.dragging == "Files") {
        files = getFiles(evt.dataTransfer);
      }
      setDragState({ dragging: false, x: null, y: null });
      onDragEnd(prevDragState, files);
      updatePositions();
    }
  };

  const dragLeave = (evt) => {
    if (dragState.dragging === "Files") {
      evt.preventDefault();
      evt.stopPropagation();
      setDragState({ dragging: false, x: null, y: null });
    }
  };

  const dragStart = (draggable) => (evt) => {
    evt.preventDefault();
    evt.stopPropagation();
    initiateDrag(evt, draggable);
  };

  useEffect(() => {
    window.addEventListener("mousemove", drag);
    window.addEventListener("touchmove", drag);
    window.addEventListener("mouseup", dragEnd);
    window.addEventListener("touchend", dragEnd);
    window.addEventListener("mouseout", dragLeave);
    return function cleanup() {
      window.removeEventListener("mousemove", drag);
      window.removeEventListener("touchmove", drag);
      window.removeEventListener("mouseup", dragEnd);
      window.removeEventListener("touchend", dragEnd);
      window.removeEventListener("mouseout", dragLeave);
    };
  });

  return [dragState,
          dragStart,
          { onDragOver: drag, onDrop: dragEnd }];
}
