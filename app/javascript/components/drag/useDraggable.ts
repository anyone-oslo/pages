import { DragEvent, useEffect, useRef } from "react";

import * as Drag from "../../types/Drag";

export default function useDraggable<T>(
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
  }, [draggable.ref]);

  return { ref: ref, onDragStart: handleDrag, draggable: true };
}
