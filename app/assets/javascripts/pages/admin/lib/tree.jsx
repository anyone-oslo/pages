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
class Tree {
  constructor(obj) {
    this.cnt = 1;
    this.obj = obj || { children: [] };
    this.indexes = {};
    this.build(this.obj);
  }

  build(obj) {
    var indexes = this.indexes;
    var startId = this.cnt;
    var self = this;

    var index = { id: startId, node: obj };
    indexes[this.cnt + ''] = index;
    this.cnt++;

    if (obj.children && obj.children.length) {
      walk(obj.children, index);
    }

    function walk(objs, parent) {
      var children = [];
      objs.forEach(function(obj, i) {
        var index = {};
        index.id = self.cnt;
        index.node = obj;

        if (parent) {
          index.parent = parent.id;
        }

        indexes[self.cnt + ''] = index;
        children.push(self.cnt);
        self.cnt++;

        if (obj.children && obj.children.length) {
          walk(obj.children, index);
        }
      });
      parent.children = children;

      children.forEach(function(id, i) {
        var index = indexes[id + ''];
        if (i > 0) {
          index.prev = children[i - 1];
        }
        if (i < children.length-1) {
          index.next = children[i+1];
        }
      });
    }

    return index;
  }

  getIndex(id) {
    var index = this.indexes[id + ''];
    if (index) {
      return index;
    }
  }

  removeIndex(index) {
    var self = this;
    del(index);

    function del(index) {
      delete self.indexes[index.id + ''];
      if (index.children && index.children.length) {
        index.children.forEach(function(child) {
          del(self.getIndex(child));
        });
      }
    }
  }

  get(id) {
    var index = this.getIndex(id);
    if (index && index.node) {
      return index.node;
    }
    return null;
  }

  remove(id) {
    var index = this.getIndex(id);
    var node = this.get(id);
    var parentIndex = this.getIndex(index.parent);
    var parentNode = this.get(index.parent);
    parentNode.children.splice(parentNode.children.indexOf(node), 1);
    parentIndex.children.splice(parentIndex.children.indexOf(id), 1);
    this.removeIndex(index);
    this.updateChildren(parentIndex.children);

    return node;
  }

  updateChildren(children) {
    children.forEach(function(id, i) {
      var index = this.getIndex(id);
      index.prev = index.next = null;
      if (i > 0) {
        index.prev = children[i-1];
      }
      if (i < children.length-1) {
        index.next = children[i+1];
      }
    }.bind(this));
  }

  insert(obj, parentId, i) {
    var parentIndex = this.getIndex(parentId);
    var parentNode = this.get(parentId);

    var index = this.build(obj);
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

  insertBefore(obj, destId) {
    var destIndex = this.getIndex(destId);
    var parentId = destIndex.parent;
    var i = this.getIndex(parentId).children.indexOf(destId);
    return this.insert(obj, parentId, i);
  }

  insertAfter(obj, destId) {
    var destIndex = this.getIndex(destId);
    var parentId = destIndex.parent;
    var i = this.getIndex(parentId).children.indexOf(destId);
    return this.insert(obj, parentId, i+1);
  }

  prepend(obj, destId) {
    return this.insert(obj, destId, 0);
  }

  append(obj, destId) {
    var destIndex = this.getIndex(destId);
    destIndex.children = destIndex.children || [];
    return this.insert(obj, destId, destIndex.children.length);
  }

  // react-ui-tree methods

  updateNodesPosition() {
    var top = 1;
    var left = 1;
    var root = this.getIndex(1);
    var self = this;

    root.top = top++;
    root.left = left++;

    if (root.children && root.children.length) {
      walk(root.children, root, left, root.node.collapsed);
    }

    function walk(children, parent, left, collapsed) {
      var height = 1;
      children.forEach(function(id) {
        var node = self.getIndex(id);
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
      return parent.height;
    }
  }

  move(fromId, toId, placement) {
    if (fromId === toId || toId === 1) {
      return;
    }

    var obj = this.remove(fromId);
    var index = null;

    if (placement === 'before') {
      index = this.insertBefore(obj, toId);
    } else if (placement === 'after') {
      index = this.insertAfter(obj, toId);
    } else if(placement === 'prepend') {
      index = this.prepend(obj, toId);
    } else if(placement === 'append') {
      index = this.append(obj, toId);
    }

    // todo: perf
    this.updateNodesPosition();
    return index;
  }

  getParent(id) {
    var indexes = this.indexes;
    if (indexes.hasOwnProperty(id)) {
      return this.getIndex(indexes[id].parent);
    }
  }

  getNodeByTop(top) {
    var indexes = this.indexes;
    for(var id in indexes) {
      if (indexes.hasOwnProperty(id)) {
        if(indexes[id].top === top) {
          return indexes[id];
        }
      }
    }
  }
}
