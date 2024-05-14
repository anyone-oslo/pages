import React, { MouseEvent } from "react";

import * as Crop from "../../types/Crop";
import * as Images from "../../types/Images";

type Ratio = number | null;

interface Props {
  cropState: Crop.State;
  image: Images.Resource;
  setAspect: (Ratio) => void;
  toggleCrop: (evt: MouseEvent) => void;
  toggleFocal: (evt: MouseEvent) => void;
}

export default function Toolbar(props: Props) {
  const { cropping } = props.cropState;

  const aspectRatios: Array<[string, Ratio]> = [
    ["Free", null],
    ["1:1", 1],
    ["3:2", 3 / 2],
    ["2:3", 2 / 3],
    ["4:3", 4 / 3],
    ["3:4", 3 / 4],
    ["5:4", 5 / 4],
    ["4:5", 4 / 5],
    ["16:9", 16 / 9]
  ];

  const updateAspect = (ratio: Ratio) => (evt: MouseEvent) => {
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
        <button
          title="Crop image"
          onClick={props.toggleCrop}
          className={cropping ? "active" : ""}>
          <i className="fa-solid fa-crop" />
        </button>
        <button
          disabled={cropping}
          title="Toggle focal point"
          onClick={props.toggleFocal}>
          <i className="fa-solid fa-bullseye" />
        </button>
        <a
          href={props.image.original_url}
          className="button"
          title="Download original image"
          download={props.image.filename}
          onClick={(evt) => cropping && evt.preventDefault()}>
          <i className="fa-solid fa-download" />
        </a>
      </div>
      {cropping && (
        <div className="aspect-ratios toolbar">
          <div className="label">Lock aspect ratio:</div>
          {aspectRatios.map((ratio) => (
            <button
              key={ratio[0]}
              className={ratio[1] == props.cropState.aspect ? "active" : ""}
              onClick={updateAspect(ratio[1])}>
              {ratio[0]}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
