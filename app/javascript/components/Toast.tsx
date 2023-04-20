import React, { Component } from "react";
import { Store } from "redux";

import ToastStore, { Toast as ToastRecord } from "../stores/ToastStore";

interface ToastProps {
  error: string,
  notice: string
}

interface ToastState {
  toast: ToastRecord | undefined,
  fadeout: boolean
}

export default class Toast extends Component<ToastProps, ToastState> {
  store: Store;

  constructor(props: ToastProps) {
    super(props);
    this.state = { toast: undefined,
                   fadeout: false };
    this.store = ToastStore;
    this.timer = undefined;
  }

  componentDidMount() {
    this.unsubscribe = this.store.subscribe(this.handleChange);
    if (this.props.error) {
      this.store.dispatch({ type: "ERROR", message: this.props.error });
    }
    if (this.props.notice) {
      this.store.dispatch({ type: "NOTICE", message: this.props.notice });
    }
  }

  componentWillUnmount() {
    if ("unsubscribe" in this) {
      this.unsubscribe();
    }
    if ("timer" in this) {
      clearTimeout(this.timer);
    }
  }

  handleChange = () => {
    const toasts = this.store.getState() as ToastRecord[];

    this.setState({ toast: toasts[0], fadeout: false });
    if (!this.timer) {
      this.timer = setTimeout(() => {
        this.setState({ fadeout: true });
        this.timer = setTimeout(() => {
          this.timer = undefined;
          this.setState({ fadeout: false });
          this.store.dispatch({ type: "NEXT" });
        }, 500);
      }, 4000);
    }
  };

  render() {
    const toast = this.state.toast;
    const classNames = ["toast"];

    if (toast) {
      classNames.push(toast.type);
      if (this.state.fadeout) {
        classNames.push("fadeout");
      }
    }

    return (
      <div className="toast-wrapper" aria-live="polite">
        {toast && (
          <div className={classNames.join(" ")}>
            {toast.message}
          </div>
        )}
      </div>
    );
  }
}
