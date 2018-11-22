class Toast extends Reflux.Component {
  constructor(props) {
    super(props);
    this.store = ToastStore;
  }

  componentDidMount() {
    if (this.props.notice) {
      ToastActions.notice(this.props.notice);
    }
  }

  componentWillUnmount() {
  }

  render() {
    let toast = this.state.current;
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
