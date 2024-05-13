import React from "react";
import Attachment from "./Attachment";
import Placeholder from "./Placeholder";
import FileUploadButton from "../FileUploadButton";
import { post } from "../../lib/request";

import { createDraggable, draggedOrder, useDragUploader } from "../drag";

interface Props extends Attachments.Options {
  state: Attachments.State;
}

function filenameToName(str: string): string {
  return str.replace(/\.[\w\d]+$/, "").replace(/_/g, " ");
}

export default function List(props: Props) {
  const { collection, deleted, setDeleted } = props.state;
  const locales = props.locales ? Object.keys(props.locales) : [props.locale];

  const uploadAttachment = (file: File) => {
    const name = {};
    locales.forEach((l) => (name[l] = file.name));

    const draggable = createDraggable({
      attachment: { filename: file.name, name: name },
      uploading: true
    });

    const data = new FormData();

    data.append("attachment[file]", file);
    locales.forEach((l) => {
      data.append(`attachment[name][${l}]`, filenameToName(file.name));
    });

    void post("/admin/attachments.json", data).then(
      (json: AttachmentResource) => {
        collection.dispatch({
          type: "update",
          payload: {
            ...draggable,
            record: { attachment: json, uploading: false }
          }
        });
      }
    );

    return draggable;
  };

  const receiveFiles = (files: File[]) => {
    collection.dispatch({
      type: "append",
      payload: files.map((f) => uploadAttachment(f))
    });
  };

  const dragEnd = (dragState: Drag.State, files: File[]) => {
    collection.dispatch({
      type: "reorder",
      payload: draggedOrder(collection, dragState)
    });
    collection.dispatch({
      type: "insertFiles",
      payload: files.map((f) => uploadAttachment(f))
    });
  };

  const [dragState, dragStart, listeners] = useDragUploader<AttachmentRecord>(
    [collection],
    dragEnd
  );

  const position = (record: AttachmentRecord) => {
    return (
      [
        ...collection.draggables.map(
          (d: Drag.Draggable<AttachmentRecord>) => d.record
        ),
        ...deleted
      ].indexOf(record) + 1
    );
  };

  const attrName = (record: AttachmentRecord) => {
    return `${props.attribute}[${position(record)}]`;
  };

  const update =
    (draggable: Drag.Draggable<AttachmentRecord>) =>
    (attachment: Partial<AttachmentResource>) => {
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

  const remove = (draggable: Drag.Draggable<AttachmentRecord>) => () => {
    collection.dispatch({ type: "remove", payload: draggable });
    if (draggable.record.id) {
      setDeleted([...deleted, draggable.record]);
    }
  };

  const attachment = (draggable: Drag.Item<AttachmentRecord>) => {
    const { dragging } = dragState;

    if (draggable === "Files") {
      return <Placeholder key="placeholder" />;
    }

    return (
      <Attachment
        key={draggable.handle}
        draggable={draggable}
        locale={props.locale}
        locales={props.locales}
        showEmbed={props.showEmbed}
        startDrag={dragStart}
        position={position(draggable.record)}
        onUpdate={update(draggable)}
        deleteRecord={remove(draggable)}
        attributeName={attrName(draggable.record)}
        placeholder={dragging && dragging == draggable}
      />
    );
  };

  const dragOrder = draggedOrder(collection, dragState);

  const classes = ["attachments"];
  if (dragState.dragging) {
    classes.push("dragover");
  }

  return (
    <div className={classes.join(" ")} ref={collection.ref} {...listeners}>
      <div className="files">{dragOrder.map((d) => attachment(d))}</div>
      <div className="deleted">
        {deleted.map((r) => (
          <span className="deleted-attachment" key={r.id}>
            <input name={`${attrName(r)}[id]`} type="hidden" value={r.id} />
            <input
              name={`${attrName(r)}[attachment_id]`}
              type="hidden"
              value={(r.attachment && r.attachment.id) || ""}
            />
            <input
              name={`${attrName(r)}[_destroy]`}
              type="hidden"
              value="true"
            />
          </span>
        ))}
      </div>
      <div className="drop-target">
        <FileUploadButton
          multiple={true}
          multiline={true}
          callback={receiveFiles}
        />
      </div>
    </div>
  );
}
