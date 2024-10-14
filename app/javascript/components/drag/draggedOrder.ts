import * as Drag from "../../types/Drag";

function hovering<T>(
  dragState: Drag.State<T>,
  target: Drag.DraggableOrFiles<T> | React.MutableRefObject<HTMLDivElement>
) {
  const { x, y } = dragState;
  let rect: DOMRect;
  if (typeof target === "string") {
    return false;
  }
  if ("rect" in target) {
    rect = target.rect;
  } else if ("current" in target && target.current) {
    rect = target.current.getBoundingClientRect();
  } else {
    return false;
  }
  return x >= rect.left && x <= rect.right && y >= rect.top && y <= rect.bottom;
}

export function collectionOrder<T>(
  collection: Drag.Collection<T>,
  dragState: Drag.State<T>
): Array<Drag.DraggableOrFiles<T>> {
  const { draggables, ref } = collection;
  const { dragging } = dragState;

  if (!dragging) {
    return draggables;
  }

  let ordered = draggables;
  if (dragging !== "Files") {
    ordered = draggables
      .filter((d) => d !== "Files")
      .filter((d) => d.handle !== dragging.handle);
  }
  if (hovering(dragState, ref)) {
    const hovered = ordered.filter((d) => hovering(dragState, d))[0];
    if (hovered) {
      const index = ordered.indexOf(hovered);
      ordered = [...ordered.slice(0, index), dragging, ...ordered.slice(index)];
    } else {
      ordered = [...ordered, dragging];
    }
  }

  return ordered;
}

export default function draggedOrder<T>(
  collection: Drag.Collection<T>,
  dragState: Drag.State<T>
) {
  let ordered = collectionOrder(collection, dragState);

  if (dragState.dragging && ordered.indexOf(dragState.dragging) === -1) {
    if (
      collection.ref.current &&
      dragState.y < collection.ref.current.getBoundingClientRect().top
    ) {
      ordered = [dragState.dragging, ...ordered];
    } else {
      ordered.push(dragState.dragging);
    }
  }

  return ordered;
}
