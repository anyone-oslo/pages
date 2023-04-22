import React, { useState } from "react";
import ImageEditor from "./ImageEditor";
import useModalStore from "../stores/useModalStore";

import { Locale, ImageResource } from "../types";

interface EditableImageProps {
  image: ImageResource,
  src: string,
  caption: boolean,
  locale: string,
  locales: Record<string, Locale>,
  width: number,
  onUpdate?: (newImage: ImageResource, src: string) => void
}

export default function EditableImage(props: EditableImageProps) {
  const [image, setImage] = useState(props.image);
  const [src, setSrc] = useState(props.src);

  const openModal = useModalStore((state) => state.open);

  const height = () => {
    const width = image.crop_width || image.real_width;
    const height = image.crop_height || image.real_height;
    return Math.round((height / width) * props.width);
  };

  const updateImage = (updatedImage: ImageResource, src: string) => {
    const newImage = { ...image, ...updatedImage };
    setSrc(src);
    setImage(newImage);
    if (props.onUpdate) {
      props.onUpdate(newImage, src);
    }
  };

  const handleClick = (evt: Event) => {
    evt.preventDefault();
    openModal(
      <ImageEditor
        image={image}
        caption={props.caption}
        locale={props.locale}
        locales={props.locales}
        onUpdate={updateImage} />
    );
  };

  const altWarning = !image.alternative[props.locale];

  return (
    <div className="editable-image">
      {altWarning &&
       <span className="alt-warning" title="Alternative text is missing">
         <i className="fa-solid fa-triangle-exclamation icon" />
       </span>}
      <img src={src}
           width={props.width}
           height={height()}
           onClick={handleClick} />
    </div>
  );
}
