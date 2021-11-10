import React from "react";
import PropTypes from "prop-types";
import EditableImage from "./EditableImage";
import FileUploadButton from "./FileUploadButton";
import ToastStore from "./ToastStore";
import { post } from "../lib/request";

export default class ImageUploader extends React.Component {
  constructor(props) {
    super(props);
    this.state = { dragover: false,
                   uploading: false,
                   image: props.image,
                   src: props.src };
    this.receiveFiles = this.receiveFiles.bind(this);
    this.removeImage = this.removeImage.bind(this);
    this.dragOver = this.dragOver.bind(this);
    this.dragLeave = this.dragLeave.bind(this);
    this.dragEnd = this.dragEnd.bind(this);
    this.drop = this.drop.bind(this);
  }

  receiveFiles(files) {
    if (files.length > 0) {
      this.uploadImage(files[0]);
    }
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

  dragLeave() {
    this.setState({ dragover: false });
  }

  dragEnd(evt) {
    this.clearItems(evt.dataTransfer);
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
                       locales={this.props.locales} />
      </div>
    );
  }

  getFiles(dt) {
    var files = [];
    if (dt.items) {
      for (let i = 0; i < dt.items.length; i++) {
        if (dt.items[i].kind == "file") {
          files.push(dt.items[i].getAsFile());
        }
      }
    } else {
      for (let i = 0; i < dt.files.length; i++) {
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
              <FileUploadButton type="image"
                                multiline={true}
                                callback={this.receiveFiles} />
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

    let locale = this.props.locale;
    let locales = this.props.locales ? Object.keys(this.props.locales) : [locale];

    let component = this;
    let data = new FormData();
    this.setState({ image: null, src: null, dragover: false, uploading: true });
    data.append("image[file]", file);
    locales.forEach((l) => {
      data.append(`image[alternative][${l}]`, (this.props.alternative || ""));
    });

    post("/admin/images.json", data)
      .then(response => {
        if (response.status === "error") {
          ToastStore.dispatch({
            type: "ERROR",
            message: "Error uploading image: " + response.error
          });
          component.setState({ uploading: false });
        } else {
          component.setState({ uploading: false,
                               image: response,
                               src: response.thumbnail_url });
        }
      });
  }
}

ImageUploader.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  image: PropTypes.object,
  src: PropTypes.string,
  width: PropTypes.number,
  caption: PropTypes.bool,
  attr: PropTypes.string,
  alternative: PropTypes.string
};
