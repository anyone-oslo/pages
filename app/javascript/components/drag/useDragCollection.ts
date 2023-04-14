import { createRef, useEffect, useReducer, useRef } from "react";
import { uniqueId } from "lodash";

import {
  Draggable,
  DraggableRecord,
  DragCollectionAction,
  DragCollection
} from "./types";

type Draggables = Draggable[];

function getPosition(draggable: Draggable) {
  if (draggable && draggable.ref && draggable.ref.current) {
    return draggable.ref.current.getBoundingClientRect();
  } else {
    return null;
  }
}

function hideDraggable(draggable: Draggable | null, callback: () => void) {
  if (draggable && draggable.ref && draggable.ref.current) {
    const prevDisplay = draggable.ref.current.style.display;
    draggable.ref.current.style.display = "none";
    const result = callback();
    draggable.ref.current.style.display = prevDisplay;
    return result;
  }
  else {
    return callback();
  }
}

function insertFiles(state: Draggable[], files: Draggable[]): Draggable[] {
  const index = state.indexOf("Files");
  if (index === -1 || !files) {
    return state;
  } else {
    return [
      ...state.slice(0, index),
      ...files,
      ...state.slice(index + 1)
    ];
  }
}

function dragCollectionReducer(
  state: Draggable[], action: DragCollectionAction
): Draggable[] {
  switch (action.type) {
  case "append":
    return [...state, ...action.payload as Draggable[]];
  case "prepend":
    return [...action.payload as Draggable[], ...state];
  case "insertFiles":
    return insertFiles(state, action.payload);
  case "update":
    return state.map(d => {
      return (d.handle === action.payload.handle) ? action.payload : d;
    });
  case "updatePositions":
    return hideDraggable(action.payload, () => {
      return state.map(d => {
        return { ...d, rect: getPosition(d) };
      });
    });
  case "remove":
    return state.filter(d => d.handle !== action.payload.handle);
  case "replace":
    return action.payload;
  case "reorder":
    return action.payload;
  default:
    return state;
  }
}

export function createDraggable(record: Record<string, unknown>): Draggable {
  return { record: record,
           rect: null,
           ref: createRef(),
           handle: uniqueId("draggable") };
}

export default function useDragCollection(
  records: DraggableRecord[]
): DragCollection {
  const containerRef = useRef<HTMLElement>(null);
  const [draggables, dispatch] = useReducer(
    dragCollectionReducer,
    [],
    () => records.map(r => createDraggable(r))
  ) as [Draggables, (Draggables) => Draggable[]];

  useEffect(() => {
    dispatch({ type: "updatePositions" });
  }, []);

  return { ref: containerRef,
           draggables: draggables,
           dispatch: dispatch };
}
