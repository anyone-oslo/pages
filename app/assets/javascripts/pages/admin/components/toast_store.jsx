var ToastActions = Reflux.createActions([
  "notice",
  "error"
]);

class ToastStore extends Reflux.Store {
  constructor() {
    super();
    this.state = {
      current: null,
      fadeout: false,
      queue: []
    };
    this.listenToMany(ToastActions);
  }

  addToQueue(msg, type) {
    let entry = { message: msg, type: type };
    if (this.state.current) {
      this.setState({ queue: [...this.state.queue, entry] });
    } else {
      this.showToast(entry, this.state.queue);
    };
  }

  showToast(entry, queue) {
    let store = this;
    this.setState({ current: entry, queue: queue, fadeout: false });
    setTimeout(function () {
      store.setState({ fadeout: true });
      setTimeout(() => store.next(), 500);
    }, 4000);
  }

  next() {
    let queue = this.state.queue;
    if (queue.length > 0) {
      let entry = queue.shift();
      this.showToast(entry, queue);
    } else {
      this.setState({ current: null, fadeout: false });
    }
  }

  onNotice(msg) {
    this.addToQueue(msg, "notice");
  }

  onError(msg) {
    this.addToQueue(msg, "error");
  }
}
