class Modal extends Reflux.Component {
  constructor(props) {
    super(props);
    this.store = ModalStore;
  }

  closeModal(evt) {
    evt.stopPropagation();
    ModalActions.close();
  }

  render() {
    let component = this.state.component;

    if (component) {
      document.body.classList.add("modal");
    } else {
      document.body.classList.remove("modal");
      return (<div className="modal-wrapper" />);
    }

    return (
      <div className="modal-wrapper open" onClick={this.closeModal}>
        <div className="modal" onClick={(evt) => evt.stopPropagation()}>
          {component}
        </div>
      </div>
    );
  }
}
