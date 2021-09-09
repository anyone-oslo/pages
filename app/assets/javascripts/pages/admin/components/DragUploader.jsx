class DragUploader extends React.Component {
  constructor(props) {
    super(props);
    this.state = { dragging: false,
                   x: null,
                   y: null };

    this.cachePositions = this.cachePositions.bind(this);
    this.drag = this.drag.bind(this);
    this.dragEnd = this.dragEnd.bind(this);
    this.dragLeave = this.dragLeave.bind(this);
    this.startDrag = this.startDrag.bind(this);
  }

  componentDidMount() {
    window.addEventListener("mousemove", this.drag);
    window.addEventListener("touchmove", this.drag);
    window.addEventListener("mouseup", this.dragEnd);
    window.addEventListener("touchend", this.dragEnd);
    window.addEventListener("mouseout", this.dragLeave);
    window.addEventListener("resize", this.cachePositions);
    this.cachePositions();
  }

  componentWillUnmount() {
    window.removeEventListener("mousemove", this.drag);
    window.removeEventListener("touchmove", this.drag);
    window.removeEventListener("mouseup", this.dragEnd);
    window.removeEventListener("touchend", this.dragEnd);
    window.removeEventListener("mouseout", this.dragLeave);
    window.removeEventListener("resize", this.cachePositions);
  }

  draggables() {
    // TODO: raise error
    return [];
  }

  receiveFiles(files, newState) {
    this.setState(newState);
  }

  cachePositions() {
    this.cachedPositions = {};
    this.draggables().forEach(d => {
      if (d.handle && d.ref && d.ref.current) {
        this.cachedPositions[d.handle] = d.ref.current.getBoundingClientRect();
      }
    });
  }

  containsFiles(evt) {
    if (!evt.dataTransfer || !evt.dataTransfer.types) {
      return false;
    }
    let types = evt.dataTransfer.types;
    for (var i = 0; i < types.length; i++) {
      if (types[i] === "Files" || types[i] === "application/x-moz-file") {
        return true;
      }
    }
    return false;
  }

  drag(evt) {
    if (this.state.dragging) {
      let position = this.mousePosition(evt);
      evt.stopPropagation();
      evt.preventDefault();
      this.setState({ x: position.x, y: position.y });
    } else {
      if (this.containsFiles(evt)) {
        this.cachePositions();
        this.setState({ dragging: "Files" });
      }
    }
  }

  dragEnd(evt) {
    if (!this.state.dragging) {
      return;
    }
    evt.preventDefault();
    evt.stopPropagation();

    var files = [];
    if (this.state.dragging == "Files") {
      files = this.getFiles(evt.dataTransfer);
    }

    this.receiveFiles(files, { dragging: false, x: null, y: null });
    this.cachePositions();
  }

  dragLeave(evt) {
    if (!this.state.dragging || this.state.dragging !== "Files") {
      return;
    }
    evt.preventDefault();
    evt.stopPropagation();
    this.setState({ dragging: false, x: null, y: null });
  }

  getFiles(dt) {
    var files = [];
    if (dt.items) {
      for (var i = 0; i < dt.items.length; i++) {
        if (dt.items[i].kind == "file") {
          files.push(dt.items[i].getAsFile());
        }
      }
    } else {
      for (var i = 0; i < dt.files.length; i++) {
        files.push(dt.files[i]);
      }
    }
    return files.filter(f => (!this.validMimeTypes ||
                              this.validMimeTypes.indexOf(f.type) !== -1));
  }

  getHandle() {
    if (!this.handle) {
      this.handle = 0;
    }
    this.handle += 1;
    return this.handle;
  }

  hovering(target) {
    let { x, y } = this.state;
    var rect;
    if (target.handle && this.cachedPositions[target.handle]) {
      rect = this.cachedPositions[target.handle];
    } else if (target.current) {
      rect = target.current.getBoundingClientRect();
    } else {
      return false;
    }
    return (x >= rect.left && x <= rect.right && y >= rect.top && y <= rect.bottom);
  }

  mousePosition(evt) {
    var x, y;
    if (evt.type == "touchmove") {
      x = evt.touches[0].clientX;
      y = evt.touches[0].clientY;
    } else {
      x = evt.clientX;
      y = evt.clientY;
    }
    return { x: x, y: y };
  }

  postFile(url, data, callback) {
    let xhr = new XMLHttpRequest();
    xhr.open("POST", url);
    xhr.setRequestHeader("X-CSRF-Token", this.props.csrf_token);
    xhr.addEventListener("load", function () {
      if (xhr.readyState == 4 && xhr.status == "200" && callback) {
        callback(JSON.parse(xhr.responseText));
      }
    });
    xhr.send(data);
  }

  startDrag(evt, record) {
    let position = this.mousePosition(evt);
    let prevDisplay = record.ref.current.style.display;
    record.ref.current.style.display = "none";
    this.cachePositions();
    record.ref.current.style.display = prevDisplay;
    this.setState({ dragging: record, x: position.x, y: position.y });
  }
}
