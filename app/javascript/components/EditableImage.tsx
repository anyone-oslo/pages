import { MouseEvent, useState } from "react";

import useModalStore from "../stores/useModalStore";
import * as Images from "../types/Images";
import { Locale } from "../types";

import ImageEditor from "./ImageEditor";

interface Props {
  image: Images.Resource;
  src: string;
  caption: boolean;
  locale: string;
  locales: Record<string, Locale>;
  width: number;
  onUpdate?: (newImage: Images.Resource, src: string) => void;
}

export default function EditableImage(props: Props) {
  const [image, setImage] = useState(props.image);
  const [src, setSrc] = useState(props.src);

  const openModal = useModalStore((state) => state.open);

  const height = () => {
    const width = image.crop_width || image.real_width;
    const height = image.crop_height || image.real_height;
    return Math.round((height / width) * props.width);
  };

  const updateImage = (updatedImage: Images.Resource, src: string) => {
    const newImage = { ...image, ...updatedImage };
    setSrc(src);
    setImage(newImage);
    if (props.onUpdate) {
      props.onUpdate(newImage, src);
    }
  };

  const handleClick = (evt: MouseEvent) => {
    evt.preventDefault();
    openModal(
      <ImageEditor
        image={image}
        caption={props.caption}
        locale={props.locale}
        locales={props.locales}
        onUpdate={updateImage}
      />
    );
  };

  const altWarning = !image.alternative[props.locale];

  return (
    <div className="editable-image">
      {altWarning && (
        <span className="alt-warning" title="Alternative text is missing">
          <i className="fa-solid fa-triangle-exclamation icon" />
        </span>
      )}
      <img
        src={src}
        width={props.width}
        height={height()}
        onClick={handleClick}
      />
    </div>
  );
}
