import { useEffect, useState } from "react";

import { Draggable, DragCollection, DragState, Position } from "./types";

function containsFiles(evt: Event) {
  if ("dataTransfer" in evt) {
    const dataTransfer: DataTransfer = evt.dataTransfer;
    if ("types" in dataTransfer) {
      const types = dataTransfer.types;
      for (let i = 0; i < types.length; i++) {
        if (types[i] === "Files" || types[i] === "application/x-moz-file") {
          return true;
        }
      }
    }
  }
  return false;
}

function getFiles(dt: DataTransfer): File[] {
  const files: File[] = [];
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

function mousePosition(evt: TouchEvent | MouseEvent): Position {
  let x: number | null, y: number | null;
  if ("touches" in evt && evt.type == "touchmove") {
    x = evt.touches[0].clientX;
    y = evt.touches[0].clientY;
  } else if (evt instanceof MouseEvent) {
    x = evt.clientX;
    y = evt.clientY;
  }
  return { x: x, y: y };
}

export default function useDragUploader(
  collections: DragCollection[],
  onDragEnd: (dragState: DragState, files: File[]) => void
) {
  const initialState: DragState = {
    dragging: false,
    x: null, y: null
  };

  const [dragState, setDragState] = useState(initialState);

  const updatePositions = (dragging: Draggable | null) => {
    collections.forEach(c => {
      c.dispatch({ type: "updatePositions", payload: dragging });
    });
  };

  const startDrag = (evt: Event, draggable: Draggable) => {
    updatePositions(draggable);
    setDragState({ dragging: draggable, ...mousePosition(evt) });
  };

  const drag = (evt: Event) => {
    if (dragState.dragging) {
      evt.stopPropagation();
      evt.preventDefault();
      setDragState({ ...dragState, ...mousePosition(evt) });
    } else {
      if (containsFiles(evt)) {
        startDrag(evt, "Files");
      }
    }
  };

  const dragEnd = (evt: Event) => {
    if (dragState.dragging) {
      const prevDragState = dragState;
      let files: File[] = [];
      evt.stopPropagation();
      evt.preventDefault();
      if ("dataTransfer" in evt && dragState.dragging == "Files") {
        files = getFiles(evt.dataTransfer);
      }
      setDragState({ dragging: false, x: null, y: null });
      onDragEnd(prevDragState, files);
      updatePositions();
    }
  };

  const dragLeave = (evt: Event) => {
    if (dragState.dragging === "Files") {
      evt.preventDefault();
      evt.stopPropagation();
      setDragState({ dragging: false, x: null, y: null });
    }
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

  return [dragState, startDrag, { onDragOver: drag, onDrop: dragEnd }];
}
