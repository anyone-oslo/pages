import React, { useState } from "react";
import PropTypes from "prop-types";
import ImageEditor from "./ImageEditor";
import ModalStore from "../stores/ModalStore";

export default function EditableImage(props) {
  const [image, setImage] = useState(props.image);
  const [src, setSrc] = useState(props.src);

  const height = () => {
    const width = image.crop_width || image.real_width;
    const height = image.crop_height || image.real_height;
    return Math.round((height / width) * props.width);
  };

  const updateImage = (updatedImage, src) => {
    let newImage = { ...image, ...updatedImage };
    setSrc(src);
    setImage(newImage);
    if (props.onUpdate) {
      props.onUpdate(newImage, src);
    }
  };

  const handleClick = (evt) => {
    evt.preventDefault();
    ModalStore.dispatch({
      type: "OPEN",
      payload: <ImageEditor image={image}
                            caption={props.caption}
                            locale={props.locale}
                            locales={props.locales}
                            onUpdate={updateImage} />
    });
  };

  const altWarning = !image.alternative[props.locale];

  return (
    <div className="editable-image">
      {altWarning &&
       <span className="alt-warning" title="Alternative text is missing">
         <i className="fa fa-exclamation-triangle icon" />
       </span>}
      <img src={src}
           width={props.width}
           height={height()}
           onClick={handleClick} />
    </div>
  );
}

EditableImage.propTypes = {
  image: PropTypes.object,
  src: PropTypes.string,
  caption: PropTypes.bool,
  locale: PropTypes.string,
  locales: PropTypes.object,
  width: PropTypes.number,
  onUpdate: PropTypes.func
};
