/*
   Based on react-ui-tree
   https://github.com/pqx/react-ui-tree

   The MIT License (MIT)

   Copyright (c) 2015 pqx Limited

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
 */

import React, { Component } from "react";
import Tree from "../../lib/Tree";
import Node from "./Node";

interface DragState {
  id?: Tree.Id;
  x: number | null;
  y: number | null;
  w: number | null;
  h: number | null;
  scrollTop: number | null;
  scrollLeft: number | null;
}

interface Props {
  addChild: (id: Tree.Id, attrs: Page.TreeNode) => void;
  dir: string;
  locale: string;
  movedPage: (id: Tree.Id) => void;
  paddingLeft?: number;
  toggleCollapsed: (id: Tree.Id) => void;
  tree: Tree<Page.TreeNode>;
  updatePage: (id: Tree.Id, attributes: Partial<Page.TreeItem>) => void;
  updateTree: (Tree) => void;
}

interface State {
  dragging: DragState;
}

const defaultPadding = 20;

export default class Draggable extends Component<Props, State> {
  _dragListener: (evt: MouseEvent) => void;
  _dragEndListener: () => void;
  _start: boolean;
  _startX: number;
  _startY: number;
  _offsetX: number;
  _offsetY: number;
  dragging: DragState;

  constructor(props: Props) {
    super(props);
    this.state = {
      dragging: this.initDragging()
    };
  }

  initDragging(): DragState {
    return {
      id: null,
      x: null,
      y: null,
      w: null,
      h: null,
      scrollTop: null,
      scrollLeft: null
    };
  }

  getDraggingDom() {
    const tree = this.props.tree;
    const dragging = this.state.dragging;
    if (dragging && dragging.id) {
      const draggingIndex = tree.getIndex(dragging.id);
      const draggingStyles = {
        top: dragging.y,
        left: dragging.x,
        width: dragging.w
      };

      return (
        <div className="draggable" style={draggingStyles}>
          <Node
            tree={tree}
            index={draggingIndex}
            paddingLeft={this.props.paddingLeft || defaultPadding}
          />
        </div>
      );
    }

    return null;
  }

  render() {
    const { tree, dir, locale } = this.props;
    const dragging = this.state.dragging;

    if (!tree) {
      return <div className="page-tree">{this.getDraggingDom()}</div>;
    } else {
      const root = tree.getIndex(1);
      return (
        <div className="page-tree">
          {this.getDraggingDom()}
          <Node
            tree={tree}
            index={root}
            key={root.id}
            paddingLeft={this.props.paddingLeft || defaultPadding}
            addChild={(idx: Tree.Index<Page.TreeNode>) => this.addChild(idx)}
            onDragStart={this.dragStart}
            onCollapse={(nodeId) => this.toggleCollapse(nodeId)}
            updatePage={(idx, attrs) => this.updatePage(idx, attrs)}
            dragging={dragging && dragging.id}
            dir={dir}
            locale={locale}
          />
        </div>
      );
    }
  }

  addChild(parent: Tree.Index<Page.TreeNode>) {
    const newNode: Page.TreeNode = {
      name: "",
      status: 0,
      editing: true,
      children: [],
      published_at: new Date(),
      pinned: false,
      locale: parent.node.locale,
      parent_page_id: parent.node.id,
      collapsed: false
    };
    this.props.addChild(parent.id, newNode);
  }

  prevAddButtonCount(tree: Tree, index: Tree.Index) {
    let count = 0;
    const parentNodes = [];
    let pointer = tree.getIndex(index.parent);
    while (pointer) {
      parentNodes.push(pointer);
      pointer = tree.getIndex(pointer.parent);
    }

    pointer = index;

    pointer = tree.getNodeByTop(index.top - 1);
    while (pointer) {
      if (
        parentNodes.indexOf(pointer) == -1 &&
        !pointer.node.collapsed &&
        pointer.node.children.filter((p: Page.TreeNode) => p.status != 4)
          .length > 0
      ) {
        count += 1;
      }
      pointer = tree.getNodeByTop(pointer.top - 1);
    }

    return count;
  }

  scrollOffset() {
    const dragging = this.state.dragging;
    return {
      top: document.body.scrollTop - dragging.scrollTop,
      left: document.body.scrollLeft - dragging.scrollLeft
    };
  }

