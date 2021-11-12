import React from "react";
import PropTypes from "prop-types";
import copyToClipboard, { copySupported } from "../../lib/copyToClipboard";
import ModalStore from "../ModalStore";
import ToastStore from "../ToastStore";
import { putJson } from "../../lib/request";

export default class AttachmentEditor extends React.Component {
  constructor(props) {
    let attachment = props.attachment;

    super(props);

    this.state = {
      locale:      this.props.locale,
      name:        attachment.name || {},
      description: attachment.description || {}
    };

    this.copyEmbedCode = this.copyEmbedCode.bind(this);
    this.save = this.save.bind(this);
  }

  copyEmbedCode(evt) {
    evt.preventDefault();
    copyToClipboard(`[attachment:${this.props.attachment.id}]`);
    ToastStore.dispatch({
      type: "NOTICE", message: "Embed code copied to clipboard"
    });
  }

  render() {
    let { locale, name, description } = this.state;
    let locales = this.props.locales;
    let attachment = this.props.attachment;
    return (
      <div className="attachment-editor">
        <form>
          {locales && Object.keys(locales).length > 1 && (
            <div className="field">
              <label>
                Locale
              </label>
              <select name="locale"
                      onChange={e => this.setState({locale: e.target.value})}>
                {Object.keys(locales).map(key => (
                  <option key={`locale-${key}`} value={key}>
                    {locales[key]}
                  </option>
                ))}
              </select>
            </div>
          )}
          <div className="field">
            <label>Name</label>
            <input type="text"
                   className="name"
                   value={name[locale] || ""}
                   onChange={e => this.updateLocalized("name",
                                                       e.target.value)} />
          </div>
          <div className="field">
            <label>Description</label>
            <textarea className="description"
                      value={description[locale] || ""}
                      onChange={e => this.updateLocalized("description",
                                                          e.target.value)} />
          </div>
          <div className="field embed-code">
            <label>
              Embed code
            </label>
            <input type="text"
                   value={`[attachment:${attachment.id}]`}
                   disabled={true} />
            {copySupported() && (
              <button onClick={this.copyEmbedCode}>
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
            <button onClick={this.save}>
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

  save(evt) {
    evt.preventDefault();
    evt.stopPropagation();

    let data = { name: this.state.name,
                 description: this.state.description };

    putJson(`/admin/attachments/${this.props.attachment.id}`,
            { attachment: data });

    if (this.props.onUpdate) {
      this.props.onUpdate(data);
    }
    ModalStore.dispatch({ type: "CLOSE" });
  }

  updateLocalized(name, value) {
    let locale = this.state.locale;
    this.setState({
      [name]: { ...this.state[name], [locale]: value }
    });
  }
}

AttachmentEditor.propTypes = {
  attachment: PropTypes.object,
  locale: PropTypes.string,
  locales: PropTypes.object,
  onUpdate: PropTypes.func
};
