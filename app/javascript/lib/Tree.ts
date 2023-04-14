/*
  Based on

  js-tree by Wang Zuo
  https://github.com/wangzuo/js-tree

  react-ui-tree
  https://github.com/pqx/react-ui-tree

  The MIT License (MIT)

  Copyright (c) 2015 Wang Zuo

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Copyright (c) 2015 pqx Limited

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
 */

type TreeId = number | string;
type MovePlacement = "before" | "after" | "prepend" | "append";

interface TreeNode {
  children: TreeNode[],
  collapsed: boolean
}

interface TreeIndex {
  id: number,
  node: TreeNode,
  children: TreeIndex[],
  parent: TreeIndex
}

function indexName(id: number | string): string {
  return `${id}`;
}

export default class Tree {
  cnt: number;
  obj: TreeNode;
  indexes: Record<string, TreeIndex>;

  constructor(obj: TreeNode) {
    this.cnt = 1;
    this.obj = obj || { children: [] };
    this.indexes = {};
    this.build(this.obj);
  }

  build(obj: TreeNode): TreeIndex {
    const indexes = this.indexes;
    const startId = this.cnt;

    const index = { id: startId, node: obj };
    indexes[indexName(this.cnt)] = index;
    this.cnt++;

    const walk = (objs: TreeIndex[], parent: TreeIndex) => {
      const children: TreeIndex[] = [];
      objs.forEach((obj) => {
        const index = {};
        index.id = this.cnt;
        index.node = obj;

        if (parent) {
          index.parent = parent.id;
        }

        indexes[indexName(this.cnt)] = index;
        children.push(this.cnt);
        this.cnt++;

        if (obj.children && obj.children.length) {
          walk(obj.children, index);
        }
      });
      parent.children = children;

      children.forEach(function(id, i) {
        const index = indexes[indexName(id)];
        if (i > 0) {
          index.prev = children[i - 1];
        }
        if (i < children.length-1) {
          index.next = children[i+1];
        }
      });
    };

    if (obj.children && obj.children.length) {
      walk(obj.children, index);
    }

    return index;
  }

  getIndex(id: TreeId): TreeIndex {
    return this.indexes[indexName(id)];
  }

  removeIndex(index: TreeIndex) {
    const del = (index: TreeIndex) => {
      delete this.indexes[indexName(index.id)];
      if (index.children && index.children.length) {
        index.children.forEach((child) => {
          del(this.getIndex(child));
        });
      }
    };
    del(index);
  }

  get(id: TreeId): TreeNode {
    return this.getIndex(id).node;
  }

  remove(id: TreeId): TreeNode {
    const index = this.getIndex(id);
    const node = this.get(id);

    const parentIndex = this.getIndex(index.parent);
    const parentNode = this.get(index.parent);

    parentNode.children.splice(parentNode.children.indexOf(node), 1);
    parentIndex.children.splice(parentIndex.children.indexOf(id), 1);

    this.removeIndex(index);
    this.updateChildren(parentIndex.children);

    return node;
  }

  updateChildren(children: TreeIndex[]) {
    children.forEach((id, i) => {
      const index = this.getIndex(id);
      index.prev = index.next = null;
      if (i > 0) {
        index.prev = children[i-1];
      }
      if (i < children.length-1) {
        index.next = children[i+1];
      }
    });
  }

  insert(obj: TreeNode, parentId: TreeId, i: number): TreeIndex {
    const parentIndex = this.getIndex(parentId);
    const parentNode = this.get(parentId);

    const index = this.build(obj);
    index.parent = parentId;

    parentNode.children = parentNode.children || [];
    parentIndex.children = parentIndex.children || [];

    parentNode.children.splice(i, 0, obj);
    parentIndex.children.splice(i, 0, index.id);

    this.updateChildren(parentIndex.children);
    if (parentIndex.parent) {
      this.updateChildren(this.getIndex(parentIndex.parent).children);
    }

    return index;
  }

  insertBefore(obj: TreeNode, destId: TreeId): TreeIndex {
    const destIndex = this.getIndex(destId);
    const parentId = destIndex.parent;
    const i = this.getIndex(parentId).children.indexOf(destId);
    return this.insert(obj, parentId, i);
  }

  insertAfter(obj: TreeNode, destId: TreeId): TreeIndex {
    const destIndex = this.getIndex(destId);
    const parentId = destIndex.parent;
    const i = this.getIndex(parentId).children.indexOf(destId);
    return this.insert(obj, parentId, i+1);
  }

  prepend(obj: TreeNode, destId: TreeId): TreeIndex {
    return this.insert(obj, destId, 0);
  }

  append(obj: TreeNode, destId: TreeId): TreeIndex {
    const destIndex = this.getIndex(destId);
    destIndex.children = destIndex.children || [];
    return this.insert(obj, destId, destIndex.children.length);
  }

  // react-ui-tree methods

  updateNodesPosition() {
    let top = 1;
    let left = 1;
    const root = this.getIndex(1);

    root.top = top++;
    root.left = left++;

    const walk = (
      children: TreeIndex[], parent: TreeIndex, left: number, collapsed: boolean
    ) => {
      let height = 1;
      children.forEach((id: TreeId) => {
        const node = this.getIndex(id);
        if (collapsed) {
          node.top = null;
          node.left = null;
        } else {
          node.top = top++;
          node.left = left;
        }

        if (node.children && node.children.length) {
          height += walk(
            node.children,
            node,
            left+1,
            collapsed || node.node.collapsed
          );
        } else {
          node.height = 1;
          height += 1;
        }
      });

      if(parent.node.collapsed) parent.height = 1;
      else parent.height = height;
      return parent.height as number;
    };

    if (root.children && root.children.length) {
      walk(root.children, root, left, root.node.collapsed);
    }
  }

  move(fromId: TreeId, toId: TreeId, placement: MovePlacement): TreeIndex {
    if (fromId === toId || toId === 1) {
      return;
    }

    const obj = this.remove(fromId);
    let index: TreeIndex;

    if (placement === "before") {
      index = this.insertBefore(obj, toId);
    } else if (placement === "after") {
      index = this.insertAfter(obj, toId);
    } else if(placement === "prepend") {
      index = this.prepend(obj, toId);
    } else if(placement === "append") {
      index = this.append(obj, toId);
    }

    // todo: perf
    this.updateNodesPosition();
    return index;
  }

  getParent(id: string) {
    const indexes = this.indexes;
    if (Object.prototype.hasOwnProperty.call(indexes, id)) {
      return this.getIndex(indexes[id].parent);
    }
  }

  getNodeByTop(top) {
    const indexes = this.indexes;
    for(const id in indexes) {
      if (Object.prototype.hasOwnProperty.call(indexes, id)) {
        if(indexes[id].top === top) {
          return indexes[id];
        }
      }
    }
  }
}
