import React from "react";
import PropTypes from "prop-types";
import DragUploader from "./DragUploader";
import FileUploadButton from "./FileUploadButton";
import GridImage from "./GridImage";
import ToastStore from "./ToastStore";

export default class ImageGrid extends DragUploader {
  constructor(props) {
    super(props);

    this.validMimeTypes = ["image/gif",
                           "image/jpeg",
                           "image/pjpeg",
                           "image/png",
                           "image/tiff"];

    let records = props.records.map(
      r => ({ ...r, ref: React.createRef(), handle: this.getHandle() })
    );

    this.state = { ...this.state,
                   primary: null,
                   images: records,
                   deleted: [] };

    if (props.enablePrimary) {
      this.state = { ...this.state,
                     primary: records.filter(r => r.primary)[0] || null,
                     images: records.filter(r => !r.primary) };
    }

    this.container = React.createRef();
    this.imagesContainer = React.createRef();
    this.primaryContainer = React.createRef();

    this.deleteImage = this.deleteImage.bind(this);
    this.uploadAdditional = this.uploadAdditional.bind(this);
    this.uploadPrimary = this.uploadPrimary.bind(this);
  }

  attributeName(record) {
    return `${this.props.attribute}[${this.index(record) + 1}]`;
  }

  draggables() {
    return this.state.images;
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
    this.setState({ primary: primary, images: images, deleted: deleted });
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

  receiveFiles(files, newState) {
    var { primary, images } = this.getDraggedOrder();

    if (files.length > 0) {
      ({ primary, images } = this.injectUploads(
        files.map(f => this.uploadImage(f)), primary, images
      ));
    }

    this.setState({...newState, primary: primary, images: images});
  }

  index(record) {
    let { primary, images, deleted } = this.state;
    var ordered = [...images, ...deleted];
    if (primary) {
      ordered = [primary, ...ordered];
    }
    return ordered.indexOf(record);
  }

  renderDrag() {
    let record = this.state.dragging;
    if (record === "Files") {
      return "";
    } else {
      let containerSize = this.container.current.getBoundingClientRect();
      let x = this.state.x - (containerSize.x || containerSize.left);
      let y = this.state.y - (containerSize.y || containerSize.top);
      let translateStyle = {
        transform: `translate3d(${x}px, ${y}px, 0)`
      };
      return (
        <div className="drag-image" style={translateStyle}>
          {record.image && (
             <img src={record.src || record.image.thumbnail_url} />
          )}
        </div>
      );
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
    if (record === "Files") {
      return (
        <div className="grid-image" key="file-placeholder">
          <div className="file-placeholder" />
        </div>
      );
    }

    let onUpdate = (image, src) => {
      this.updateImage(record, { image: image, src: src });
    };

    return (
      <GridImage key={record.handle}
                 record={record}
                 locale={this.props.locale}
                 locales={this.props.locales}
                 csrf_token={this.props.csrf_token}
                 showEmbed={this.props.showEmbed}
                 startDrag={this.startDrag}
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
                 <FileUploadButton multiple={true}
                                   type="image"
                                   multiline={true}
                                   callback={this.uploadPrimary} />
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
            {this.props.enablePrimary ? "More images" : "Images"}
          </h3>
          <div className="drop-target">
            <FileUploadButton multiple={true}
                              type="image"
                              callback={this.uploadAdditional} />
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

  updateImage(record, attrs) {
    if (this.state.primary === record) {
      this.setState({ primary: { ...record, ...attrs } });
    } else {
      let images = this.state.images.slice();
      images[images.indexOf(record)] = { ...record, ...attrs };
      this.setState({ images: images });
    }
  }

  uploadImage(file) {
    let component = this;
    var obj = { image: null, file: file, ref: React.createRef(),
                handle: this.getHandle() };

    let data = new FormData();

    data.append("image[file]", file);
    this.postFile("/admin/images.json", data, function (json) {
      if (json.status === "error") {
        ToastStore.dispatch({
          type: "ERROR", message: "Error uploading image: " + json.error
        });
        component.deleteImage(obj);
      } else {
        let preloader = new Image();
        obj.file = null;
        obj.image = json;
        preloader.onload = () => component.setState({});
        preloader.src = obj.image.thumbnail_url;
      }
    });

    return obj;
  }

  uploadAdditional(files) {
    this.setState({
      images: [...this.state.images,
               ...files.map(f => this.uploadImage(f))]
    });
  }

  uploadPrimary(files) {
    let uploadedFiles = files.map(f => this.uploadImage(f));
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

ImageGrid.propTypes = {
  records: PropTypes.array,
  enablePrimary: PropTypes.bool
};
