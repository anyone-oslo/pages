export type DraggableRecord = Record<string, unknown>;

export interface Draggable {
  record: DraggableRecord,
  ref: React.MutableRefObject<HTMLDivElement>,
  rect: DOMRect | null,
  handle: string
}

export interface DragCollectionAction {
  type: string,
  payload?: Draggable[] | Draggable | null
}

export interface DragCollection {
  ref: React.MutableRefObject<HTMLDivElement>,
  draggables: Draggable[],
  dispatch: (DragCollectionAction) => void
}

export interface Position {
  x: number | null,
  y: number | null
}

export interface DragState extends Position {
  dragging: Draggable | false
}
