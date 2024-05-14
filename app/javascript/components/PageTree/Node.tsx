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

import React, {
  createRef,
  ChangeEvent,
  Component,
  CSSProperties,
  FormEvent,
  MouseEvent,
  RefObject
} from "react";

import Tree from "../../lib/Tree";
import * as Trees from "../../types/Trees";
import * as Pages from "../../types/Pages";

import PageName from "./PageName";

interface Props {
  index: Trees.Index<Pages.TreeNode>;
  paddingLeft: number;
  tree: Tree<Pages.TreeNode>;
  addChild?: (index: Trees.Index<Pages.TreeNode>) => void;
  dir?: string;
  dragging?: Trees.Id;
  locale: string;
  onCollapse?: (id: Trees.Id) => void;
  onDragStart?: (id: number, element: HTMLDivElement, evt: MouseEvent) => void;
  updatePage?: (
    index: Trees.Index<Pages.TreeNode>,
    attributes: Partial<Pages.TreeItem>
  ) => void;
}

interface State {
  newName: string;
}

interface ButtonOptions {
  icon: string;
  className: string;
  onClick: (evt: MouseEvent) => void;
}

export default class Node extends Component<Props, State> {
  innerRef: RefObject<HTMLDivElement>;

  constructor(props: Props) {
    super(props);
    this.state = { newName: this.pageName() };
    this.innerRef = createRef<HTMLDivElement>();
  }

  permitted(action: string): boolean {
    return (
      this.node().permissions && this.node().permissions.indexOf(action) != -1
    );
  }

  actions() {
    const statusLabel = this.node().status != 2 ? "Publish" : "Hide";
    const statusIcon = this.node().status != 2 ? "check" : "ban";

    if (this.node().editing) {
      return null;
    }

    if (this.props.index.id === 1) {
      return (
        <span className="actions">
          <button
            type="button"
            className="add"
            onClick={() => this.props.addChild(this.props.index)}>
            <i className="fa-solid fa-plus icon" />
            Add child
          </button>
        </span>
      );
    } else {
      return (
        <span className="actions">
          {this.permitted("edit") &&
            this.button(statusLabel, {
              className: "toggle-status",
              icon: statusIcon,
              onClick: () => this.toggleStatus()
            })}

          {this.permitted("edit") &&
            this.button("Rename", {
              className: "edit",
              icon: "pencil",
              onClick: () => this.edit()
            })}

          {this.permitted("edit") &&
            this.button("Delete", {
              className: "delete",
              icon: "trash",
              onClick: () => this.deletePage()
            })}

          {this.permitted("create") &&
            this.button("Add child", {
              className: "add",
              icon: "plus",
              onClick: () => this.props.addChild(this.props.index)
            })}
        </span>
      );
    }
  }

  addButton() {
    const node = this.node();
    const handleClick = () => {
      if (this.props.addChild) {
        this.props.addChild(this.props.index);
      }
    };

    if (
      !node.collapsed &&
      this.permitted("create") &&
      (node.root || this.visibleChildren().length > 0)
    ) {
      return this.button("Add page here", {
        className: "add add-inline transparent",
        icon: "plus",
        onClick: handleClick
      });
    }
  }

  button(label: string, options: ButtonOptions) {
    const icon = "fa-solid fa-" + options.icon + " icon";
    return (
      <button
        type="button"
        className={options.className}
        onClick={options.onClick}>
        <i className={icon} />
        {label}
      </button>
    );
  }

  childNodes() {
    const { index, tree, dragging, dir, locale } = this.props;

    if (index.children && index.children.length && !index.node.collapsed) {
      const childrenStyles: CSSProperties = {};
      if (index.node.collapsed) {
        childrenStyles.display = "none";
      }
      childrenStyles["paddingLeft"] = `${this.props.paddingLeft}px`;

      return (
        <div className="children" style={childrenStyles}>
          {index.children.map((child) => {
            const childIndex = tree.getIndex(child);
            return (
              <Node
                tree={tree}
                index={childIndex}
                key={childIndex.id}
                dragging={dragging}
                paddingLeft={this.props.paddingLeft}
                addChild={this.props.addChild}
                onCollapse={this.props.onCollapse}
                onDragStart={this.props.onDragStart}
                updatePage={this.props.updatePage}
                dir={dir}
                locale={locale}
              />
            );
          })}
        </div>
      );
    }

    return null;
  }

