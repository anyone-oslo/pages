import React from "react";
import PropTypes from "prop-types";
import ToastStore from "./ToastStore";

export default class Toast extends React.Component {
  constructor(props) {
    super(props);
    this.state = { toast: undefined,
                   fadeout: false };
    this.store = ToastStore;
    this.timer = undefined;
    this.handleChange = this.handleChange.bind(this);
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
    this.unsubscribe();
    if (this.timer) {
      clearTimeout(this.timer);
    }
  }

  handleChange() {
    this.setState({ toast: this.store.getState()[0], fadeout: false });
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
  }

  render() {
    let toast = this.state.toast;
    let classNames = ["toast"];

    if (toast) {
      classNames.push(toast.type);
      if (this.state.fadeout) {
        classNames.push("fadeout");
      }
    }

    return (
      <div className="toast-wrapper">
        {toast && (
          <div className={classNames.join(" ")}>
            {toast.message}
          </div>
        )}
      </div>
    );
  }
}

Toast.propTypes = {
  notice: PropTypes.string,
  error: PropTypes.string
};
