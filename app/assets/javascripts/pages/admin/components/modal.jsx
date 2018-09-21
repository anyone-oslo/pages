class Modal extends Reflux.Component {
  constructor(props) {
    super(props);
    this.store = ModalStore;
    this.closeModal = this.closeModal.bind(this);
    this.handleKeypress = this.handleKeypress.bind(this);
  }

  componentDidMount() {
    window.addEventListener("keypress", this.handleKeypress);
  }

  componentWillUnmount() {
    window.removeEventListener("keypress", this.handleKeypress);
  }

  closeModal(evt) {
    evt.stopPropagation();
    evt.preventDefault();
    ModalActions.close();
  }

  handleKeypress(evt) {
    if (this.state.component && (evt.key == "Escape" || evt.keyCode === 27)) {
      this.closeModal(evt);
    }
  }

  render() {
    let component = this.state.component;

    if (component) {
      document.body.classList.add("modal");
    } else {
      document.body.classList.remove("modal");
      return (<div className="modal-wrapper"></div>);
    }

    return (
      <div className="modal-wrapper open">
        <div className="background" onClick={this.closeModal} />
        <div className="modal">
          {component}
        </div>
      </div>
    );
  }
}
