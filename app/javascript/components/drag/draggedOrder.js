function hovering(dragState, target) {
  let { x, y } = dragState;
  var rect;
  if (target.rect) {
    rect = target.rect;
  } else if (target.current) {
    rect = target.current.getBoundingClientRect();
  } else {
    return false;
  }
  return (x >= rect.left && x <= rect.right &&
          y >= rect.top && y <= rect.bottom);
}

export function collectionOrder(collection, dragState) {
  const { draggables, ref } = collection;
  const { dragging } = dragState;

  if (!dragging) {
    return draggables;
  }

  let ordered = draggables.filter(d => d.handle !== dragging.handle);
  if (hovering(dragState, ref)) {
    const hovered = ordered.filter(d => hovering(dragState, d))[0];
    if (hovered) {
      const index = ordered.indexOf(hovered);
      ordered = [...ordered.slice(0, index),
                 dragging,
                 ...ordered.slice(index)];
    } else {
      ordered = [...ordered, dragging];
    }
  }

  return ordered;
}

export default function draggedOrder(collection, dragState) {
  let ordered = collectionOrder(collection, dragState);

  if (dragState.dragging && ordered.indexOf(dragState.dragging) === -1) {
    if (dragState.y < collection.ref.current.getBoundingClientRect().top) {
      ordered = [dragState.dragging, ...ordered];
    } else {
      ordered.push(dragState.dragging);
    }
  }

  return ordered;
}
