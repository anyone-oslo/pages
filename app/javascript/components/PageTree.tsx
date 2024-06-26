import React, { Component } from "react";

import Tree from "../lib/Tree";
import { postJson, putJson } from "../lib/request";
import * as Trees from "../types/Trees";
import * as Pages from "../types/Pages";

import Draggable from "./PageTree/Draggable";

type CollapsedState = Record<number, boolean>;

interface ParentMap {
  [index: number]: Pages.TreeNode[];
}

interface Props {
  dir: string;
  locale: string;
  pages: Pages.TreeNode[];
  permissions: string[];
}

interface State {
  tree: Tree<Pages.TreeNode>;
}

function collapsedState(): CollapsedState {
  if (
    window &&
    window.localStorage &&
    typeof window.localStorage.collapsedPages != "undefined"
  ) {
    return JSON.parse(
      window.localStorage.getItem("collapsedPages")
    ) as CollapsedState;
  }
  return {};
}

export default class PageTree extends Component<Props, State> {
  constructor(props: Props) {
    super(props);

    this.state = { tree: this.buildTree(props.pages, props.locale) };
  }

  applyCollapsed(tree: Tree<Pages.TreeNode>) {
    const depth = (t: Tree, index: Trees.Index) => {
      let depth = 0;
      let pointer = t.getIndex(index.parent);
      while (pointer) {
        depth += 1;
        pointer = t.getIndex(pointer.parent);
      }
      return depth;
    };

    const walk = (id: Trees.Id) => {
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
        index.children.forEach((c) => walk(c));
      }
    };
    walk(1);
  }

  createPage(index: Trees.Index<Pages.TreeNode>, attributes: Pages.TreeItem) {
    void postJson(`/admin/${this.props.locale}/pages.json`, {
      page: attributes
    }).then((response: Pages.TreeItem) => this.updateNode(index, response));
  }

  buildTree(pages: Pages.TreeNode[], locale: string) {
    // Build tree
    const parentMap: ParentMap = pages.reduce(
      (m: ParentMap, page: Pages.TreeNode) => {
        const id = page.parent_page_id || 0;
        m[id] = [...(m[id] || []), page];
        return m;
      },
      {}
    );

    pages.forEach((p) => {
      p.children = parentMap[p.id] || [];
    });

    const tree = new Tree<Pages.TreeNode>({
      blocks: {
        name: { [locale]: "All Pages" }
      },
      permissions: this.props.permissions,
      root: true,
      children: parentMap[0],
      collapsed: false
    });
    this.applyCollapsed(tree);
    tree.updateNodesPosition();
    return tree;
  }

  movePage(
    index: Trees.Index<Pages.TreeNode>,
    parent: Trees.Index<Pages.TreeNode>,
    position: number
  ) {
    const data = {
      parent_id: parent.node.id,
      position: position
    };
    const url = `/admin/${this.props.locale}/pages/${index.node.id}/move.json`;
    this.performUpdate(index, url, data);
  }

  performUpdate(
    index: Trees.Index<Pages.TreeNode>,
    url: string,
    data: Record<string, unknown>
  ) {
    void putJson(url, data).then((response: Pages.TreeItem) =>
      this.updateNode(index, response)
    );
  }

  render() {
    const addChild = (id: Trees.Id, attributes: Pages.TreeNode) => {
      const tree = this.state.tree;
      const index = tree.append(attributes, id);
      this.reorderChildren(id);
      this.setCollapsed(id, false);
      this.createPage(index, attributes);
      this.setState({ tree: tree });
    };

    const movedPage = (id: Trees.Id) => {
      const tree = this.state.tree;
      const index = tree.getIndex(id);
      this.reorderChildren(index.parent);

      const parent = tree.getIndex(index.parent);
      const position = parent.children.indexOf(id) + 1;

      this.movePage(index, parent, position);
      this.setState({ tree: tree });
    };

    const toggleCollapsed = (id: Trees.Id) => {
      const tree = this.state.tree;
      const node = tree.getIndex(id).node;
      this.setCollapsed(id, !node.collapsed);
      this.setState({ tree: tree });
    };

    const updatePage = (id: Trees.Id, attributes: Pages.TreeItem) => {
      const tree = this.state.tree;
      const index = tree.getIndex(id);
      const url = `/admin/${this.props.locale}/pages/${index.node.id}.json`;
      this.updateNode(index, attributes);

      const data: Record<string, unknown> = { ...attributes };
      if ("blocks" in attributes && "name" in attributes.blocks) {
        data.name = attributes.blocks.name[this.props.locale];
      }
      this.performUpdate(index, url, { page: data });
    };

    const updateTree = (tree: Tree<Pages.TreeNode>) => {
      this.setState({ tree: tree });
    };

    return (
      <Draggable
        tree={this.state.tree}
        addChild={addChild}
        movedPage={movedPage}
        toggleCollapsed={toggleCollapsed}
        updatePage={updatePage}
        updateTree={updateTree}
        locale={this.props.locale}
        dir={this.props.dir}
      />
    );
  }

  reorderChildren(id: Trees.Id) {
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
        return (
          new Date(bNode.published_at).getTime() -
          new Date(aNode.published_at).getTime()
        );
      } else {
        return aNode.pinned ? -1 : 1;
      }
    });
    tree.updateNodesPosition();
  }

  setCollapsed(id: Trees.Id, value: boolean) {
    const node = this.state.tree.getIndex(id).node;
    node.collapsed = value;
    this.storeCollapsed(id, node.collapsed);
    this.state.tree.updateNodesPosition();
  }

  storeCollapsed(id: Trees.Id, newState: boolean) {
    const node = this.state.tree.getIndex(id).node;
    const store = collapsedState();
    store[node.id] = newState;
    window.localStorage.collapsedPages = JSON.stringify(store);
  }

  updateNode(index: Trees.Index<Pages.TreeNode>, attributes: Pages.TreeItem) {
    index.node = { ...index.node, ...attributes };
    this.setState({ tree: this.state.tree });
  }
}
