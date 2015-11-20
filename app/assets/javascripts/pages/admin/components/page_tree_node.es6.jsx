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
  actions() {
    var statusLabel = (this.node().status != 2) ? "Publish" : "Hide";
    var statusIcon = "icon fa fa-" + ((this.node().status != 2) ? "check" : "ban");

    return (
      <span className="actions">
        <button type="button"
                className="toggle-status"
                onClick={e => this.toggleStatus()}>
          <i className={statusIcon} />
          {statusLabel}
        </button>

        <button type="button"
                className="delete"
                onClick={e => this.deletePage()}>
          <i className="fa fa-trash icon" />
          Delete
        </button>

        <button type="button"
                className="add"
                onClick={e => this.props.addChild(this.props.index)}>
          <i className="fa fa-plus icon" />
          Add child
        </button>
      </span>
    );
  }

  addButton() {
    var self = this;
    var node = this.node();
    var handleClick = function (e) {
      if (self.props.addChild) {
        self.props.addChild(self.props.index);
      }
    }

    if (!node.collapsed && this.visibleChildren.length > 0) {
      return (
        <button className="add add-inline"
                onClick={handleClick}>
          <i className="fa fa-plus icon" />
          Add page here
        </button>
      );
    }
  }

  childNodes() {
    var index = this.props.index;
    var tree = this.props.tree;
    var dragging = this.props.dragging;

    if (index.children && index.children.length && !index.node.collapsed) {
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
                   addChild={this.props.addChild}
                   onCollapse={this.props.onCollapse}
                   onDragStart={this.props.onDragStart}
                   updatePage={this.props.updatePage}
               />
             );
           })}
        </div>
      );
    }

    return null;
  }

  collapseArrow() {
    var index = this.props.index;
    var self = this;

    var handleCollapse = function (e) {
      e.stopPropagation();
      var nodeId = self.props.index.id;
      if (self.props.onCollapse) {
        self.props.onCollapse(nodeId);
      }
    }

    if (this.visibleChildren().length > 0) {
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

  collapsedLabel() {
    if (this.node().collapsed) {
      var pluralized = (this.node().children.length == 1) ? "item" : "items";
      return (
        <span className="collapsed-label">
          ({this.node().children.length} {pluralized})
        </span>
      );
    } else {
      return null;
    }
  }

  deletePage() {
    if (confirm("Are you sure you want to delete this page?")) {
      this.updatePage({status: 4});
    }
  }

  editUrl(page) {
    return(`/admin/${page.locale}/pages/${page.param}/edit`)
  }

  node() {
    return this.props.index.node;
  }

  pageName() {
    if (this.node().name) {
      return this.node().name;
    } else {
      return <i className="untitled">Untitled</i>;
    }
  }

  render() {
    var self = this;
    var props = this.props;
    var index = props.index;
    var dragging = props.dragging;
    var classnames = "node";

    if (index.id === dragging) {
      classnames = "node placeholder";
    }

    var handleMouseDown = function (e) {
      var dom = self.refs.inner;

      if (props.onDragStart) {
        props.onDragStart(props.index.id, dom, e);
      }
    }

    if (this.node().status != 4) {
      return (
        <div className={classnames}>
          <div className="inner" ref="inner" onMouseDown={handleMouseDown}>
            {this.collapseArrow()}
            {this.renderNode()}
          </div>
          {this.childNodes()}
          {this.addButton()}
        </div>
      );
    } else {
      return null;
    }
  }

  renderNode() {
    var self = this;
    var index = this.props.index;
    var node = index.node;
    var className = `page status-${this.node().status}`;

    return (
      <div className={className}>
        <i className="fa fa-file-o icon"></i>
        <a href={this.editUrl(node)} className="name">
          {this.pageName()}
        </a>
        {this.statusLabel()}
        {this.collapsedLabel()}
        {this.actions()}
      </div>
    );
  }

  statusLabel() {
    let labels = ["Draft", "Reviewed", "Published", "Hidden", "Deleted"];
    if (typeof(this.node().status) != "undefined" && this.node().status != 2) {
      return (
        <span className="status-label">
          ({labels[this.node().status]})
        </span>
      );
    } else {
      return "";
    }
  }

  toggleStatus() {
    if (this.node().status != 2) {
      this.updatePage({status: 2});
    } else {
      this.updatePage({status: 3});
    }
  }

  updatePage(attributes) {
    if (this.props.updatePage) {
      return this.props.updatePage(this.props.index, attributes);
    }
  }

  visibleChildren() {
    return this.node().children.filter(p => p.status != 4);
  }
}
