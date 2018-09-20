class ImageUploader extends React.Component {
  constructor(props) {
    super(props);
    this.state = { dragover: false,
                   uploading: false,
                   image: props.image,
                   src: props.src };
    this.browseFile = this.browseFile.bind(this);
    this.removeImage = this.removeImage.bind(this);
    this.dragOver = this.dragOver.bind(this);
    this.dragLeave = this.dragLeave.bind(this);
    this.dragEnd = this.dragEnd.bind(this);
    this.drop = this.drop.bind(this);
  }

  browseFile(evt) {
    let component = this;
    evt.preventDefault();
    let input = document.createElement("input");
    input.type = "file";
    input.addEventListener("change", function () {
      component.uploadImage(input.files[0]);
    });
    input.click();
  }

  clearItems(dt) {
    if (dt.items) {
      for (var i = 0; i < dt.items.length; i++) {
        dt.items.remove(i);
      }
    } else {
      dt.clearData();
    }
  }

  dragOver(evt) {
    evt.preventDefault();
    this.setState({ dragover: true });
  }

  dragLeave() {
    this.setState({ dragover: false });
  }

  dragEnd(evt) {
    clearItems(evt.dataTransfer);
    this.setState({ dragover: false });
  }

  drop(evt) {
    let files = this.getFiles(evt.dataTransfer);
    evt.preventDefault();
    if (files.length > 0) {
      this.uploadImage(files[0]);
    }
  }

  editableImage() {
    let image = this.state.image;
    if (!image) { return; }
    return (
      <div className="image">
        <EditableImage image={image}
                       src={this.state.src}
                       width={this.props.width}
                       caption={this.props.caption}
                       locale={this.props.locale}
                       locales={this.props.locales}
                       csrf_token={this.props.csrf_token} />
      </div>
    );
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
    return files;
  }

  render() {
    let image = this.state.image;
    let id = image ? image.id : "";
    let classes = ["image-uploader"];
    if (this.state.uploading) {
      classes.push("uploading");
    } else if (this.state.dragover) {
      classes.push("dragover");
    }
    return (
      <div className={classes.join(" ")}
           onDragOver={this.dragOver}
           onDragLeave={this.dragLeave}
           onDragEnd={this.dragEnd}
           onDrop={this.drop}>
        <input type="hidden"
               name={this.props.attr}
               value={id} />
        {this.editableImage()}
        <div className="ui-wrapper">
          {this.state.uploading && (
             <div className="ui">
               Uploading image...
             </div>
          )}
          {!this.state.uploading && (
             <div className="ui">
               Drag and drop image here, or<br />
               <button onClick={this.browseFile}>choose a file</button>
               <br />
               {image && (
                  <a className="delete remove-image"
                     href="#"
                     onClick={this.removeImage}>
                    Remove image
                  </a>
               )}
             </div>
          )}
        </div>
      </div>
    );
  }

  removeImage(evt) {
    evt.preventDefault();
    this.setState({image: null, src: null});
  }

  uploadImage(file) {
    let validTypes = ["image/gif",
                      "image/jpeg",
                      "image/pjpeg",
                      "image/png",
                      "image/tiff"];

    if (validTypes.indexOf(file.type) == -1) {
      alert("Invalid file type, only images in JPEG, PNG or GIF " +
            "formats are supported");
      return;
    }

    let component = this;
    let xhr = new XMLHttpRequest();
    let data = new FormData();
    this.setState({ image: null, src: null, dragover: false, uploading: true });
    data.append("image[file]", file);
    xhr.open("POST", "/admin/images.json");
    xhr.setRequestHeader("X-CSRF-Token", this.props.csrf_token);
    xhr.addEventListener("load", function (evt) {
      if (xhr.readyState == 4 && xhr.status == "200") {
        let image = JSON.parse(xhr.responseText);
        component.setState({ uploading: false,
                             image: image,
                             src: image.thumbnail_url });
      }
    });
    xhr.send(data);
  }
}
