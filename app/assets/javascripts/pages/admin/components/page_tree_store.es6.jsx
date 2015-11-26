(function () {
  var tree = null;

  var PageTreeStore = Reflux.createStore({
    listenables: [PageTreeActions],

    init: function () {
    },

    getInitialState: function () {
      return tree;
    },

    onInit: function (newTree) {
      tree = new Tree(newTree);
      tree.updateNodesPosition();
      this.trigger(tree);
    },

    onAddChild: function (id, attributes) {
      tree.append(attributes, id);
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
