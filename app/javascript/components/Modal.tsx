import React, { Component } from "react";
import { Store } from "redux";

import ModalStore, { ModalState } from "../stores/ModalStore";

type ModalProps = Record<string, never>;

export default class Modal extends Component<ModalProps, ModalState> {
  store: Store;

  constructor(props: ModalProps) {
    super(props);
    this.state = { component: null };
    this.store = ModalStore;
  }

  componentDidMount() {
    this.unsubscribe = this.store.subscribe(this.handleChange);
    window.addEventListener("keypress", this.handleKeypress);
  }

  componentWillUnmount() {
    if ("unsubscribe" in this) {
      this.unsubscribe();
    }
    window.removeEventListener("keypress", this.handleKeypress);
  }

  closeModal = (evt: Event) => {
    evt.stopPropagation();
    evt.preventDefault();
    ModalStore.dispatch({ type: "CLOSE" });
  };

  handleChange = () => {
    this.setState({ ...this.store.getState() as ModalState });
  };

  handleKeypress = (evt: KeyboardEvent) => {
    if (this.state.component && (evt.key == "Escape" || evt.keyCode === 27)) {
      this.closeModal(evt);
    }
  };

  render() {
    const component = this.state.component;

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
