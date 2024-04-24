import React, { DragEvent, useEffect, useRef } from "react";

export default function useDraggable<T = Drag.DraggableRecord>(
  draggable: Drag.Draggable<T>,
  startDrag: (evt: React.MouseEvent, draggable: Drag.Draggable<T>) => void
) {
  const ref = useRef<HTMLDivElement>(null);

  const handleDrag = (evt: DragEvent) => {
    evt.preventDefault();
    evt.stopPropagation();
    startDrag(evt, draggable);
  };

  useEffect(() => {
    draggable.ref.current = ref.current;
  }, []);

  return { ref: ref, onDragStart: handleDrag, draggable: true };
}
