import * as Crop from "../../types/Crop";
import useImageCropperContext from "./useImageCropperContext";

export default function Toolbar() {
  const { state, dispatch } = useImageCropperContext();
  const { cropping, image } = state;

  const aspectRatios: Array<[string, Crop.Ratio]> = [
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

  const updateAspect = (ratio: Crop.Ratio) => (evt: React.MouseEvent) => {
    evt.preventDefault();
    dispatch({ type: "setAspect", payload: ratio });
  };

  const toggleCrop = () => {
    if (state.cropping) {
      dispatch({ type: "completeCrop" });
    } else {
      dispatch({ type: "startCrop" });
    }
  };

  const toggleFocal = () => {
    dispatch({ type: "toggleFocal" });
  };

  const width = Math.ceil(state.crop_width);
  const height = Math.ceil(state.crop_height);
  const format = image.content_type.split("/")[1].toUpperCase();

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
          onClick={toggleCrop}
          className={cropping ? "active" : ""}>
          <i className="fa-solid fa-crop" />
        </button>
        <button
          disabled={cropping}
          title="Toggle focal point"
          onClick={toggleFocal}>
          <i className="fa-solid fa-bullseye" />
        </button>
        <a
          href={image.original_url}
          className="button"
          title="Download original image"
          download={image.filename}
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
              className={ratio[1] == state.aspect ? "active" : ""}
              onClick={updateAspect(ratio[1])}>
              {ratio[0]}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
