import React from "react";
import copyToClipboard from "../../lib/copyToClipboard";
import AttachmentEditor from "./AttachmentEditor";
import useModalStore from "../../stores/useModalStore";
import useToastStore from "../../stores/useToastStore";
import { AttachmentResource, Locale } from "../../types";

import { useDraggable, Draggable } from "../drag";

interface Record {
  id: number | null;
  attachment: AttachmentResource;
  uploading: boolean;
}

interface AttachmentProps {
  attributeName: string;
  placeholder: boolean;
  draggable: { record: Record };
  locale: string;
  locales: { [index: string]: Locale };
  deleteRecord: () => void;
  showEmbed: boolean;
  position: number;
  onUpdate: (localizations: Record<string, Record<string, string>>) => void;
  startDrag: (evt: Event, draggable: Draggable) => void;
}

export default function Attachment(props: AttachmentProps) {
  const { attributeName, draggable, locales, locale } = props;
  const { record } = draggable;
  const { attachment, uploading } = record;

  const openModal = useModalStore((state) => state.open);
  const notice = useToastStore((state) => state.notice);

  const listeners = useDraggable(draggable, props.startDrag);

  const copyEmbed = (evt: Event) => {
    evt.preventDefault();
    copyToClipboard(`[attachment:${attachment.id}]`);
    notice("Embed code copied to clipboard");
  };

  const deleteRecord = (evt: Event) => {
    evt.preventDefault();
    if (props.deleteRecord) {
      props.deleteRecord();
    }
  };

  const description = () => {
    if (attachment.description && attachment.description[locale]) {
      return attachment.description[locale];
    }
    return null;
  };

  const name = () => {
    if (attachment.name && attachment.name[locale]) {
      return attachment.name[locale];
    }
    return null;
  };

  const editAttachment = (evt: Event) => {
    evt.preventDefault();
    openModal(
      <AttachmentEditor
        attachment={attachment}
        locale={locale}
        locales={locales}
        onUpdate={props.onUpdate}
      />
    );
  };

  const classes = ["attachment"];
  if (props.placeholder) {
    classes.push("placeholder");
  }
  if (record.uploading) {
    classes.push("uploading");
  }

  const icon = uploading ? "cloud-arrow-up" : "paperclip";

  let localeDir = "ltr";
  if (locale in locales && locales[locale].dir) {
    localeDir = locales[locale].dir;
  }

  return (
    <div className={classes.join(" ")} {...listeners}>
      <input
        name={`${attributeName}[id]`}
        type="hidden"
        value={record.id || ""}
      />
      <input
        name={`${attributeName}[attachment_id]`}
        type="hidden"
        value={(attachment && attachment.id) || ""}
      />
      <input
        name={`${attributeName}[position]`}
        type="hidden"
        value={props.position}
      />
      {!uploading && (
        <div className="actions">
          <button onClick={editAttachment}>Edit</button>
          {props.showEmbed && <button onClick={copyEmbed}>Embed</button>}
          {props.deleteRecord && <button onClick={deleteRecord}>Remove</button>}
        </div>
      )}
      {attachment && (
        <div className="attachment-info">
          <h3>
            <i className={`fa-solid fa-${icon} icon`} />
            {name() || <em>Untitled</em>}
            <br />
          </h3>
          {!uploading && (
            <a href={attachment.url} rel="noreferrer" target="_blank">
              {attachment.filename}
            </a>
          )}
          {!uploading && description() && (
            <p dir={localeDir}>{description()}</p>
          )}
        </div>
      )}
    </div>
  );
}
