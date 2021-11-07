import React from "react";
import PropTypes from "prop-types";

export default function Placeholder(props) {
  if (props.src) {
    return (
      <div className="temp-image">
        <img src={props.src} />
        <span>Uploading...</span>
      </div>
    );
  } else {
    return (
      <div className="file-placeholder">
        <span>Uploading...</span>
      </div>
    );
  }
}

Placeholder.propTypes = {
  src: PropTypes.string
};
