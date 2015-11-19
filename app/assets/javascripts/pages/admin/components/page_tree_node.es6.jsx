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

class PageTreeNode extends React.Component {
  renderCollapse() {
    var index = this.props.index;
    var self = this;

    var handleCollapse = function (e) {
      e.stopPropagation();
      var nodeId = self.props.index.id;
      if (self.props.onCollapse) {
        self.props.onCollapse(nodeId);
      }
    }

    if (index.children && index.children.length) {
      var classnames = null;
      var collapsed = index.node.collapsed;

      if (collapsed) {
        classnames = "collapse fa fa-caret-right";
      } else {
        classnames = "collapse fa fa-caret-down";
      }

      return (
        <i
        className={classnames}
        onMouseDown={function(e) {e.stopPropagation()}}
        onClick={handleCollapse}
        />
      );
    }

    return null;
  }

  renderChildren() {
    var index = this.props.index;
    var tree = this.props.tree;
    var dragging = this.props.dragging;

    if (index.children && index.children.length) {
      var childrenStyles = {};
      if (index.node.collapsed) {
        childrenStyles.display = 'none';
      }
      childrenStyles['paddingLeft'] = this.props.paddingLeft + 'px';

      return (
        <div className="children" style={childrenStyles}>
          {index.children.map((child) => {
             var childIndex = tree.getIndex(child);
             return (
               <PageTreeNode
                   tree={tree}
                   index={childIndex}
                   key={childIndex.id}
                   dragging={dragging}
                   paddingLeft={this.props.paddingLeft}
                   onCollapse={this.props.onCollapse}
                   onDragStart={this.props.onDragStart}
               />
             );
           })}
        </div>
      );
    }

    return null;
  }

  editUrl (page) {
    return(`/admin/${page.locale}/pages/${page.param}/edit`)
  }

  renderNode() {
    var index = this.props.index;
    var node = index.node;
    var collapsed = "";
    if (node.collapsed) {
      collapsed = <span className="collapsed-label">
          ({node.children.length} items)
      </span>;
    }
    return (
      <div className="page">
        <i className="fa fa-file-o icon"></i>
        <a href={this.editUrl(node)} className="name">
          {node.name}
        </a>
        {collapsed}
      </div>
    );
  }

  render() {
    var self = this;
    var tree = this.props.tree;
    var index = this.props.index;
    var dragging = this.props.dragging;
    var styles = {};
    var classnames = "node";

    if (index.id === dragging) {
      classnames = "node placeholder";
    }

    var handleMouseDown = function (e) {
      var nodeId = self.props.index.id;
      var dom = self.refs.inner;

      if(self.props.onDragStart) {
        self.props.onDragStart(nodeId, dom, e);
      }
    }

    return (
      <div className={classnames} style={styles}>
        <div className="inner" ref="inner" onMouseDown={handleMouseDown}>
          {this.renderCollapse()}
          {this.renderNode()}
        </div>
        {this.renderChildren()}
      </div>
    );
  }
}
