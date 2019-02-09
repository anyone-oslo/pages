var PageTreeActions = Reflux.createActions([
  "addChild",
  "init",
  "movedPage",
  "toggleCollapsed",
  "updatePage",
  "updateTree"
]);

class PageTreeStore extends Reflux.Store {
  constructor() {
    super();
    this.state = { tree: null };
    this.listenToMany(PageTreeActions);
  }

  collapsedState() {
    if (window && window.localStorage &&
        typeof(window.localStorage.collapsedPages) != "undefined") {
      return JSON.parse(window.localStorage.collapsedPages);
    }
    return {};
  }

  applyCollapsed(tree) {
    let store = this;
    let collapsedState = this.collapsedState();
    let walk = function (id) {
      var index = tree.getIndex(id);
      var node = index.node;
      if (collapsedState.hasOwnProperty(node.id)) {
        node.collapsed = collapsedState[node.id];
      } else if (node.news_page) {
        node.collapsed = true;
      } else if (store.depth(tree, index) > 1) {
        node.collapsed = true;
      }
      if (index.children && index.children.length) {
        index.children.forEach(c => walk(c));
      }
    };
    walk(1);
  }

  depth(tree, index) {
    var depth = 0;
    var pointer = index;
    while (pointer = tree.getIndex(pointer.parent)) {
      depth += 1;
    }
    return depth;
  }

  createPage(index, attributes) {
    let store = this;
    let url = `/admin/${index.node.locale}/pages.json`;
    $.post(url, { page: attributes }, function (response) {
      store.updateNode(index, response);
    });
  }

  movePage(index, parent, position) {
    let data = {
      parent_id: parent.node.id,
      position: position
    };
    let url = `/admin/${index.node.locale}/pages/${index.node.id}/move.json`;
    this.performUpdate(index, url, data);
  }

  updatePage(index, attributes) {
    let url = `/admin/${index.node.locale}/pages/${index.node.id}.json`;
    this.performUpdate(index, url, { page: attributes });
  }

  performUpdate(index, url, data) {
    let store = this;
    $.put(url, data, function (response) {
      store.updateNode(index, response);
    });
  }

  updateNode(index, attributes) {
    for (var attr in attributes) {
      if (attributes.hasOwnProperty(attr)) {
        index.node[attr] = attributes[attr];
      }
    }
    this.setState({tree: tree});
  }

  getInitialState() {
    return this.state.tree;
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

  onInit(props) {
    let pages = props.pages;

    // Build tree
    let parentMap = pages.reduce((m, page) => {
      let id = page.parent_page_id;
      m[id] = [...(m[id] || []), page];
      return m;
    }, {});

    pages.forEach((p) => p.children = parentMap[p.id] || []);

    tree = new Tree({ name: "All Pages",
                      locale: props.locale,
                      permissions: props.permissions,
                      root: true,
                      children: parentMap[null] });
    this.applyCollapsed(tree);
    tree.updateNodesPosition();
    this.setState({tree: tree});
  }

  onMovedPage(id) {
    let tree = this.state.tree;
    let index = tree.getIndex(id);
    this.reorderChildren(index.parent);

    parent = tree.getIndex(index.parent);
    position = parent.children.indexOf(id) + 1;

    this.movePage(index, parent, position);
    this.setState({tree: tree});
  }

  onAddChild(id, attributes) {
    let tree = this.state.tree;
    var index = tree.append(attributes, id);
    this.reorderChildren(id);
    this.setCollapsed(id, false);
    this.createPage(index, attributes);
    this.setState({tree: tree});
  }

  onToggleCollapsed(id) {
    let tree = this.state.tree;
    var node = tree.getIndex(id).node;
    this.setCollapsed(id, !node.collapsed);
    this.setState({tree: tree});
  }

  onUpdatePage(id, attributes) {
    let tree = this.state.tree;
    var index = tree.getIndex(id);
    this.updateNode(index, attributes);
    this.updatePage(index, attributes);
  }

  onUpdateTree(newTree) {
    tree = newTree;
    this.setState({tree: tree});
  }
}
