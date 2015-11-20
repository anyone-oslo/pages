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

class PageTree extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.init(this.props);
  }

  componentWillReceiveProps(nextProps) {
    if (!this._updated) {
      this.setState(this.init(nextProps));
    } else {
      this._updated = false;
    }
  }

  init(props) {
    var tree = new Tree(props.tree);
    tree.isNodeCollapsed = props.isNodeCollapsed;
    tree.changeNodeCollapsed = props.changeNodeCollapsed;
    tree.updateNodesPosition();

    return {
      tree: tree,
      dragging: {
        id: null,
        x: null,
        y: null,
        w: null,
        h: null
      }
    };
  }

  getDraggingDom() {
    var tree = this.state.tree;
    var dragging = this.state.dragging;
    if (dragging && dragging.id) {
      var draggingIndex = tree.getIndex(dragging.id);
      var draggingStyles = {
        top: dragging.y,
        left: dragging.x,
        width: dragging.w
      };

      return (
        <div className="draggable" style={draggingStyles}>
          <PageTreeNode
              tree={tree}
              index={draggingIndex}
              paddingLeft={this.props.paddingLeft}
          />
        </div>
      );
    }

    return null;
  }

  render() {
    var self = this;
    var tree = this.state.tree;
    var dragging = this.state.dragging;
    var root = tree.getIndex(1);

    return (
      <div className="page-tree">
        {this.getDraggingDom()}
        {root.children.map((child) => {
           var childIndex = tree.getIndex(child);
           return (
             <PageTreeNode
                 tree={tree}
                 index={childIndex}
                 key={childIndex.id}
                 paddingLeft={this.props.paddingLeft}
                 addChild={id => this.addChild(id)}
                 onDragStart={(id, dom, e) => this.dragStart(id, dom, e)}
                 onCollapse={nodeId => this.toggleCollapse(nodeId)}
                 updatePage={(idx, attrs) => this.updatePage(idx, attrs)}
                 dragging={dragging && dragging.id}
             />
           );
         })}
      </div>
    );
  }

  addChild(parent) {
    let newNode = { name: "", status: 0, children: [] };
    var tree = this.state.tree;
    tree.append(newNode, parent.id);
    this.updatePage(parent, { collapsed: false });
    this.setState({tree: tree});
    this.change(tree);
  }

  drag(e) {
    if (this._start) {
      var distance = Math.abs(e.clientX - this._offsetX) +
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

    var tree = this.state.tree;
    var dragging = this.state.dragging;
    var paddingLeft = this.props.paddingLeft;
    var newIndex = null;
    var index = tree.getIndex(dragging.id);
    var collapsed = index.node.collapsed;

    var _startX = this._startX;
    var _startY = this._startY;
    var _offsetX = this._offsetX;
    var _offsetY = this._offsetY;

    var pos = {
      x: _startX + e.clientX - _offsetX,
      y: _startY + e.clientY - _offsetY
    };
    dragging.x = pos.x;
    dragging.y = pos.y;

    var diffX = dragging.x - paddingLeft/2 - (index.left-2) * paddingLeft;
    var diffY = dragging.y - dragging.h/2 - (index.top-2) * dragging.h;

    if (diffX < 0) {
      // left
      if (index.parent && !index.next) {
        newIndex = tree.move(index.id, index.parent, 'after');
      }
    } else if (diffX > paddingLeft) {
      // right
      if (index.prev) {
        var prev = tree.getIndex(index.prev);

        if (!prev.node.leaf && !prev.node.collapsed) {
          newIndex = tree.move(index.id, index.prev, 'append');
        }
      }
    }

    if (newIndex) {
      index = newIndex;
      newIndex.node.collapsed = collapsed;
      dragging.id = newIndex.id;
    }

    if (diffY < 0) {
      // up
      var above = tree.getNodeByTop(index.top-1);
      newIndex = tree.move(index.id, above.id, 'before');
    } else if (diffY > dragging.h) {
      // down
      if (index.next) {
        var below = tree.getIndex(index.next);
        if (below.children && below.children.length && !below.node.collapsed) {
          newIndex = tree.move(index.id, index.next, 'prepend');
        } else {
          newIndex = tree.move(index.id, index.next, 'after');
        }
      } else {
        var below = tree.getNodeByTop(index.top + index.height);
        if (below && below.parent !== index.id) {
          if (below.children && below.children.length && !below.node.collapsed) {
            newIndex = tree.move(index.id, below.id, 'prepend');
          } else {
            newIndex = tree.move(index.id, below.id, 'after');
          }
        }
      }
    }

    if (newIndex) {
      newIndex.node.collapsed = collapsed;
      dragging.id = newIndex.id;
    }

    this.setState({
      tree: tree,
      dragging: dragging
    });
  }

  dragStart(id, dom, e) {
    this.dragging = {
      id: id,
      w: dom.offsetWidth,
      h: dom.offsetHeight,
      x: dom.offsetLeft,
      y: dom.offsetTop
    };

    this._startX = dom.offsetLeft;
    this._startY = dom.offsetTop;
    this._offsetX = e.clientX;
    this._offsetY = e.clientY;
    this._start = true;

    var self = this;
    this._dragListener = (e) => self.drag(e);
    this._dragEndListener = () => self.dragEnd();

    window.addEventListener('mousemove', this._dragListener);
    window.addEventListener('mouseup', this._dragEndListener);
  }

  dragEnd() {
    this.setState({
      dragging: {
        id: null,
        x: null,
        y: null,
        w: null,
        h: null
      }
    });

    this.change(this.state.tree);
    window.removeEventListener('mousemove', this._dragListener);
    window.removeEventListener('mouseup', this._dragEndListener);
  }

  toggleCollapse(nodeId) {
    var tree = this.state.tree;
    var index = tree.getIndex(nodeId);
    var node = index.node;
    node.collapsed = !node.collapsed;
    tree.updateNodesPosition();

    this.setState({
      tree: tree
    });

    this.change(tree);
  }

  change(tree) {
    this._updated = true;
    if (this.props.onChange) {
      this.props.onChange(tree.obj);
    }
  }

  updatePage(index, attributes) {
    var tree = this.state.tree;

    for (var attr in attributes) {
      if (attributes.hasOwnProperty(attr)) {
        index.node[attr] = attributes[attr];
      }
    }

    this.setState({tree: tree});
    this.change(tree);
  }
}

PageTree.propTypes = {
  tree: React.PropTypes.object.isRequired,
  paddingLeft: React.PropTypes.number
};

PageTree.defaultProps = {
  paddingLeft: 15
};
