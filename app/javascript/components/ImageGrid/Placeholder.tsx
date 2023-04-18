import React from "react";

interface PlaceholderProps {
  src: string
}

export default function Placeholder(props: PlaceholderProps) {
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
