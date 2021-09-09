var ModalActions = Reflux.createActions([
  "open",
  "close"
]);

class ModalStore extends Reflux.Store {
  constructor() {
    super();
    this.state = { component: null };
    this.listenToMany(ModalActions);
  }

  onOpen(component) {
    this.setState({component: component});
  }

  onClose() {
    this.setState({component: null});
  }
}
