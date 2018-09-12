class Modal extends Reflux.Component {
  constructor(props) {
    super(props);
    this.store = ModalStore;
  }

  render() {
    let component = this.state.component;

    if (!component) {
      return (<div className="modal-wrapper" />);
    }

    return (
      <div className="modal-wrapper open" onClick={ModalActions.close}>
        <div className="modal" onClick={(evt) => evt.stopPropagation()}>
          {component}
        </div>
      </div>
    );
  }
}
