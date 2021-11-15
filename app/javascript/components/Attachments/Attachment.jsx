import React from "react";
import PropTypes from "prop-types";
import copyToClipboard from "../../lib/copyToClipboard";
import AttachmentEditor from "./AttachmentEditor";
import ModalStore from "../ModalStore";
import ToastStore from "../ToastStore";

export default function Attachment(props) {
  const { attributeName, draggable } = props;
  const { record } = draggable;
  const { attachment, uploading } = record;

  const copyEmbed = (evt) => {
    evt.preventDefault();
    copyToClipboard(`[attachment:${attachment.id}]`);
    ToastStore.dispatch({
      type: "NOTICE", message: "Embed code copied to clipboard"
    });
  };

  const deleteRecord = (evt) => {
    evt.preventDefault();
    if (props.deleteRecord) {
      props.deleteRecord();
    }
  };

  const description = () => {
    if (attachment.description && attachment.description[props.locale]) {
      return attachment.description[props.locale];
    }
    return null;
  };

  const name = () => {
    if (attachment.name && attachment.name[props.locale]) {
      return attachment.name[props.locale];
    }
    return null;
  };

  const editAttachment = (evt) => {
    evt.preventDefault();
    ModalStore.dispatch({
      type: "OPEN",
      payload: <AttachmentEditor attachment={attachment}
                                 locale={props.locale}
                                 locales={props.locales}
                                 onUpdate={props.onUpdate} />
    });
  };

  const classes = ["attachment"];
  if (props.placeholder) {
    classes.push("placeholder");
  }
  if (record.uploading) {
    classes.push("uploading");
  }

  const icon = uploading ? "cloud-upload" : "paperclip";

  return (
    <div className={classes.join(" ")}
         onDragStart={props.startDrag}
         ref={draggable.ref}
         draggable>
      <input name={`${attributeName}[id]`}
             type="hidden" value={record.id || ""} />
      <input name={`${attributeName}[attachment_id]`}
             type="hidden" value={(attachment && attachment.id) || ""} />
      <input name={`${attributeName}[position]`}
             type="hidden" value={props.position} />
      {props.enablePrimary && (
        <input name={`${attributeName}[primary]`}
               type="hidden" value={props.primary} />
      )}
      {!uploading &&
       <div className="actions">
         <button onClick={editAttachment}>
           Edit
         </button>
         {props.showEmbed && (
           <button onClick={copyEmbed}>
             Embed
           </button>
         )}
         {props.deleteRecord && (
           <button onClick={deleteRecord}>
             Remove
           </button>
         )}
       </div>
      }
    {attachment &&
     <div className="attachment-info">
       <h3>
         <i className={`fa fa-${icon} icon`} />
         {name() || <em>Untitled</em>}<br />
       </h3>
       {!uploading &&
        <a href={attachment.url}
           rel="noreferrer"
           target="_blank">{attachment.filename}</a>}
       {!uploading && description() && <p>{description()}</p>}
     </div>}
    </div>
  );
}

Attachment.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  draggable: PropTypes.object,
  deleteRecord: PropTypes.func,
  startDrag: PropTypes.func,
  showEmbed: PropTypes.bool,
  enablePrimary: PropTypes.bool,
  onUpdate: PropTypes.func,
  attributeName: PropTypes.string,
  placeholder: PropTypes.bool,
  position: PropTypes.number,
  primary: PropTypes.bool,
  ref: PropTypes.object
};