  drag(e: MouseEvent) {
    if (this._start) {
      const distance =
        Math.abs(e.clientX - this._offsetX) +
        Math.abs(e.clientY - this._offsetY);
      if (distance >= 15) {
        this.setState({
          dragging: this.dragging
        });
        this._start = false;
      } else {
        return null;
      }
    }

    const tree = this.props.tree;
    const dragging = this.state.dragging;
    const paddingLeft = this.props.paddingLeft || defaultPadding;
    let newIndex: Tree.Index<Page.TreeNode> = null;
    let index = tree.getIndex(dragging.id);
    const collapsed = index.node.collapsed;

    const _startX = this._startX;
    const _startY = this._startY;
    const _offsetX = this._offsetX;
    const _offsetY = this._offsetY;

    const pos = {
      x: _startX + e.clientX - _offsetX + this.scrollOffset().left,
      y: _startY + e.clientY - _offsetY + this.scrollOffset().top
    };
    dragging.x = pos.x;
    dragging.y = pos.y;

    const diffX = dragging.x - paddingLeft / 2 - (index.left - 2) * paddingLeft;
    const diffY =
      dragging.y -
      dragging.h / 2 -
      (index.top - 2 + this.prevAddButtonCount(tree, index)) * dragging.h;

    if (diffX < 0) {
      // left
      if (index.parent && !index.next) {
        newIndex = tree.move(index.id, index.parent, "after");
      }
    } else if (diffX > paddingLeft) {
      // right
      if ("prev" in index) {
        const prev = tree.getIndex(index.prev);

        if (!prev.node.collapsed) {
          newIndex = tree.move(index.id, index.prev, "append");
        }
      }
    }

    if (newIndex) {
      index = newIndex;
      newIndex.node.collapsed = collapsed;
      dragging.id = newIndex.id;
    }

    if (diffY < 0 - dragging.h * 0.5) {
      // up
      const above = tree.getNodeByTop(index.top - 1);
      newIndex = tree.move(index.id, above.id, "before");
    } else if (diffY > dragging.h * 1.5) {
      // down
      const below = index.next
        ? tree.getIndex(index.next)
        : tree.getNodeByTop(index.top + index.height);

      if (below && below.parent !== index.id) {
        if (below.children && below.children.length && !below.node.collapsed) {
          newIndex = tree.move(index.id, below.id, "prepend");
        } else {
          newIndex = tree.move(index.id, below.id, "after");
        }
      }
    }

    if (newIndex) {
      newIndex.node.collapsed = collapsed;
      dragging.id = newIndex.id;
    }

    this.setState({ dragging: dragging });
  }

  dragStart = (id: Tree.Id, dom: HTMLDivElement, e: React.MouseEvent) => {
    // Only drag on left click
    if (e.button !== 0) {
      return;
    }

    this.dragging = {
      id: id,
      w: dom.offsetWidth,
      h: dom.offsetHeight,
      x: dom.offsetLeft,
      y: dom.offsetTop,
      scrollTop: document.body.scrollTop,
      scrollLeft: document.body.scrollLeft
    };

    this._startX = dom.offsetLeft;
    this._startY = dom.offsetTop;
    this._offsetX = e.clientX;
    this._offsetY = e.clientY;
    this._start = true;

    this._dragListener = (e: MouseEvent) => {
      this.drag(e);
    };
    this._dragEndListener = () => this.dragEnd();

    window.addEventListener("mousemove", this._dragListener);
    window.addEventListener("mouseup", this._dragEndListener);
  };

  dragEnd() {
    if (!this._start) {
      this.props.updateTree(this.props.tree);
      this.props.movedPage(this.state.dragging.id);
    }

    this.setState({
      dragging: this.initDragging()
    });

    window.removeEventListener("mousemove", this._dragListener);
    window.removeEventListener("mouseup", this._dragEndListener);
  }

  toggleCollapse(nodeId: Tree.Id) {
    this.props.toggleCollapsed(nodeId);
  }

  updatePage(index: Tree.Index, attributes: Partial<Page.TreeItem>) {
    this.props.updatePage(index.id, attributes);
  }
}
