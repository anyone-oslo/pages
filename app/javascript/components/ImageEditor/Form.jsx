import React from "react";
import PropTypes from "prop-types";
import ModalStore from "../../stores/ModalStore";
import ToastStore from "../../stores/ToastStore";
import copyToClipboard, { copySupported } from "../../lib/copyToClipboard";

export default function Form(props) {
  const { alternative, caption, image, locale, locales } = props;

  const copyEmbedCode = (evt) => {
    evt.preventDefault();
    copyToClipboard(`[image:${image.id}]`);
    ToastStore.dispatch({
      type: "NOTICE", message: "Embed code copied to clipboard"
    });
  };

  const handleChangeLocale = (evt) => {
    props.setLocale(evt.target.value);
  };

  const inputDir = (locales && locales[locale].dir) || "ltr";

  return (
    <form>
      <div className="field embed-code">
        <label>
          Embed code
        </label>
        <input type="text"
               value={`[image:${image.id}]`}
               disabled={true} />
        {copySupported() && (
          <button onClick={copyEmbedCode}>
            Copy
          </button>
        )}
      </div>
      {locales && Object.keys(locales).length > 1 && (
        <div className="field">
          <label>
            Locale
          </label>
          <select name="locale"
                  value={locale}
                  onChange={handleChangeLocale}>
            {Object.keys(locales).map(key => (
              <option key={`locale-${key}`} value={key}>
                {locales[key].name}
              </option>
            ))}
          </select>
        </div>
      )}
      <div className={"field " + (alternative[locale] ? "" : "field-with-warning")}>
        <label>
          Alternative text
        </label>
        <span className="description">
          For visually impaired users and search engines.
        </span>
        <textarea
          className="alternative"
          lang={locale}
          dir={inputDir}
          value={alternative[locale] || ""}
          onChange={e => props.updateLocalization("alternative", e.target.value)} />
      </div>
      {props.showCaption && (
        <div className="field">
          <label>
            Caption
          </label>
          <textarea
            lang={locale}
            dir={inputDir}
            onChange={e => props.updateLocalization("caption", e.target.value)}
            value={caption[locale] || ""}
            className="caption" />
        </div>
      )}
      <div className="buttons">
        <button onClick={props.save}>
          Save
        </button>
        <button onClick={() => ModalStore.dispatch({ type: "CLOSE" })}>
          Cancel
        </button>
      </div>
    </form>
  );
}

Form.propTypes = {
  alternative: PropTypes.object,
  caption: PropTypes.object,
  image: PropTypes.object,
  locale: PropTypes.string,
  locales: PropTypes.object,
  setLocale: PropTypes.func,
  save: PropTypes.func,
  showCaption: PropTypes.bool,
  updateLocalization: PropTypes.func
};
