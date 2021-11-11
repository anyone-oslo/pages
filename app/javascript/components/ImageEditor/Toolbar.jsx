import React from "react";
import PropTypes from "prop-types";

export default function Toolbar(props) {
  const aspectRatios = [
    ["Free", null], ["1:1", 1],    ["3:2", 3/2], ["2:3", 2/3],
    ["4:3", 4/3],   ["3:4", 3/4],  ["5:4", 5/4], ["4:5", 4/5],
    ["16:9", 16/9]
  ];

  const updateAspect = (ratio) => (evt) => {
    evt.preventDefault();
    props.setAspect(ratio);
  };

  const width = Math.ceil(props.cropState.crop_width);
  const height = Math.ceil(props.cropState.crop_height);
  const format = props.image.content_type.split("/")[1].toUpperCase();

  return (
    <div className="toolbars">
      <div className="toolbar">
        <div className="info">
          <span className="format">
            {width}x{height} {format}
          </span>
        </div>
        <button title="Crop image"
                onClick={props.toggleCrop}
                className={props.cropping ? "active" : ""}>
          <i className="fa fa-crop" />
        </button>
        <button disabled={props.cropping}
                title="Toggle focal point"
                onClick={props.toggleFocal}>
          <i className="fa fa-bullseye" />
        </button>
        <a href={props.image.original_url}
           className="button"
           title="Download original image"
           disabled={props.cropping}
           download={props.image.filename}
           onClick={evt => props.cropping && evt.preventDefault()}>
          <i className="fa fa-download" />
        </a>
      </div>
      {props.cropping && (
        <div className="aspect-ratios toolbar">
          <div className="label">
            Lock aspect ratio:
          </div>
          {aspectRatios.map(ratio => (
            <button key={"ratio-" + ratio[1]}
                    className={(ratio[1] == props.cropState.aspect) ? "active" : ""}
                    onClick={updateAspect(ratio[1])}>
              {ratio[0]}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

Toolbar.propTypes = {
  cropState: PropTypes.object,
  cropping: PropTypes.bool,
  image: PropTypes.object,
  setAspect: PropTypes.func,
  toggleCrop: PropTypes.func,
  toggleFocal: PropTypes.func
};
