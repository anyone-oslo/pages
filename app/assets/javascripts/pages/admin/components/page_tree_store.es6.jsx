(function () {
  var tree = null;

  var PageTreeStore = Reflux.createStore({
    listenables: [PageTreeActions],

    init: function () {
    },

    getInitialState: function () {
      return tree;
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
      tree.updateNodesPosition();
      this.trigger(tree);
    },

    onMovedPage: function (id) {
      let index = tree.getIndex(id);
      this.reorderChildren(index.parent);
      this.trigger(tree);
    },

    onAddChild: function (id, attributes) {
      tree.append(attributes, id);
      this.reorderChildren(id);
      PageTreeActions.updatePage(id, { collapsed: false });
      this.trigger(tree);
    },

    onToggleCollapsed: function (id) {
      var node = tree.getIndex(id).node;
      node.collapsed = !node.collapsed;
      this.trigger(tree);
    },

    onUpdatePage: function (id, attributes) {
      var index = tree.getIndex(id);
      for (var attr in attributes) {
        if (attributes.hasOwnProperty(attr)) {
          index.node[attr] = attributes[attr];
        }
      }
      this.trigger(tree);
    },

    onUpdateTree: function (newTree) {
      tree = newTree;
      this.trigger(tree);
    }
  });

  window.PageTreeStore = PageTreeStore;
})();
