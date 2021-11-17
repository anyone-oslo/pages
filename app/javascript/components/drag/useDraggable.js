import { useEffect, useRef } from "react";

export default function useDraggable(draggable, startDrag) {
  const ref = useRef();

  const handleDrag = (evt) => {
    evt.preventDefault();
    evt.stopPropagation();
    startDrag(evt, draggable);
  };

  useEffect(() => {
    draggable.ref.current = ref.current;
  }, []);

  return { ref: ref, onDragStart: handleDrag, draggable: true };
}
