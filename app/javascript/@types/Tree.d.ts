declare namespace Tree {
  type Id = number | string;

  interface Node {
    children: Array<Node>;
    collapsed: boolean;
    root?: boolean;
  }

  interface Index<T extends Node = Node> {
    id: number;
    node: T;
    children?: Id[];
    parent?: Id;
    top?: number;
    height?: number;
    next?: Id;
    prev?: Id;
    left?: number;
  }
}
