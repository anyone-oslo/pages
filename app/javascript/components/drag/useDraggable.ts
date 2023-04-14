import React, { useEffect, useRef } from "react";
import { Draggable } from "./types";

export default function useDraggable(
  draggable: Draggable,
  startDrag: (evt: React.MouseEvent, draggable: Draggable) => void
) {
  const ref = useRef<HTMLDivElement>(null);

  const handleDrag = (evt: Event) => {
    evt.preventDefault();
    evt.stopPropagation();
    startDrag(evt, draggable);
  };

  useEffect(() => {
    draggable.ref.current = ref.current;
  }, []);

  return { ref: ref, onDragStart: handleDrag, draggable: true };
}
