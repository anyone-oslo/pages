import { MouseEvent, useEffect, useState } from "react";

import copyToClipboard from "../../lib/copyToClipboard";
import useToastStore from "../../stores/useToastStore";
import * as Drag from "../../types/Drag";
import * as Images from "../../types/Images";
import { Locale } from "../../types";
import { useDraggable } from "../drag";

import EditableImage from "../EditableImage";
import Placeholder from "./Placeholder";

interface Props {
  draggable: Drag.Draggable<Images.Record>;
  attributeName: string;
  locale: string;
  locales: { [index: string]: Locale };
  placeholder: boolean;
  enablePrimary: boolean;
  showEmbed: boolean;
  primary: boolean;
  position: number;
  deleteImage: () => void;
  startDrag: (
    evt: MouseEvent,
    draggable: Drag.Draggable<Images.Record>
  ) => void;
  onUpdate: (newImage: Images.Resource, src: string) => void;
}

export default function GridImage(props: Props) {
  const { attributeName, draggable } = props;
  const record = draggable.record;
  const image = record.image;

  const notice = useToastStore((state) => state.notice);

  const [src, setSrc] = useState<string>(record.src || null);

  const dragAttrs = useDraggable(draggable, props.startDrag);

  useEffect(() => {
    if ("file" in record && record.file) {
      const reader = new FileReader();
      reader.onload = () => setSrc(reader.result as string);
      reader.readAsDataURL(record.file);
    }
  }, [record]);

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
  if ("file" in record) {
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
