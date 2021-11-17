import React, { useState } from "react";
import PropTypes from "prop-types";
import EditableImage from "./EditableImage";
import FileUploadButton from "./FileUploadButton";
import ToastStore from "./ToastStore";
import { post } from "../lib/request";

function getFiles(dt) {
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

export default function ImageUploader(props) {
  const [uploading, setUploading] = useState(false);
  const [dragover, setDragover] = useState(false);
  const [image, setImage] = useState(props.image);
  const [src, setSrc] = useState(props.src);

  const handleDragOver = (evt) => {
    evt.preventDefault();
    setDragover(true);
  };

  const handleDragLeave = () => {
    setDragover(false);
  };

  const handleDragEnd = (evt) => {
    if (evt.dataTransfer.items) {
      for (var i = 0; i < evt.dataTransfer.items.length; i++) {
        evt.dataTransfer.items.remove(i);
      }
    } else {
      evt.dataTransfer.clearData();
    }
    setDragover(false);
  };

  const handleDrop = (evt) => {
    let files = getFiles(evt.dataTransfer);
    evt.preventDefault();
    if (files.length > 0) {
      uploadImage(files[0]);
    }
  };

  const handleRemove = (evt) => {
    evt.preventDefault();
    setImage(null);
    setSrc(null);
  };

  const receiveFiles = (files) => {
    if (files.length > 0) {
      uploadImage(files[0]);
    }
  };

  const uploadImage = (file) => {
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

    let locale = props.locale;
    let locales = props.locales ? Object.keys(props.locales) : [locale];

    let data = new FormData();

    setImage(null);
    setSrc(null);
    setDragover(false);
    setUploading(true);

    data.append("image[file]", file);
    locales.forEach((l) => {
      data.append(`image[alternative][${l}]`, (props.alternative || ""));
    });

    post("/admin/images.json", data)
      .then(response => {
        setUploading(false);
        if (response.status === "error") {
          ToastStore.dispatch({
            type: "ERROR",
            message: "Error uploading image: " + response.error
          });
        } else {
          setSrc(response.thumbnail_url);
          setImage(response);
        }
      });
  };

  let classes = ["image-uploader"];
  if (uploading) {
    classes.push("uploading");
  } else if (dragover) {
    classes.push("dragover");
  }
  return (
    <div className={classes.join(" ")}
         onDragOver={handleDragOver}
         onDragLeave={handleDragLeave}
         onDragEnd={handleDragEnd}
         onDrop={handleDrop}>
      <input type="hidden"
             name={props.attr}
             value={image ? image.id : ""} />
      {image &&
       <div className="image">
         <EditableImage image={image}
                        src={src}
                        width={props.width}
                        caption={props.caption}
                        locale={props.locale}
                        locales={props.locales} />
       </div>}
      <div className="ui-wrapper">
        {uploading && (
          <div className="ui">
            Uploading image...
          </div>
        )}
        {!uploading && (
          <div className="ui">
            <FileUploadButton type="image"
                              multiline={true}
                              callback={receiveFiles} />
            {image && (
              <a className="delete remove-image"
                 href="#"
                 onClick={handleRemove}>
                Remove image
              </a>
            )}
          </div>
        )}
      </div>
    </div>
  );
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
