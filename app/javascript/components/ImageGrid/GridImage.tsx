import React, { DragEvent, MouseEvent, useEffect, useState } from "react";
import copyToClipboard from "../../lib/copyToClipboard";
import EditableImage from "../EditableImage";
import useToastStore from "../../stores/useToastStore";
import Placeholder from "./Placeholder";

import { useDraggable } from "../drag";

interface Record extends Drag.DraggableRecord {
  id: number | null;
  image: ImageResource;
  src: string | null;
  file: File | null;
}

interface Props {
  draggable: Drag.Draggable<Record>;
  attributeName: string;
  locale: string;
  locales: { [index: string]: Locale };
  placeholder: boolean;
  enablePrimary: boolean;
  showEmbed: boolean;
  primary: boolean;
  position: number;
  deleteImage: () => void;
  startDrag: (evt: DragEvent, draggable: Drag.Draggable) => void;
  onUpdate: (newImage: ImageResource, src: string) => void;
}

export default function GridImage(props: Props) {
  const { attributeName, draggable } = props;
  const record = draggable.record;
  const image = record.image;

  const notice = useToastStore((state) => state.notice);

  const [src, setSrc] = useState<string>(record.src || null);

  const dragAttrs = useDraggable(draggable, props.startDrag);

  useEffect(() => {
    if (record.file) {
      const reader = new FileReader();
      reader.onload = () => setSrc(reader.result as string);
      reader.readAsDataURL(record.file);
    }
  }, []);

  const copyEmbed = (evt: MouseEvent) => {
    evt.preventDefault();
    copyToClipboard(`[image:${image.id}]`);
    notice("Embed code copied to clipboard");
  };

  const deleteImage = (evt: MouseEvent) => {
    evt.preventDefault();
    if (props.deleteImage) {
      props.deleteImage();
    }
  };

  const classes = ["grid-image"];
  if (props.placeholder) {
    classes.push("placeholder");
  }
  if (record.file) {
    classes.push("uploading");
  }

  return (
    <div className={classes.join(" ")} {...dragAttrs}>
      <input
        name={`${attributeName}[id]`}
        type="hidden"
        value={record.id || ""}
      />
      <input
        name={`${attributeName}[image_id]`}
        type="hidden"
        value={(image && image.id) || ""}
      />
      <input
        name={`${attributeName}[position]`}
        type="hidden"
        value={props.position}
      />
      {props.enablePrimary && (
        <input
          name={`${attributeName}[primary]`}
          type="hidden"
          value={props.primary ? "true" : "false"}
        />
      )}
      {!image && <Placeholder src={src} />}
      {image && (
        <>
          <EditableImage
            image={image}
            key={props.placeholder ? "placeholder" : draggable.handle}
            src={src || image.thumbnail_url}
            width={250}
            caption={true}
            locale={props.locale}
            locales={props.locales}
            onUpdate={props.onUpdate}
          />
          <div className="actions">
            {props.showEmbed && <button onClick={copyEmbed}>Embed</button>}
            {props.deleteImage && <button onClick={deleteImage}>Remove</button>}
          </div>
        </>
      )}
    </div>
  );
}
