declare namespace Drag {
  type DraggableRecord = Record<string, unknown>;

  interface Draggable<T = DraggableRecord> {
    record: T;
    ref: React.MutableRefObject<HTMLDivElement>;
    rect: DOMRect | null;
    handle: string;
  }

  type Item<T = DraggableRecord> = Draggable<T> | string;

  interface CollectionAction<T = DraggableRecord> {
    type: string;
    payload?: Item<T>[] | Item<T>;
  }

  interface Collection<T = DraggableRecord> {
    ref: React.MutableRefObject<HTMLDivElement>;
    draggables: Item<T>[];
    dispatch: (CollectionAction) => void;
  }

  interface Position {
    x: number | null;
    y: number | null;
  }

  interface State extends Position {
    dragging: Item | false;
  }
}