  collapseArrow() {
    const index = this.props.index;

    // Don't collapse the root node
    if (!index.parent) {
      return null;
    }

    const handleCollapse = (e: MouseEvent) => {
      e.stopPropagation();
      const nodeId = this.props.index.id;
      if (this.props.onCollapse) {
        this.props.onCollapse(nodeId);
      }
    };

    if (this.visibleChildren().length > 0) {
      const collapsed = index.node.collapsed;
      const classnames = ["collapse fa-solid fa-caret-right"];

      if (collapsed) {
        classnames.push("collapsed");
      } else {
        classnames.push("open");
      }

      return (
        <i
          className={classnames.join(" ")}
          onMouseDown={function (e) {
            e.stopPropagation();
          }}
          onClick={handleCollapse}
        />
      );
    }

    return null;
  }

  collapsedLabel() {
    if (
      this.node().collapsed &&
      this.node().children &&
      this.node().children.length > 0
    ) {
      const pluralized = this.node().children.length == 1 ? "item" : "items";
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
      this.updatePage({ status: 4 });
    }
  }

  edit() {
    this.updatePage({ editing: true });
  }

  editUrl(page: Pages.TreeNode) {
    return `/admin/${this.props.locale}/pages/${page.id}/edit`;
  }

  node(): Pages.TreeNode {
    return this.props.index.node;
  }

  pageName() {
    return this.node().blocks.name[this.props.locale];
  }

  render() {
    const props = this.props;
    const index = props.index;
    const dragging = props.dragging;
    const editing = this.node().editing;
    let classnames = "node";

    const node = editing ? this.renderEditNode() : this.renderNode();

    if (index.id === dragging) {
      classnames = "node placeholder";
    }

    const handleMouseDown = (e: MouseEvent) => {
      if (this.permitted("edit") && !editing && props.onDragStart) {
        props.onDragStart(props.index.id, this.innerRef.current, e);
      }
    };

    if (this.node().status != 4) {
      return (
        <div className={classnames}>
          <div
            className="inner"
            ref={this.innerRef}
            onMouseDown={handleMouseDown}>
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
    const { dir, locale } = this.props;

    const handleNameChange = (event: ChangeEvent<HTMLInputElement>) => {
      this.setState({ newName: event.target.value });
    };

    const performEdit = (event: FormEvent) => {
      event.preventDefault();
      this.updatePage({
        blocks: { name: { [locale]: this.state.newName } },
        editing: false
      });
    };

    const cancelEdit = () => {
      this.setState({ newName: this.pageName() });
      this.updatePage({ editing: false });
    };

    return (
      <div className="page edit">
        <i className="fa-regular fa-file icon"></i>
        <form className="edit-name" onSubmit={performEdit}>
          <input
            className="tight"
            type="text"
            value={this.state.newName}
            dir={dir}
            lang={locale}
            autoFocus
            onChange={handleNameChange}
          />
          <button className="save primary" type="submit">
            <i className="fa-solid fa-cloud icon"></i>
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
    const index = this.props.index;
    const node = index.node;

    let className = "page";

    let iconClass = "fa-regular fa-file icon";

    if (typeof node.status != "undefined") {
      className = `page status-${this.node().status}`;
    }

    if (node.news_page) {
      iconClass = "fa-regular fa-file-lines page-icon";
    } else if (node.pinned) {
      iconClass = "fa-regular fa-flag page-icon";
    }

    return (
      <div className={className}>
        <i className={iconClass}></i>
        <PageName
          name={this.pageName()}
          dir={this.props.dir}
          locale={this.props.locale}
          editUrl={node.id && this.permitted("edit") && this.editUrl(node)}
        />
        {this.statusLabel()}
        {this.collapsedLabel()}
        {this.actions()}
      </div>
    );
  }

  statusLabel() {
    const labels = ["Draft", "Reviewed", "Published", "Hidden", "Deleted"];
    if (typeof this.node().status != "undefined" && this.node().status != 2) {
      return (
        <span className="status-label">({labels[this.node().status]})</span>
      );
    } else {
      return "";
    }
  }

  toggleStatus() {
    if (this.node().status != 2) {
      this.updatePage({ status: 2 });
    } else {
      this.updatePage({ status: 3 });
    }
  }

  updatePage(attributes: Partial<Pages.TreeItem>) {
    if (this.props.updatePage) {
      return this.props.updatePage(this.props.index, attributes);
    }
  }

  visibleChildren(): Pages.TreeNode[] {
    if (this.node().children) {
      return this.node().children.filter((p) => p.status != 4);
    } else {
      return [];
    }
  }
}
