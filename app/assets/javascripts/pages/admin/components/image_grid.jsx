class ImageGrid extends React.Component {
  constructor(props) {
    super(props);

    let records = props.records.map(r => ({
      ...r,
      ref: React.createRef(),
      handle: this.getHandle()
    }));

    this.state = { dragging: false,
                   primary: null,
                   images: records,
                   deleted: [],
                   x: null,
                   y: null };

    if (props.enablePrimary) {
      this.state = { ...this.state,
                     primary: records.filter(r => r.primary)[0] || null,
                     images: records.filter(r => !r.primary) }
    }

    this.container = React.createRef();
    this.imagesContainer = React.createRef();
    this.primaryContainer = React.createRef();
    this.uploadImagesInput = React.createRef();
    this.uploadPrimaryInput = React.createRef();

    ["cachePositions", "deleteImage", "drag", "dragEnd", "dragLeave",
     "startImageDrag", "uploadImages", "triggerUploadImages",
     "uploadPrimary", "triggerUploadPrimary"].forEach(
       prop => this[prop] = this[prop].bind(this)
     );
  }

  attributeName(record) {
    return `${this.props.attribute}[${this.index(record) + 1}]`;
  }

  cachePositions() {
    this.cachedPositions = {};
    this.state.images.forEach(r => {
      this.cachedPositions[r.handle] = r.ref.current.getBoundingClientRect();
    });
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

  deleteImage(record) {
    let { primary, images, deleted } = this.state;
    if (record == this.state.primary) {
      primary = null;
    } else {
      images = images.filter(i => i != record);
    }
    if (record.id) {
      deleted = [...deleted, record];
    }
    this.setState({ primary: primary,
                    images: images,
                    deleted: deleted });
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

  dragLeave(evt) {
    if (!this.state.dragging || this.state.dragging !== "Files") {
      return;
    }
    evt.preventDefault();
    evt.stopPropagation();
    this.setState({ dragging: false, x: null, y: null });
  }

  getHandle() {
    if (!this.handle) {
      this.handle = 0;
    }
    this.handle += 1;
    return this.handle;
  }

  injectUploads(files, primary, images) {
    let queue = files.slice();
    if (primary === "Files") {
      primary = queue.shift();
      images = [...queue, ...images];
    } else {
      let source = images;
      images = [];
      source.forEach(function (img) {
        if (img === "Files") {
          images = [...images, ...queue];
        } else {
          images.push(img);
        }
      });
    }
    return { primary: primary, images: images };
  }

  dragEnd(evt) {
    if (!this.state.dragging) {
      return;
    }
    evt.preventDefault();
    evt.stopPropagation();
    var { primary, images } = this.getDraggedOrder();

    if (this.state.dragging == "Files") {
      let files = this.getFiles(evt.dataTransfer)
                      .map(f => this.uploadFile(f));
      var { primary,
            images } = this.injectUploads(files, primary, images);
    }

    this.setState({dragging: false,
                   x: null,
                   y: null,
                   primary: primary,
                   images: images});
    this.cachePositions();
  }

  getFiles(dt) {
    let validTypes = ["image/gif",
                      "image/jpeg",
                      "image/pjpeg",
                      "image/png",
                      "image/tiff"];
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
    return files.filter(f => validTypes.indexOf(f.type) !== -1);
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

  index(record) {
    let { primary, images, deleted } = this.state;
    var ordered = [...images, ...deleted];
    if (primary) {
      ordered = [primary, ...ordered];
    }
    return ordered.indexOf(record);
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

  renderDrag() {
    let record = this.state.dragging;
    if (record === "Files") {
      return;
    } else {
      let containerSize = this.container.current.getBoundingClientRect();
      let x = this.state.x - (containerSize.x || containerSize.left);
      let y = this.state.y - (containerSize.y || containerSize.top);
      let translateStyle = {
        transform: `translate3d(${x}px, ${y}px, 0)`
      }
      return (
        <div className="drag-image" style={translateStyle}>
          {record.image && (
             <img src={record.src || record.image.thumbnail_url} />
          )}
        </div>
      )
    }
  }

  getDraggedOrder() {
    let dragging = this.state.dragging;
    var primary = this.state.primary;
    var images = this.state.images;
    if (dragging) {
      if (this.hovering(this.primaryContainer)) {
        images = [primary, ...images].filter(
          r => r !== null && r !== dragging
        );
        primary = dragging;
      } else if (this.hovering(this.imagesContainer)) {
        images = [];
        if (dragging === primary) {
          primary = null;
        }
        this.state.images.filter(r => r !== dragging).forEach(r => {
          if (this.hovering(r) && images.indexOf(dragging) === -1) {
            images.push(dragging);
          }
          images.push(r);
        });
        if (images.indexOf(dragging) === -1) {
          images.push(dragging);
        }
      } else {
        if (dragging === primary) {
          primary = null;
        }
        images = this.state.images.filter(r => r !== dragging);
        if (this.state.y < this.imagesContainer.current.getBoundingClientRect().top) {
          images = [dragging, ...images];
        } else {
          images.push(dragging);
        }
      }
    }
    return { primary: primary, images: images };
  }

  renderImage(record, primary) {
    let dragging = this.state.dragging;
    var key;
    if (record === "Files") {
      return (
        <div className="grid-image" key="file-placeholder">
          <div className="file-placeholder" />
        </div>
      );
    }

    if (record.image) {
      key = record.image.id;
    } else if (record.file) {
      key = record.file.name;
    }

    let onUpdate = (image, src) => {
      this.updateImage(record, { image: image, src: src });
    }

    return (
      <GridImage key={`grid-image-${key}`}
                 record={record}
                 locale={this.props.locale}
                 locales={this.props.locales}
                 csrf_token={this.props.csrf_token}
                 showEmbed={this.props.showEmbed}
                 startDrag={this.startImageDrag}
                 position={this.index(record) + 1}
                 primary={primary}
                 onUpdate={onUpdate}
                 enablePrimary={this.props.enablePrimary}
                 deleteImage={this.deleteImage}
                 attributeName={this.attributeName(record)}
                 placeholder={dragging && dragging == record} />
    );
  }

  render() {
    let { dragging, deleted } = this.state;
    let { primary, images } = this.getDraggedOrder();
    return (
      <div className="image-grid"
           ref={this.container}
           onDragOver={this.drag}
           onDrop={this.dragEnd}>
        {dragging && this.renderDrag()}
        {this.props.enablePrimary && (
           <div className="primary-image" ref={this.primaryContainer}>
             <h3>
               Main image
             </h3>
             {primary && this.renderImage(primary, true)}
             {!primary && (
                <div className="drop-target">
                  <span>
                    Drag and drop image here, or<br />
                    <button onClick={this.triggerUploadPrimary}>
                      choose a file
                    </button>
                  </span>
                  <input type="file"
                         onChange={this.uploadPrimary}
                         ref={this.uploadPrimaryInput}
                         multiple />
                </div>
             )}
             {this.props.primaryAttribute && (
                <input type="hidden" name={this.props.primaryAttribute}
                       value={(primary && primary.image && primary.image.id) || ""} />
             )}
           </div>
        )}
        <div className="grid" ref={this.imagesContainer}>
          <h3>
            {this.props.enablePrimary ? "More files" : "Images"}
          </h3>
          <div className="drop-target">
            <span>
              Drag and drop image here, or
              <button onClick={this.triggerUploadImages}>
                choose a file
              </button>
            </span>
            <input type="file"
                   onChange={this.uploadImages}
                   ref={this.uploadImagesInput}
                   multiple />
          </div>
          <div className="images">
            {images.map(r => this.renderImage(r, false))}
          </div>
        </div>
        <div className="deleted">
          {deleted.map(r => this.renderDeletedImage(r))}
        </div>
      </div>
    );
  }

  renderDeletedImage(record) {
    let image = record.image;
    let attrName = this.attributeName(record);
    return (
      <span className="deleted-image" key={`deleted-${record.id}`}>
        <input name={`${attrName}[id]`}
               type="hidden" value={record.id} />
        <input name={`${attrName}[image_id]`}
               type="hidden" value={(image && image.id) || ""} />
        <input name={`${attrName}[_destroy]`}
               type="hidden" value={true} />
      </span>
    );
  }

  startImageDrag(evt, record) {
    let position = this.mousePosition(evt);
    let prevDisplay = record.ref.current.style.display;
    record.ref.current.style.display = "none";
    this.cachePositions();
    record.ref.current.style.display = prevDisplay;
    this.setState({ dragging: record, x: position.x, y: position.y });
  }

  updateImage(record, attrs) {
    if (this.state.primary === record) {
      this.setState({ primary: { ...record, ...attrs } });
    } else {
      let images = this.state.images.slice();
      images[images.indexOf(record)] = { ...record, ...attrs };
      this.setState({ images: images });
    }
  }

  uploadFile(file) {
    let component = this;
    let obj = { image: null, file: file, ref: React.createRef(),
                handle: this.getHandle() };
    let xhr = new XMLHttpRequest();
    let data = new FormData();
    this.setState({ image: null, src: null, dragover: false, uploading: true });
    data.append("image[file]", file);
    xhr.open("POST", "/admin/images.json");
    xhr.setRequestHeader("X-CSRF-Token", this.props.csrf_token);
    xhr.addEventListener("load", function () {
      if (xhr.readyState == 4 && xhr.status == "200") {
        let preloader = new Image();
        obj.file = null;
        obj.image = JSON.parse(xhr.responseText)
        preloader.onload = () => component.setState({});
        preloader.src = obj.image.thumbnail_url;
      }
    });
    xhr.send(data);
    return obj;
  }

  triggerUploadImages(evt) {
    evt.preventDefault();
    this.uploadImagesInput.current.click();
  }

  triggerUploadPrimary(evt) {
    evt.preventDefault();
    this.uploadPrimaryInput.current.click();
  }

  uploadFiles(fileList) {
    let result = [];
    for (var i = 0; i < fileList.length; i++) {
      result.push(this.uploadFile(fileList[i]));
    }
    return result;
  }

  uploadImages(evt) {
    let uploadedFiles = this.uploadFiles(evt.target.files);
    this.setState({ images: [...this.state.images, ...uploadedFiles] });
  }

  uploadPrimary(evt) {
    let uploadedFiles = this.uploadFiles(evt.target.files);
    var primary = this.state.primary;
    var images = this.state.images;
    if (primary) {
      images = [primary, ...images];
    }
    primary = uploadedFiles[0];
    if (uploadedFiles.length > 1) {
      images = [...uploadedFiles.slice(1), ...images];
    }
    this.setState({ primary: primary, images: images });
  }
}
