import React from "react";
import PropTypes from "prop-types";
import PageTreeDraggable from "./PageTreeDraggable";
import Tree from "../lib/Tree";
import { postJson, putJson } from "../lib/request";

export default class PageTree extends React.Component {
  constructor(props) {
    super(props);

    this.state = { tree: this.buildTree(props.pages) };

    this.addChild = this.addChild.bind(this);
    this.movedPage = this.movedPage.bind(this);
    this.toggleCollapsed = this.toggleCollapsed.bind(this);
    this.updatePage = this.updatePage.bind(this);
    this.updateTree = this.updateTree.bind(this);
  }

  addChild(id, attributes) {
    let tree = this.state.tree;
    var index = tree.append(attributes, id);
    this.reorderChildren(id);
    this.setCollapsed(id, false);
    this.createPage(index, attributes);
    this.setState({tree: tree});
  }

  movedPage(id) {
    let tree = this.state.tree;
    let index = tree.getIndex(id);
    this.reorderChildren(index.parent);

    let parent = tree.getIndex(index.parent);
    let position = parent.children.indexOf(id) + 1;

    this.movePage(index, parent, position);
    this.setState({tree: tree});
  }

  toggleCollapsed(id) {
    let tree = this.state.tree;
    var node = tree.getIndex(id).node;
    this.setCollapsed(id, !node.collapsed);
    this.setState({tree: tree});
  }

  updatePage(id, attributes) {
    let tree = this.state.tree;
    let index = tree.getIndex(id);
    let url = `/admin/${index.node.locale}/pages/${index.node.id}.json`;
    this.updateNode(index, attributes);
    this.performUpdate(index, url, { page: attributes });
  }

  updateTree(tree) {
    this.setState({ tree: tree });
  }

  applyCollapsed(tree) {
    const depth = (t, index) => {
      var depth = 0;
      let pointer = t.getIndex(index.parent);
      while (pointer) {
        depth += 1;
        pointer = t.getIndex(pointer.parent);
      }
      return depth;
    };

    let collapsedState = this.collapsedState();
    let walk = function (id) {
      var index = tree.getIndex(id);
      var node = index.node;
      if (Object.prototype.hasOwnProperty.call(collapsedState, node.id)) {
        node.collapsed = collapsedState[node.id];
      } else if (node.news_page) {
        node.collapsed = true;
      } else if (depth(tree, index) > 1) {
        node.collapsed = true;
      }
      if (index.children && index.children.length) {
        index.children.forEach(c => walk(c));
      }
    };
    walk(1);
  }

  collapsedState() {
    if (window && window.localStorage &&
        typeof(window.localStorage.collapsedPages) != "undefined") {
      return JSON.parse(window.localStorage.collapsedPages);
    }
    return {};
  }

  createPage(index, attributes) {
    postJson(`/admin/${index.node.locale}/pages.json`, { page: attributes })
      .then(response => this.updateNode(index, response));
  }

  buildTree(pages) {
    // Build tree
    let parentMap = pages.reduce((m, page) => {
      let id = page.parent_page_id;
      m[id] = [...(m[id] || []), page];
      return m;
    }, {});

    pages.forEach((p) => p.children = parentMap[p.id] || []);

    let tree = new Tree({ name: "All Pages",
                          locale: this.props.locale,
                          permissions: this.props.permissions,
                          root: true,
                          children: parentMap[null] });
    this.applyCollapsed(tree);
    tree.updateNodesPosition();
    return tree;
  }

  movePage(index, parent, position) {
    let data = {
      parent_id: parent.node.id,
      position: position
    };
    let url = `/admin/${index.node.locale}/pages/${index.node.id}/move.json`;
    this.performUpdate(index, url, data);
  }

  performUpdate(index, url, data) {
    putJson(url, data).then(response => this.updateNode(index, response));
  }

  render() {
    return(
      <PageTreeDraggable tree={this.state.tree}
                         addChild={this.addChild}
                         movedPage={this.movedPage}
                         toggleCollapsed={this.toggleCollapsed}
                         updatePage={this.updatePage}
                         updateTree={this.updateTree} />
    );
  }

  reorderChildren(id) {
    let tree = this.state.tree;
    var index = this.state.tree.getIndex(id);
    var node = index.node;
    if (!node.news_page) {
      return;
    }
    index.children = index.children.sort(function (a, b) {
      var aNode = tree.getIndex(a).node;
      var bNode = tree.getIndex(b).node;
      if (aNode.pinned == bNode.pinned) {
        return new Date(bNode.published_at) - new Date(aNode.published_at);
      } else {
        return aNode.pinned ? -1 : 1;
      }
    });
    tree.updateNodesPosition();
  }

  setCollapsed(id, value) {
    var node = this.state.tree.getIndex(id).node;
    node.collapsed = value;
    this.storeCollapsed(id, node.collapsed);
    this.state.tree.updateNodesPosition();
  }

  storeCollapsed(id, newState) {
    let node = this.state.tree.getIndex(id).node;
    var store = this.collapsedState();
    store[node.id] = newState;
    window.localStorage.collapsedPages = JSON.stringify(store);
  }

  updateNode(index, attributes) {
    for (var attr in attributes) {
      if (Object.prototype.hasOwnProperty.call(attributes, attr)) {
        index.node[attr] = attributes[attr];
      }
    }
    this.setState({ tree: this.state.tree });
  }
}

PageTree.propTypes = {
  pages: PropTypes.array,
  locale: PropTypes.string,
  permissions: PropTypes.array
};
