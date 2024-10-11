import { createRef, useEffect, useReducer, useRef } from "react";
import { uniqueId } from "lodash";

import * as Drag from "../../types/Drag";

function getPosition<T>(draggable: Drag.Draggable<T>) {
  if (draggable && "ref" in draggable && draggable.ref.current) {
    return draggable.ref.current.getBoundingClientRect();
  } else {
    return null;
  }
}

function hideDraggable<T>(
  draggable: Drag.DraggableOrFiles<T> | null,
  callback: () => Drag.DraggableOrFiles<T>[]
) {
  if (
    draggable &&
    draggable !== "Files" &&
    "ref" in draggable &&
    draggable.ref.current
  ) {
    const prevDisplay = draggable.ref.current.style.display;
    draggable.ref.current.style.display = "none";
    const result = callback();
    draggable.ref.current.style.display = prevDisplay;
    return result;
  } else {
    return callback();
  }
}

function insertFiles<T>(
  state: Drag.DraggableOrFiles<T>[],
  files: Drag.DraggableOrFiles<T>[]
): Drag.DraggableOrFiles<T>[] {
  const index = state.indexOf("Files");
  if (index === -1 || !files) {
    return state;
  } else {
    return [...state.slice(0, index), ...files, ...state.slice(index + 1)];
  }
}

function reducer<T>(
  state: Drag.DraggableOrFiles<T>[],
  action: Drag.CollectionAction<T>
): Drag.DraggableOrFiles<T>[] {
  switch (action.type) {
    case "append":
      return [...state, ...action.payload];
    case "prepend":
      return [...action.payload, ...state];
    case "insertFiles":
      return insertFiles(state, action.payload);
    case "update":
      return state.map((d: Drag.Draggable<T>) => {
        return d.handle === action.payload.handle ? action.payload : d;
      });
    case "updatePositions":
      return hideDraggable(action.payload, () => {
        return state.map((d: Drag.Draggable<T>) => {
          return { ...d, rect: getPosition(d) };
        });
      });
    case "reinitialize":
      return action.payload.map((r) => createDraggable(r));
    case "remove":
      return state.filter(
        (d: Drag.Draggable<T>) => d.handle !== action.payload.handle
      );
    case "replace":
      return action.payload;
    case "reorder":
      return action.payload;
    default:
      return state;
  }
}

export function createDraggable<T>(record: T): Drag.Draggable<T> {
  return {
    record: record,
    rect: null,
    ref: createRef(),
    handle: uniqueId("draggable")
  };
}

export default function useDragCollection<T>(
  records: Array<T>
): Drag.Collection<T> {
  const containerRef = useRef<HTMLDivElement>(null);
  const [draggables, dispatch] = useReducer(reducer<T>, [], () =>
    records.map((r) => createDraggable(r))
  );

  useEffect(() => {
    dispatch({ type: "updatePositions" });
  }, []);

  return { ref: containerRef, draggables: draggables, dispatch: dispatch };
}
