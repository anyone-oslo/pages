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
  constructor(props) {
    super(props);
    this.state = { newName: props.index.node.name };
  }

  permitted(action) {
    return this.node().permissions &&
           this.node().permissions.indexOf(action) != -1;
  }

  actions() {
    let statusLabel = (this.node().status != 2) ? "Publish" : "Hide";
    let statusIcon = (this.node().status != 2) ? "check" : "ban";

    if (this.node().editing) {
      return null;
    }

    if (this.props.index.id === 1) {
      return (
        <span className="actions">
          <button type="button"
                  className="add"
                  onClick={e => this.props.addChild(this.props.index)}>
            <i className="fa fa-plus icon" />
            Add child
          </button>
        </span>
      );
    } else {
      return (
        <span className="actions">
          {this.permitted("edit") && this.button(statusLabel, {
             className: "toggle-status",
             icon: statusIcon,
             onClick: e => this.toggleStatus()
           })}

          {this.permitted("edit") && this.button("Rename", {
             className: "edit",
             icon: "pencil",
             onClick: e => this.edit()
           })}

          {this.permitted("edit") && this.button("Delete", {
             className: "delete",
             icon: "trash",
             onClick: e => this.deletePage()
           })}

          {this.permitted("create") && this.button("Add child", {
             className: "add",
             icon: "plus",
             onClick: e => this.props.addChild(this.props.index)
           })}
        </span>
      );
    }
  }

  addButton() {
    let self = this;
    let node = this.node();
    let handleClick = function (e) {
      if (self.props.addChild) {
        self.props.addChild(self.props.index);
      }
    }

    if (!node.collapsed &&
        this.permitted("create") &&
        (node.root || this.visibleChildren().length > 0)) {
      return (
        this.button("Add page here", {
          className: "add add-inline",
          icon: "plus",
          onClick: handleClick
        })
      );
    }
  }

  button(label, options) {
    let icon = "fa fa-" + options.icon + " icon";
    return (
      <button type="button"
              className={options.className}
              onClick={options.onClick}>
        <i className={icon} />
        {label}
      </button>
    );
  }

  childNodes() {
    let index = this.props.index;
    let tree = this.props.tree;
    let dragging = this.props.dragging;

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
    let index = this.props.index;
    let self = this;

    // Don't collapse the root node
    if (!index.parent) {
      return null;
    }

    let handleCollapse = function (e) {
      e.stopPropagation();
      let nodeId = self.props.index.id;
      if (self.props.onCollapse) {
        self.props.onCollapse(nodeId);
      }
    }

    if (this.visibleChildren().length > 0) {
      let collapsed = index.node.collapsed;
      var classnames = null;

      if (collapsed) {
        classnames = "collapse fa fa-caret-right";
      } else {
        classnames = "collapse fa fa-caret-down";
      }

      return (
        <i className={classnames}
           onMouseDown={function(e) {e.stopPropagation()}}
           onClick={handleCollapse} />
      );
    }

    return null;
  }

  collapsedLabel() {
    if (this.node().collapsed &&
        this.node().children &&
        this.node().children.length > 0) {
      let pluralized = (this.node().children.length == 1) ? "item" : "items";
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

  edit() {
    this.updatePage({editing: true});
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
    let self = this;
    let props = this.props;
    let index = props.index;
    let dragging = props.dragging;
    let editing = this.node().editing;
    var classnames = "node";

    var node = editing ? this.renderEditNode() : this.renderNode();

    if (index.id === dragging) {
      classnames = "node placeholder";
    }

    let handleMouseDown = function (e) {
      if (self.permitted("edit") && !editing && props.onDragStart) {
        props.onDragStart(props.index.id, self.refs.inner, e);
      }
    }

    if (this.node().status != 4) {
      return (
        <div className={classnames}>
          <div className="inner" ref="inner" onMouseDown={handleMouseDown}>
            {this.collapseArrow()}
            {node}
          </div>
          {this.childNodes()}
          {this.addButton()}
        </div>
      );
    } else {
      return null;
    }
  }

  renderEditNode() {
    let self = this;

    let handleNameChange = function(event) {
      self.setState({newName: event.target.value});
    }

    let performEdit = function(event) {
      event.preventDefault();
      self.updatePage({
        name: self.state.newName,
        editing: false
      });
    }

    let cancelEdit = function(e) {
      self.setState({newName: self.node().name});
      self.updatePage({editing: false});
    }

    return (
      <div className="page edit">
        <i className="fa fa-file-o icon"></i>
        <form onSubmit={performEdit}>
          <input type="text"
                 value={this.state.newName}
                 autoFocus
                 ref="nameInput"
                 onChange={handleNameChange} />
          <button className="save" type="submit">
            <i className="fa fa-cloud icon"></i>
            Save
          </button>
          {this.button("Cancel", {
             className: "cancel",
             icon: "ban",
             onClick: cancelEdit
           })}
        </form>
      </div>
    );
  }

  renderNode() {
    let self = this;
    let index = this.props.index;
    let node = index.node;

    var dateLabel = "";
    var pageName = <span className="name">{this.pageName()}</span>;
    var className = "page";

    var iconClass = "fa fa-file-o icon";

    if (typeof(node.status) != "undefined") {
      className = `page status-${this.node().status}`;
    }

    if (node.id && node.locale && this.permitted("edit")) {
      pageName = <a href={this.editUrl(node)} className="name">
        {this.pageName()}
      </a>;
    }

    if (node.id && node.starts_at) {
      dateLabel = <span className="date">
        {node.starts_at}
      </span>
    }

    if (node.news_page) {
      iconClass = "fa fa-newspaper-o icon";
    } else if (node.pinned) {
      iconClass = "fa fa-flag-o icon";
    }

    return (
      <div className={className}>
        <i className={iconClass}></i>
        {pageName}
        {dateLabel}
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
    if (this.node().children) {
      return this.node().children.filter(p => p.status != 4);
    } else {
      return [];
    }
  }
}
