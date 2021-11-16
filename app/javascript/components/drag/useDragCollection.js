import React, { useEffect, useReducer, useRef } from "react";
import uniqueId from "lodash/uniqueId";

function getPosition(draggable) {
  if (draggable.ref.current) {
    return draggable.ref.current.getBoundingClientRect();
  } else {
    return null;
  }
}

function hideDraggable(draggable, callback) {
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

function dragCollectionReducer(state, action) {
  switch (action.type) {
  case "append":
    return [...state, ...action.payload];
  case "prepend":
    return [...action.payload, ...state];
  case "insertFiles":
    var index = state.indexOf("Files");

    if (index === -1 || !action.payload) {
      return state;
    } else {
      return [...state.slice(0, index),
              ...action.payload,
              ...state.slice(index + 1)];
    }
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

export function createDraggable(record) {
  return { record: record,
           rect: null,
           ref: React.createRef(),
           handle: uniqueId("draggable") };
}

export default function useDragCollection(records) {
  const containerRef = useRef();
  const [draggables, dispatch] = useReducer(
    dragCollectionReducer,
    [],
    () => records.map(r => createDraggable(r))
  );

  useEffect(() => {
    dispatch({ type: "updatePositions" });
  }, []);

  return { ref: containerRef,
           draggables: draggables,
           dispatch: dispatch };
}
