import React from "react";
import ModalStore from "./ModalStore";

export default class Modal extends React.Component {
  constructor(props) {
    super(props);
    this.state = { component: null };
    this.store = ModalStore;
    this.closeModal = this.closeModal.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleKeypress = this.handleKeypress.bind(this);
  }

  componentDidMount() {
    this.unsubscribe = this.store.subscribe(this.handleChange);
    window.addEventListener("keypress", this.handleKeypress);
  }

  componentWillUnmount() {
    this.unsubscribe();
    window.removeEventListener("keypress", this.handleKeypress);
  }

  closeModal(evt) {
    evt.stopPropagation();
    evt.preventDefault();
    ModalStore.dispatch({ type: "CLOSE" });
  }

  handleChange() {
    this.setState({ ...this.store.getState() });
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
