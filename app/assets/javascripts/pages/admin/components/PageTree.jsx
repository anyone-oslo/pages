class PageTree extends Reflux.Component {
  constructor(props) {
    super(props);
    this.store = PageTreeStore;

    this.addChild = this.addChild.bind(this);
    this.movedPage = this.movedPage.bind(this);
    this.toggleCollapsed = this.toggleCollapsed.bind(this);
    this.updatePage = this.updatePage.bind(this);
    this.updateTree = this.updateTree.bind(this);
  }

  addChild(id, attributes) {
    PageTreeActions.addChild(id, attributes);
  }

  movedPage(id) {
    PageTreeActions.movedPage(id);
  }

  toggleCollapsed(id) {
    PageTreeActions.toggleCollapsed(id);
  }

  updatePage(id, attributes) {
    PageTreeActions.updatePage(id, attributes);
  }

  updateTree(tree) {
    PageTreeActions.updateTree(tree);
  }

  componentDidMount() {
    PageTreeActions.init(this.props);
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
}
