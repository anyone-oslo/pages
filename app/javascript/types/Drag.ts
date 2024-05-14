export type DraggableRecord = Record<string, unknown>;

export interface Draggable<T = DraggableRecord> {
  record: T;
  ref: React.MutableRefObject<HTMLDivElement>;
  rect: DOMRect | null;
  handle: string;
}

export type Item<T = DraggableRecord> = Draggable<T> | "Files";

export type CollectionAction<T = DraggableRecord> =
  | {
      type: "append" | "prepend" | "insertFiles" | "replace" | "reorder";
      payload: Item<T>[];
    }
  | { type: "update"; payload: Item<T> }
  | { type: "remove"; payload: Draggable<T> }
  | { type: "updatePositions"; payload?: Draggable<T> };

export interface Collection<T = DraggableRecord> {
  ref: React.MutableRefObject<HTMLDivElement>;
  draggables: Item<T>[];
  dispatch: (CollectionAction) => void;
}

export interface Position {
  x: number | null;
  y: number | null;
}

export interface State<T = DraggableRecord> extends Position {
  dragging: Item<T> | false;
}
