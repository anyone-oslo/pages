(function () {
  var tree = null;

  var PageTreeStore = Reflux.createStore({
    listenables: [PageTreeActions],

    init: function () {
      if (!window.localStorage.collapsedPages) {
        window.localStorage.collapsedPages = JSON.stringify({});
      }
    },

    applyCollapsed: function () {
      let store = JSON.parse(window.localStorage.collapsedPages);
      let walk = function (id) {
        var index = tree.getIndex(id);
        var node = index.node;
        if (store.hasOwnProperty(node.id)) {
          node.collapsed = store[node.id];
        } else if (node.news_page) {
          node.collapsed = true;
        }
        if (index.children && index.children.length) {
          index.children.forEach(c => walk(c));
        }
      };
      walk(1);
    },

    createPage: function (index, attributes) {
      let store = this;
      let url = `/admin/${index.node.locale}/pages.json`;
      $.post(url, { page: attributes }, function (response) {
        store.updateNode(index, response.page_tree);
      });
    },

    updatePage: function (index, attributes) {
      let store = this;
      let url = `/admin/${index.node.locale}/pages/${index.node.id}.json`;
      $.put(url, { page: attributes }, function (response) {
        store.updateNode(index, response.page_tree);
      });
    },

    updateNode: function (index, attributes) {
      for (var attr in attributes) {
        if (attributes.hasOwnProperty(attr)) {
          index.node[attr] = attributes[attr];
        }
      }
      this.trigger(tree);
    },

    getInitialState: function () {
      return tree;
    },

    storeCollapsed: function (id, state) {
      let node = tree.getIndex(id).node;
      var store = JSON.parse(window.localStorage.collapsedPages);
      store[node.id] = state;
      console.log(store);
      window.localStorage.collapsedPages = JSON.stringify(store);
    },

    reorderChildren: function (id) {
      var index = tree.getIndex(id);
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
    },

    onInit: function (newTree) {
      tree = new Tree(newTree);
      this.applyCollapsed();
      tree.updateNodesPosition();
      this.trigger(tree);
    },

    onMovedPage: function (id) {
      let index = tree.getIndex(id);
      this.reorderChildren(index.parent);
      this.trigger(tree);
    },

    onAddChild: function (id, attributes) {
      var index = tree.append(attributes, id);
      this.reorderChildren(id);
      this.updateNode(index, { collapsed: false })
      this.createPage(index, attributes);
    },

    onToggleCollapsed: function (id) {
      var node = tree.getIndex(id).node;
      node.collapsed = !node.collapsed;
      this.storeCollapsed(id, node.collapsed);
      this.trigger(tree);
    },

    onUpdatePage: function (id, attributes) {
      var index = tree.getIndex(id);
      this.updateNode(index, attributes);
      this.updatePage(index, attributes);
    },

    onUpdateTree: function (newTree) {
      tree = newTree;
      this.trigger(tree);
    }
  });

  window.PageTreeStore = PageTreeStore;
})();
