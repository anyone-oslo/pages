declare namespace Drag {
  type DraggableRecord = Record<string, unknown>;

  interface Draggable<T = DraggableRecord> {
    record: T;
    ref: React.MutableRefObject<HTMLDivElement>;
    rect: DOMRect | null;
    handle: string;
  }

  type Item<T = DraggableRecord> = Draggable<T> | "Files";

  type CollectionAction<T = DraggableRecord> =
    | {
        type: "append" | "prepend" | "insertFiles" | "replace" | "reorder";
        payload: Item<T>[];
      }
    | { type: "update"; payload: Item<T> }
    | { type: "remove"; payload: Drag.Draggable<T> }
    | { type: "updatePositions"; payload?: Drag.Draggable<T> };

  interface Collection<T = DraggableRecord> {
    ref: React.MutableRefObject<HTMLDivElement>;
    draggables: Item<T>[];
    dispatch: (CollectionAction) => void;
  }

  interface Position {
    x: number | null;
    y: number | null;
  }

  interface State<T = DraggableRecord> extends Position {
    dragging: Item<T> | false;
  }
}
