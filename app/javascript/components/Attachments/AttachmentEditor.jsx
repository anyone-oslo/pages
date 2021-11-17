import React, { useState } from "react";
import PropTypes from "prop-types";
import copyToClipboard, { copySupported } from "../../lib/copyToClipboard";
import ModalStore from "../ModalStore";
import ToastStore from "../ToastStore";
import { putJson } from "../../lib/request";

export default function AttachmentEditor(props) {
  const { attachment } = props;

  const [locale, setLocale] = useState(props.locale);
  const [localizations, setLocalizations] = useState({
    name: attachment.name || {},
    description: attachment.description || {},
  });

  const updateLocalization = (name) => (evt) => {
    setLocalizations({
      ...localizations,
      [name]: { ...localizations[name],
                [locale]: evt.target.value }
    });
  };

  const copyEmbedCode = (evt) => {
    evt.preventDefault();
    copyToClipboard(`[attachment:${attachment.id}]`);
    ToastStore.dispatch({
      type: "NOTICE", message: "Embed code copied to clipboard"
    });
  };

  const save = (evt) => {
    evt.preventDefault();
    evt.stopPropagation();

    let data = { ...localizations };

    putJson(`/admin/attachments/${attachment.id}`,
            { attachment: data });

    if (props.onUpdate) {
      props.onUpdate(data);
    }
    ModalStore.dispatch({ type: "CLOSE" });
  };

  return (
    <div className="attachment-editor">
      <form>
        {props.locales && Object.keys(props.locales).length > 1 && (
          <div className="field">
            <label>
              Locale
            </label>
            <select name="locale"
                    onChange={e => setLocale(e.target.value)}>
              {Object.keys(props.locales).map(key => (
                <option key={`locale-${key}`} value={key}>
                  {props.locales[key]}
                </option>
              ))}
            </select>
          </div>
        )}
        <div className="field">
          <label>Name</label>
          <input type="text"
                 className="name"
                 value={localizations.name[locale] || ""}
                 onChange={updateLocalization("name")} />
        </div>
        <div className="field">
          <label>Description</label>
          <textarea className="description"
                    value={localizations.description[locale] || ""}
                    onChange={updateLocalization("description")} />
        </div>
        <div className="field embed-code">
          <label>
            Embed code
          </label>
          <input type="text"
                 value={`[attachment:${attachment.id}]`}
                 disabled={true} />
          {copySupported() && (
            <button onClick={copyEmbedCode}>
              Copy
            </button>
          )}
        </div>
        <div className="field">
          <label>File</label>
          <a href={attachment.url}
             rel="noreferrer"
             target="_blank">{attachment.filename}</a>
        </div>
        <div className="buttons">
          <button onClick={save}>
            Save
          </button>
          <button onClick={() => ModalStore.dispatch({ type: "CLOSE" })}>
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}

AttachmentEditor.propTypes = {
  attachment: PropTypes.object,
  locale: PropTypes.string,
  locales: PropTypes.object,
  onUpdate: PropTypes.func
};