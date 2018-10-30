class PageImages extends React.Component {
  constructor(props) {
    super(props);
    let pageImages = props.page_images
                          .map(pi => ({ ...pi,
                                        ref: React.createRef(),
                                        handle: this.getHandle() }));
    this.state = {
      dragging: false,
      primary: pageImages.filter(pi => pi.primary)[0] || null,
      additional: pageImages.filter(pi => !pi.primary),
      deleted: [],
      x: null,
      y: null
    };
    this.container = React.createRef();
    this.additionalContainer = React.createRef();
    this.primaryContainer = React.createRef();
    this.uploadAdditionalInput = React.createRef();
    this.uploadPrimaryInput = React.createRef();
    this.cachePositions = this.cachePositions.bind(this);
    this.deleteImage = this.deleteImage.bind(this);
    this.drag = this.drag.bind(this);
    this.dragEnd = this.dragEnd.bind(this);
    this.dragLeave = this.dragLeave.bind(this);
    this.startImageDrag = this.startImageDrag.bind(this);
    this.uploadAdditional = this.uploadAdditional.bind(this);
    this.triggerUploadAdditional = this.triggerUploadAdditional.bind(this);
    this.uploadPrimary = this.uploadPrimary.bind(this);
    this.triggerUploadPrimary = this.triggerUploadPrimary.bind(this);
  }

  cachePositions() {
    this.cachedPositions = {};
    this.state.additional.forEach(pi => {
      this.cachedPositions[pi.handle] = pi.ref.current.getBoundingClientRect();
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

  deleteImage(pi) {
    let { primary, additional, deleted } = this.state;
    if (pi == this.state.primary) {
      primary = null;
    } else {
      additional = additional.filter(i => i != pi);
    }
    if (pi.id) {
      deleted = [...deleted, pi];
    }
    this.setState({ primary: primary,
                    additional: additional,
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

  injectUploads(images, primary, additional) {
    let queue = images.slice();
    if (primary === "Files") {
      primary = queue.shift();
      additional = [...queue, ...additional];
    } else {
      let source = additional;
      additional = [];
      source.forEach(function (img) {
        if (img === "Files") {
          additional = [...additional, ...queue];
        } else {
          additional.push(img);
        }
      });
    }
    return { primary: primary, additional: additional };
  }

  dragEnd(evt) {
    if (!this.state.dragging) {
      return;
    }
    evt.preventDefault();
    evt.stopPropagation();
    var { primary, additional } = this.getDraggedOrder();

    if (this.state.dragging == "Files") {
      let files = this.getFiles(evt.dataTransfer)
                      .map(f => this.uploadFile(f));
      var { primary,
            additional } = this.injectUploads(files, primary, additional);
    }

    this.setState({dragging: false,
                   x: null,
                   y: null,
                   primary: primary,
                   additional: additional});
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

  index(pi) {
    let { primary, additional, deleted } = this.state;
    var ordered = [...additional, ...deleted];
    if (primary) {
      ordered = [primary, ...ordered];
    }
    return ordered.indexOf(pi);
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
    let pageImage = this.state.dragging;
    if (pageImage === "Files") {
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
          {pageImage.image && (
             <img src={pageImage.src || pageImage.image.thumbnail_url} />
          )}
        </div>
      )
    }
  }

  getDraggedOrder() {
    let dragging = this.state.dragging;
    var primary = this.state.primary;
    var additional = this.state.additional;
    if (dragging) {
      if (this.hovering(this.primaryContainer)) {
        additional = [primary, ...additional].filter(
          pi => pi !== null && pi !== dragging
        );
        primary = dragging;
      } else if (this.hovering(this.additionalContainer)) {
        additional = [];
        if (dragging === primary) {
          primary = null;
        }
        this.state.additional.filter(pi => pi !== dragging).forEach(pi => {
          if (this.hovering(pi) && additional.indexOf(dragging) === -1) {
            additional.push(dragging);
          }
          additional.push(pi);
        });
        if (additional.indexOf(dragging) === -1) {
          additional.push(dragging);
        }
      } else {
        if (dragging === primary) {
          primary = null;
        }
        additional = this.state.additional.filter(pi => pi !== dragging);
        if (this.state.y < this.additionalContainer.current.getBoundingClientRect().top) {
          additional = [dragging, ...additional];
        } else {
          additional.push(dragging);
        }
      }
    }
    return { primary: primary, additional: additional };
  }

  renderImage(pageImage, primary) {
    let dragging = this.state.dragging;
    var key;
    if (pageImage === "Files") {
      return (
        <div className="page-image" key="file-placeholder">
          <div className="file-placeholder" />
        </div>
      );
    }

    if (pageImage.image) {
      key = pageImage.image.id;
    } else if (pageImage.file) {
      key = pageImage.file.name;
    }

    let onUpdate = (image, src) => {
      this.updateImage(pageImage, { image: image, src: src });
    }

    return (
      <PageImage key={`page-image-${key}`}
                 pageImage={pageImage}
                 locale={this.props.locale}
                 locales={this.props.locales}
                 csrf_token={this.props.csrf_token}
                 startDrag={this.startImageDrag}
                 index={this.index(pageImage)}
                 primary={primary}
                 onUpdate={onUpdate}
                 deleteImage={this.deleteImage}
                 placeholder={dragging && dragging == pageImage} />
    );
  }

  render() {
    let { dragging, deleted } = this.state;
    let { primary, additional } = this.getDraggedOrder();
    return (
      <div className="page-images"
           ref={this.container}
           onDragOver={this.drag}
           onDrop={this.dragEnd}>
        {dragging && this.renderDrag()}
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
                      ref={this.uploadPrimaryInput} />
             </div>
          )}
          <input type="hidden" name="page[image_id]"
                 value={(primary && primary.image && primary.image.id) || ""} />
        </div>
        <div className="additional" ref={this.additionalContainer}>
          <h3>
            More images
          </h3>
          <div className="drop-target">
            <span>
              Drag and drop image here, or
              <button onClick={this.triggerUploadAdditional}>
                choose a file
              </button>
            </span>
            <input type="file"
                   onChange={this.uploadAdditional}
                   ref={this.uploadAdditionalInput} />
          </div>
          <div className="images">
            {additional.map(pi => this.renderImage(pi, false))}
          </div>
        </div>
        <div className="deleted">
          {deleted.map(pi => this.renderDeletedImage(pi))}
        </div>
      </div>
    );
  }

  renderDeletedImage(pi) {
    let image = pi.image;
    let index = this.index(pi);
    return (
      <span className="deleted-image" key={`deleted-${pi.id}`}>
        <input name={`page[page_images_attributes][${index}][id]`}
               type="hidden" value={pi.id} />
        <input name={`page[page_images_attributes][${index}][image_id]`}
               type="hidden" value={(image && image.id) || ""} />
        <input name={`page[page_images_attributes][${index}][_destroy]`}
               type="hidden" value={true} />
      </span>
    );
  }

  startImageDrag(evt, pageImage) {
    let position = this.mousePosition(evt);
    let prevDisplay = pageImage.ref.current.style.display;
    pageImage.ref.current.style.display = "none";
    this.cachePositions();
    pageImage.ref.current.style.display = prevDisplay;
    this.setState({ dragging: pageImage, x: position.x, y: position.y });
  }

  updateImage(pageImage, attrs) {
    if (this.state.primary === pageImage) {
      this.setState({ primary: { ...pageImage, ...attrs } });
    } else {
      let additional = this.state.additional.slice();
      additional[additional.indexOf(pageImage)] = { ...pageImage, ...attrs };
      this.setState({ additional: additional });
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

  triggerUploadAdditional(evt) {
    evt.preventDefault();
    this.uploadAdditionalInput.current.click();
  }

  triggerUploadPrimary(evt) {
    evt.preventDefault();
    this.uploadPrimaryInput.current.click();
  }

  uploadAdditional(evt) {
    let uploadedFile = this.uploadFile(evt.target.files[0]);
    this.setState({ additional: [...this.state.additional, uploadedFile] });
  }

  uploadPrimary(evt) {
    let uploadedFile = this.uploadFile(evt.target.files[0]);
    var primary = this.state.primary;
    var additional = this.state.additional;
    if (primary) {
      additional = [primary, ...additional];
    }
    primary = uploadedFile;
    this.setState({ primary: primary, additional: additional });
  }
}
