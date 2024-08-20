import React, { useCallback, useEffect, useState } from "react";

import * as Pages from "../types/Pages";
import * as Tree from "./PageTree/tree";
import usePageTree, {
  State,
  movePage,
  visibleChildNodes
} from "./PageTree/usePageTree";
import Node, { paddingLeft } from "./PageTree/Node";

type DragState = {
  id: Tree.Id;
  x: number;
  y: number;
  w: number;
  h: number;
  scrollTop: number;
  scrollLeft: number;
  startX: number;
  startY: number;
  offsetX: number;
  offsetY: number;
  tree: State;
};

type Props = {
  dir: string;
  locale: string;
  pages: Pages.TreeResource[];
  permissions: string[];
};

function prevAddButtonCount(state: State, id: Tree.Id) {
  let count = 0;
  const parentNodes = Tree.parents(state, id);

  let pointer = Tree.getNodeByTop(state, state.nodes[id].top - 1);
  while (pointer) {
    if (
      parentNodes.indexOf(pointer.id) == -1 &&
      !pointer.collapsed &&
      visibleChildNodes(state, pointer.id).length > 0
    ) {
      count += 1;
    }
    pointer = Tree.getNodeByTop(state, pointer.top - 1);
  }
  return count;
}

export default function PageTree({ dir, locale, pages, permissions }: Props) {
  const [state, dispatch] = usePageTree(pages, locale, dir, permissions);

  const [dragging, setDragging] = useState(false);
  const [dragState, setDragState] = useState<DragState | null>(null);

  const getDraggingDom = () => {
    if (dragging) {
      const dragStateStyles = {
        top: dragState.y,
        left: dragState.x,
        width: dragState.w
      };

      return (
        <div className="draggable" style={dragStateStyles}>
          <Node state={dragState.tree} id={dragState.id} dispatch={dispatch} />
        </div>
      );
    }
  };

  const dragStart = (id: Tree.Id, dom: HTMLDivElement, e: React.MouseEvent) => {
    // Only drag on left click
    if (e.button !== 0) {
      return;
    }

    setDragState({
      id: id,
      w: dom.offsetWidth,
      h: dom.offsetHeight,
      x: dom.offsetLeft,
      y: dom.offsetTop,
      scrollTop: document.body.scrollTop,
      scrollLeft: document.body.scrollLeft,
      startX: dom.offsetLeft,
      startY: dom.offsetTop,
      offsetX: e.clientX,
      offsetY: e.clientY,
      tree: { ...state }
    });
  };

  const drag = useCallback(
    (e: MouseEvent) => {
      if (!dragState) {
        return;
      } else if (!dragging) {
        const distance =
          Math.abs(e.clientX - dragState.offsetX) +
          Math.abs(e.clientY - dragState.offsetY);
        if (distance >= 15) {
          setDragging(true);
        } else {
          return null;
        }
      }

      let tree = dragState.tree;
      let node = tree.nodes[dragState.id];

      const pos = {
        x:
          dragState.startX +
          e.clientX -
          dragState.offsetX +
          (document.body.scrollLeft - dragState.scrollLeft),
        y:
          dragState.startY +
          e.clientY -
          dragState.offsetY +
          (document.body.scrollTop - dragState.scrollTop)
      };

      const move = (target: Tree.Id, placement: Tree.MovePlacement) => {
        tree = {
          ...tree,
          ...Tree.indexPositions(
            Tree.moveRelative(tree, node.id, target, placement)
          )
        };
        node = tree.nodes[dragState.id];
      };

      const diffX = pos.x - paddingLeft / 2 - (node.left - 2) * paddingLeft;
      const diffY =
        pos.y -
        dragState.h / 2 -
        (node.top - 2 + prevAddButtonCount(tree, dragState.id)) * dragState.h;

      if (diffX < 0) {
        // left
        if (node.parent && !Tree.nextSibling(tree, node.id)) {
          move(node.parent, "after");
        }
      } else if (diffX > paddingLeft) {
        // right
        const prev = Tree.prevSibling(tree, node.id);
        if (prev && !prev.collapsed) {
          move(prev.id, "append");
        }
      }

      if (diffY < 0 - dragState.h * 0.5) {
        // up
        move(Tree.getNodeByTop(tree, node.top - 1).id, "before");
      } else if (diffY > dragState.h * 1.5) {
        // down
        const below =
          Tree.nextSibling(tree, node.id) ||
          Tree.getNodeByTop(tree, node.id + node.height);

        if (below && below.parent !== node.id) {
          if (below.childNodes.length > 0 && !below.collapsed) {
            move(below.id, "prepend");
          } else {
            move(below.id, "after");
          }
        }
      }

      setDragState({ ...dragState, ...pos, tree: tree });
    },
    [dragging, dragState]
  );

  const dragEnd = useCallback(() => {
    if (dragging) {
      movePage(dragState.tree, dragState.id, dispatch);
      setDragState(null);
      setDragging(false);
    }
  }, [dragging, dragState, dispatch]);

  useEffect(() => {
    window.addEventListener("mousemove", drag);
    window.addEventListener("mouseup", dragEnd);
    return () => {
      window.removeEventListener("mousemove", drag);
      window.removeEventListener("mouseup", dragEnd);
    };
  }, [drag, dragEnd]);

  return (
    <div className="page-tree">
      {getDraggingDom()}
      <Node
        state={(dragging && dragState.tree) || state}
        id={state.rootId}
        dispatch={dispatch}
        onDragStart={dragStart}
        dragging={dragging && dragState.id}
      />
    </div>
  );
}
