export type Id = number;
export type Node<T> = {
  id: Id;
  collapsed: boolean;
  record: T;
  childNodes: Id[];
  parent?: Id;
  height?: number;
  top?: number;
  left?: number;
};

export type MovePlacement = "before" | "after" | "prepend" | "append";

type InitNodeFn<T> = (node: T) => { children: Array<T>; collapsed?: boolean };
type SortFn<T> = (a: Node<T>, b: Node<T>) => number;
type Index<T> = Record<Id, Node<T>>;

export type State<T> = {
  rootId: Id;
  nodes: Index<T>;
  initNode: InitNodeFn<T>;
};

const uniqueId = (() => {
  let id = 1;
  return (): Id => {
    return id++;
  };
})();

export function getNodeByTop<T>(state: State<T>, top: number): Node<T> | null {
  return Object.values(state.nodes).find((n) => n.top === top) || null;
}

export function sibling<T>(state: State<T>, id: Id, offset: number) {
  const parent = state.nodes[state.nodes[id].parent];
  if (!parent) {
    return null;
  }
  const index = parent.childNodes.indexOf(id) + offset;
  if (index >= 0 && index < parent.childNodes.length) {
    return state.nodes[parent.childNodes[index]];
  }
  return null;
}

export function parents<T>(state: State<T>, id: Id) {
  const node = state.nodes[id];
  if (node.parent) {
    return [...parents(state, node.parent), node.parent];
  } else {
    return [];
  }
}

export function nextSibling<T>(state: State<T>, id: Id) {
  return sibling(state, id, 1);
}

export function prevSibling<T>(state: State<T>, id: Id) {
  return sibling(state, id, -1);
}

export function sortChildNodes<T>(state: State<T>, id: Id, sortFn: SortFn<T>) {
  return updateNode(state, id, {
    childNodes: state.nodes[id].childNodes
      .map((i) => state.nodes[i])
      .sort(sortFn)
      .map((n) => n.id)
  });
}

export function move<T>(
  prevState: State<T>,
  id: Id,
  target: Id,
  position: number
) {
  if (id === target) {
    return prevState;
  }
  const node = prevState.nodes[id];
  const state = removeNode(prevState, id);
  return insertNode(state, target, node, position);
}

export function moveRelative<T>(
  prevState: State<T>,
  id: Id,
  target: Id,
  placement: MovePlacement
): State<T> {
  if (id === target) {
    return prevState;
  }
  const node = prevState.nodes[id];
  const state = removeNode(prevState, id);

  switch (placement) {
    case "before":
      return insertAdjacentNode(state, target, node);
    case "after":
      return insertAdjacentNode(state, target, node, 1);
    case "prepend":
      return insertNode(state, target, node);
    case "append":
      return insertNode(state, target, node, -1);
    default:
      return state;
  }
}

export function insertAdjacent<T>(
  state: State<T>,
  sibling: Id,
  record: T,
  offset: number = 0
): State<T> {
  const target = state.nodes[sibling];
  const index = state.nodes[target.parent].childNodes.indexOf(target.id);
  return insert(state, target.parent, record, index + offset);
}

function insertAdjacentNode<T>(
  state: State<T>,
  sibling: Id,
  node: Node<T>,
  offset: number = 0
): State<T> {
  const target = state.nodes[sibling];
  const index = state.nodes[target.parent].childNodes.indexOf(target.id);
  return insertNode(state, target.parent, node, index + offset);
}

function insertNode<T>(
  state: State<T>,
  parent: Id,
  node: Node<T>,
  position: number = 0
) {
  const parentNode = state.nodes[parent];
  const childNodes = [...parentNode.childNodes];
  if (position < 0) {
    position += childNodes.length + 1;
  }
  childNodes.splice(position, 0, node.id);

  return updateNode(updateNode(state, node.id, { parent: parent }), parent, {
    childNodes: childNodes
  });
}

export function insert<T>(
  state: State<T>,
  parent: Id,
  record: T,
  position: number = 0
): State<T> {
  const [node, newNodes] = makeNode(record, state.initNode, parent);
  const nextState = { ...state, nodes: { ...state.nodes, ...newNodes } };
  return insertNode(nextState, parent, node, position);
}

function makeNode<T>(
  record: T,
  initNode: InitNodeFn<T>,
  parent?: Id
): [Node<T>, Index<T>] {
  const id = uniqueId();
  const childNodes = [];
  let index = {};

  const { children, collapsed } = initNode(record);

  if (children) {
    children.forEach((r) => {
      const [childNode, childIndex] = makeNode(r, initNode, id);
      childNodes.push(childNode.id);
      index = { ...index, ...childIndex };
    });
  }

  const node = {
    id: id,
    collapsed: collapsed || false,
    record: record,
    childNodes: childNodes,
    parent: parent
  };

  return [node, { ...index, [node.id]: node }];
}

function removeNode<T>(state: State<T>, id: Id) {
  const node = state.nodes[id];
  if (node.parent) {
    const childNodes = [...state.nodes[node.parent].childNodes];
    childNodes.splice(childNodes.indexOf(id), 1);
    return updateNode(state, node.parent, { childNodes: childNodes });
  } else {
    return state;
  }
}

export function remove<T>(prevState: State<T>, id: Id) {
  const state = removeNode(prevState, id);

  const removeIndex = (id: Id) => {
    state.nodes[id].childNodes.forEach((c) => removeIndex(c));
    delete state.nodes[id];
  };
  removeIndex(id);

  return state;
}

export function update<T>(state: State<T>, id: Id, updated: Partial<T>) {
  const record = { ...state.nodes[id].record, ...updated };
  return updateNode(state, id, { record: record });
}

export function updateNode<T>(
  state: State<T>,
  id: Id,
  updated: Partial<Node<T>>
) {
  const node = state.nodes[id];
  return { ...state, nodes: { ...state.nodes, [id]: { ...node, ...updated } } };
}

export function indexPositions<T>(prevState: State<T>): State<T> {
  let top = 1;
  let state = { ...prevState };
  const walk = (id: Id, left: number = 1, parentCollapsed?: boolean) => {
    const position = { height: 1, top: null, left: null };
    const node = state.nodes[id];

    if (!parentCollapsed) {
      position.top = top++;
      position.left = left;
    }

    node.childNodes.forEach((i) => {
      position.height += walk(i, left + 1, parentCollapsed || node.collapsed);
    });

    if (node.collapsed) {
      position.height = 1;
    }

    state = updateNode(state, id, position);
    return position.height;
  };

  walk(state.rootId);

  return state;
}

export function build<T>(root: T, initNode: InitNodeFn<T>): State<T> {
  const [rootNode, nodes] = makeNode(root, initNode);
  return {
    rootId: rootNode.id,
    initNode: initNode,
    nodes: nodes
  };
}
