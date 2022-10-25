import React, { useState } from "react";
import PropTypes from "prop-types";
import Attachment from "./Attachments/Attachment";
import Placeholder from "./Attachments/Placeholder";
import FileUploadButton from "./FileUploadButton";
import { post } from "../lib/request";

import { createDraggable,
         draggedOrder,
         useDragCollection,
         useDragUploader } from "./drag";

function filenameToName(str) {
  return str.replace(/\.[\w\d]+$/, "").replace(/_/g, " ");
}

export default function Attachments(props) {
  const collection = useDragCollection(props.records);
  const locales = props.locales && props.locales.length > 0 ?
        Object.keys(props.locales) : [props.locale];
  const [deleted, setDeleted] = useState([]);

  const uploadAttachment = (file) => {
    let name = {};
    locales.forEach((l) => name[l] = file.name);

    const draggable = createDraggable(
      { attachment: { filename: file.name, name: name },
        uploading: true }
    );

    let data = new FormData();

    data.append("attachment[file]", file);
    locales.forEach((l) => {
      data.append(`attachment[name][${l}]`, filenameToName(file.name));
    });

    post("/admin/attachments.json", data)
      .then(json => {
        collection.dispatch({
          type: "update",
          payload: { ...draggable,
                     record: { attachment: json, uploading: false } }
        });
      });

    return draggable;
  };

  const receiveFiles = (files) => {
    collection.dispatch({
      type: "append",
      payload: files.map(f => uploadAttachment(f))
    });
  };

  const dragEnd = (dragState, files) => {
    collection.dispatch({
      type: "reorder",
      payload: draggedOrder(collection, dragState)
    });
    collection.dispatch({
      type: "insertFiles",
      payload: files.map(f => uploadAttachment(f))
    });
  };

  const [dragState,
         dragStart,
         listeners] = useDragUploader([collection], dragEnd);

  const position = (record) => {
    return [...collection.draggables.map(d => d.record),
            ...deleted].indexOf(record) + 1;
  };

  const attrName = (record) => {
    return `${props.attribute}[${position(record)}]`;
  };

  const update = (draggable) => (attachment) => {
    const { record } = draggable;
    const updated = {
      ...draggable,
      record: {
        ...record,
        attachment: { ...record.attachment, ...attachment }
      }
    };
    collection.dispatch({ type: "update", payload: updated });
  };

  const remove = (draggable) => () => {
    collection.dispatch({ type: "remove", payload: draggable });
    if (draggable.record.id) {
      setDeleted([...deleted, draggable.record]);
    }
  };

  const attachment = (draggable) => {
    const { dragging } = dragState;

    if (draggable === "Files") {
      return (<Placeholder key="placeholder" />);
    }

    return (
      <Attachment key={draggable.handle}
                  draggable={draggable}
                  locale={props.locale}
                  locales={props.locales}
                  showEmbed={props.showEmbed}
                  startDrag={dragStart}
                  position={position(draggable.record)}
                  onUpdate={update(draggable)}
                  deleteRecord={remove(draggable)}
                  attributeName={attrName(draggable.record)}
                  placeholder={dragging && dragging == draggable} />
    );
  };

  const dragOrder = draggedOrder(collection, dragState);

  const classes = ["attachments"];
  if (dragState.dragging) {
    classes.push("dragover");
  }

  return (
    <div className={classes.join(" ")}
         ref={collection.ref}
         {...listeners}>
      <div className="files">
        {dragOrder.map(d => attachment(d))}
      </div>
      <div className="deleted">
        {deleted.map(r =>
          <span className="deleted-attachment" key={r.id}>
            <input name={`${attrName(r)}[id]`}
                   type="hidden"
                   value={r.id} />
            <input name={`${attrName(r)}[attachment_id]`}
                   type="hidden"
                   value={(r.attachment && r.attachment.id) || ""} />
            <input name={`${attrName(r)}[_destroy]`}
                   type="hidden"
                   value={true} />
          </span>)}
      </div>
      <div className="drop-target">
        <FileUploadButton multiple={true}
                          multiline={true}
                          callback={receiveFiles} />
      </div>
    </div>
  );
}

Attachments.propTypes = {
  attribute: PropTypes.string,
  locale: PropTypes.string,
  locales: PropTypes.object,
  records: PropTypes.array,
  showEmbed: PropTypes.bool
};
