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

    movePage: function (index, parent, position) {
      let store = this;
      let data = {
        parent_id: parent.node.id,
        position: position
      };
      let url = `/admin/${index.node.locale}/pages/${index.node.id}/move.json`;
      $.put(url, data, function (response) {
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

    setCollapsed: function (id, value) {
      var node = tree.getIndex(id).node;
      node.collapsed = value;
      this.storeCollapsed(id, node.collapsed);
      tree.updateNodesPosition();
    },

    storeCollapsed: function (id, state) {
      let node = tree.getIndex(id).node;
      var store = JSON.parse(window.localStorage.collapsedPages);
      store[node.id] = state;
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

      parent = tree.getIndex(index.parent);
      position = parent.children.indexOf(id) + 1;

      this.movePage(index, parent, position);
      this.trigger(tree);
    },

    onAddChild: function (id, attributes) {
      var index = tree.append(attributes, id);
      this.reorderChildren(id);
      this.setCollapsed(id, false);
      this.createPage(index, attributes);
      this.trigger(tree);
    },

    onToggleCollapsed: function (id) {
      var node = tree.getIndex(id).node;
      this.setCollapsed(id, !node.collapsed);
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
