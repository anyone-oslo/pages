export type Draggable<T> = {
  record: T;
  ref: React.MutableRefObject<HTMLDivElement>;
  rect: DOMRect | null;
  handle: string;
};

export type DraggableOrFiles<T> = Draggable<T> | "Files";

export type CollectionAction<T> =
  | { type: "append" | "insertFiles" | "replace"; payload: Draggable<T>[] }
  | { type: "prepend" | "reorder"; payload: DraggableOrFiles<T>[] }
  | { type: "update"; payload: Draggable<T> }
  | { type: "reinitialize"; payload: Array<T> }
  | { type: "remove"; payload: Draggable<T> }
  | { type: "updatePositions"; payload?: DraggableOrFiles<T> };

export type Collection<T> = {
  ref: React.MutableRefObject<HTMLDivElement>;
  draggables: DraggableOrFiles<T>[];
  dispatch: React.Dispatch<CollectionAction<T>>;
};

export type Position = {
  x: number;
  y: number;
};

export type State<T> = {
  dragging: DraggableOrFiles<T> | false;
  x?: number;
  y?: number;
};
