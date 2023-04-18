import React, { Component } from "react";
import Tree, { TreeId, TreeIndex } from "../lib/Tree";
import { postJson, putJson } from "../lib/request";
import { Attributes, PageNode } from "./PageTree/types";
import Draggable from "./PageTree/Draggable";

interface Page extends Record<string, unknown> {
  parent_page_id: number | null
}

type CollapsedState = Record<number, boolean>;

interface ParentMap {
  [index: number]: Page[]
}

interface PageTreeProps {
  dir: string,
  locale: string,
  pages: Page[],
  permissions: string[]
}

interface PageTreeState {
  tree: Tree<PageNode>
}

function collapsedState(): CollapsedState {
  if (window && window.localStorage &&
    typeof(window.localStorage.collapsedPages) != "undefined") {
      return JSON.parse(window.localStorage.getItem("collapsedPages")) as CollapsedState;
    }
  return {};
}

export default class PageTree extends Component<PageTreeProps, PageTreeState> {
  constructor(props: PageTreeProps) {
    super(props);

    this.state = { tree: this.buildTree(props.pages) };
  }

  applyCollapsed(tree: Tree<PageNode>) {
    const depth = (t: Tree, index: TreeIndex) => {
      let depth = 0;
      let pointer = t.getIndex(index.parent);
      while (pointer) {
        depth += 1;
        pointer = t.getIndex(pointer.parent);
      }
      return depth;
    };

    const walk = (id: TreeId) => {
      const index = tree.getIndex(id);
      const node = index.node;
      if (node.id && node.id in collapsedState()) {
        node.collapsed = collapsedState()[node.id];
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

  createPage(index: TreeIndex<PageNode>, attributes: Attributes) {
    void postJson(`/admin/${index.node.locale}/pages.json`, { page: attributes })
      .then((response: Attributes) => this.updateNode(index, response));
  }

  buildTree(pages: Page[]) {
    // Build tree
    const parentMap: ParentMap = pages.reduce((m: ParentMap, page: Page) => {
      const id = page.parent_page_id || 0;
      m[id] = [...(m[id] || []), page];
      return m;
    }, {});

    pages.forEach((p: Page) => { p.children = parentMap[p.id] || []; });

    const tree = new Tree({
      name: "All Pages",
      locale: this.props.locale,
      permissions: this.props.permissions,
      root: true,
      children: parentMap[0]
    });
    this.applyCollapsed(tree);
    tree.updateNodesPosition();
    return tree;
  }

  movePage(index: TreeIndex<PageNode>, parent: TreeIndex<PageNode>, position: number) {
    const data = {
      parent_id: parent.node.id,
      position: position
    };
    const url = `/admin/${index.node.locale}/pages/${index.node.id}/move.json`;
    this.performUpdate(index, url, data);
  }

  performUpdate(index: TreeIndex, url: string, data: Attributes) {
    void putJson(url, data)
      .then((response: Page) => this.updateNode(index, response));
  }

  render() {
    const addChild = (id: TreeId, attributes: Attributes) => {
      const tree = this.state.tree;
      const index = tree.append(attributes, id);
      this.reorderChildren(id);
      this.setCollapsed(id, false);
      this.createPage(index, attributes);
      this.setState({tree: tree});
    };

    const movedPage = (id: TreeId) => {
      const tree = this.state.tree;
      const index = tree.getIndex(id);
      this.reorderChildren(index.parent);

      const parent = tree.getIndex(index.parent);
      const position = parent.children.indexOf(id) + 1;

      this.movePage(index, parent, position);
      this.setState({ tree: tree });
    };

    const toggleCollapsed = (id: TreeId) => {
      const tree = this.state.tree;
      const node = tree.getIndex(id).node;
      this.setCollapsed(id, !node.collapsed);
      this.setState({tree: tree});
    };

    const updatePage = (id: TreeId, attributes: Attributes) => {
      const tree = this.state.tree;
      const index = tree.getIndex(id);
      const url = `/admin/${index.node.locale}/pages/${index.node.id}.json`;
      this.updateNode(index, attributes);
      this.performUpdate(index, url, { page: attributes });
    };

    const updateTree = (tree: Tree) => {
      this.setState({ tree: tree });
    };

    return(
      <Draggable tree={this.state.tree}
                 addChild={addChild}
                 movedPage={movedPage}
                 toggleCollapsed={toggleCollapsed}
                 updatePage={updatePage}
                 updateTree={updateTree}
                 locale={this.props.locale}
                 dir={this.props.dir} />
    );
  }

  reorderChildren(id: TreeId) {
    const tree = this.state.tree;
    const index = this.state.tree.getIndex(id);
    const node = index.node;
    if (!node.news_page) {
      return;
    }
    index.children = index.children.sort(function (a, b) {
      const aNode = tree.getIndex(a).node;
      const bNode = tree.getIndex(b).node;
      if (aNode.pinned == bNode.pinned) {
        return new Date(bNode.published_at) - new Date(aNode.published_at);
      } else {
        return aNode.pinned ? -1 : 1;
      }
    });
    tree.updateNodesPosition();
  }

  setCollapsed(id: TreeId, value: boolean) {
    const node = this.state.tree.getIndex(id).node;
    node.collapsed = value;
    this.storeCollapsed(id, node.collapsed);
    this.state.tree.updateNodesPosition();
  }

  storeCollapsed(id: TreeId, newState: boolean) {
    const node = this.state.tree.getIndex(id).node;
    const store = collapsedState();
    store[node.id] = newState;
    window.localStorage.collapsedPages = JSON.stringify(store);
  }

  updateNode(index: TreeIndex, attributes: Attributes) {
    for (const attr in attributes) {
      if (Object.prototype.hasOwnProperty.call(attributes, attr)) {
        index.node[attr] = attributes[attr];
      }
    }
    this.setState({ tree: this.state.tree });
  }
}
