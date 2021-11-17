import React, { useEffect, useState } from "react";
import PropTypes from "prop-types";
import copyToClipboard from "../../lib/copyToClipboard";
import EditableImage from "../EditableImage";
import ToastStore from "../../stores/ToastStore";
import Placeholder from "./Placeholder";

import { useDraggable } from "../drag";

export default function GridImage(props) {
  const { attributeName, draggable } = props;
  const record = draggable.record;
  const image = record.image;

  const [src, setSrc] = useState(record.src || null);

  const dragAttrs = useDraggable(draggable, props.startDrag);

  useEffect(() => {
    if (record.file) {
      const reader = new FileReader();
      reader.onload = () => setSrc(reader.result);
      reader.readAsDataURL(record.file);
    }
  }, []);

  const copyEmbed = (evt) => {
    evt.preventDefault();
    copyToClipboard(`[image:${image.id}]`);
    ToastStore.dispatch({
      type: "NOTICE", message: "Embed code copied to clipboard"
    });
  };

  const deleteImage = (evt) => {
    evt.preventDefault();
    if (props.deleteImage) {
      props.deleteImage();
    }
  };

  let classes = ["grid-image"];
  if (props.placeholder) {
    classes.push("placeholder");
  }
  if (record.file) {
    classes.push("uploading");
  }

  return (
    <div className={classes.join(" ")}
         {...dragAttrs}>
      <input name={`${attributeName}[id]`}
             type="hidden" value={record.id || ""} />
      <input name={`${attributeName}[image_id]`}
             type="hidden" value={(image && image.id) || ""} />
      <input name={`${attributeName}[position]`}
             type="hidden" value={props.position} />
      {props.enablePrimary && (
        <input name={`${attributeName}[primary]`}
               type="hidden" value={props.primary} />
      )}
      {!image &&
       <Placeholder src={src} />}
      {image &&
       <>
         <EditableImage image={image}
                        src={src || image.thumbnail_url}
                        width={250}
                        caption={true}
                        locale={props.locale}
                        locales={props.locales}
                        onUpdate={props.onUpdate} />
         <div className="actions">
           {props.showEmbed && (
             <button onClick={copyEmbed}>
               Embed
             </button>
           )}
           {props.deleteImage && (
             <button onClick={deleteImage}>
               Remove
             </button>
           )}
         </div>
       </>}
    </div>
  );
}
GridImage.propTypes = {
  draggable: PropTypes.object,
  deleteImage: PropTypes.func,
  startDrag: PropTypes.func,
  locale: PropTypes.string,
  locales: PropTypes.object,
  onUpdate: PropTypes.func,
  attributeName: PropTypes.string,
  placeholder: PropTypes.bool,
  enablePrimary: PropTypes.bool,
  showEmbed: PropTypes.bool,
  primary: PropTypes.bool,
  position: PropTypes.number,
};
