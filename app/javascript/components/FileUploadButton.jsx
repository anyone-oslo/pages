import React, { useRef } from "react";
import PropTypes from "prop-types";

export default function FileUploadButton(props) {
  const inputRef = useRef();

  const handleChange = (evt) => {
    let fileList = evt.target.files;
    let files = [];
    for (var i = 0; i < fileList.length; i++) {
      files.push(fileList[i]);
    }
    if (files.length > 0) {
      props.callback(files);
    }
  };

  const triggerDialog = (evt) => {
    evt.preventDefault();
    inputRef.current.click();
  };

  return (
    <div className="upload-button">
      <span>
        Drag and drop {props.type || "file"}
        {props.multiple && "s"} here, or
        {props.multiline && <br />}
        <button onClick={triggerDialog}>
          choose a file
        </button>
      </span>
      <input type="file"
             onChange={handleChange}
             ref={inputRef}
             style={{ display: "none" }}
             multiple={props.multiple || false} />
    </div>
  );
}

FileUploadButton.propTypes = {
  callback: PropTypes.func,
  type: PropTypes.string,
  multiple: PropTypes.bool,
  multiline: PropTypes.bool
};
