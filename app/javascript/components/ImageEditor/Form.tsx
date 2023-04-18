import React, { ChangeEvent } from "react";
import ModalStore from "../../stores/ModalStore";
import ToastStore from "../../stores/ToastStore";
import { Locale, ImageResource } from "../../types";
import copyToClipboard, { copySupported } from "../../lib/copyToClipboard";

interface FormProps {
  alternative: Record<string, string>,
  caption: Record<string, string>,
  image: ImageResource,
  locale: string,
  locales: Record<string, Locale>,
  setLocale: (locale: string) => void,
  save: (evt: Event) => void,
  showCaption: boolean,
  updateLocalization: (name: "alternative" | "caption", value: string) => void
}

export default function Form(props: FormProps) {
  const { alternative, caption, image, locale, locales } = props;

  const copyEmbedCode = (evt: Event) => {
    evt.preventDefault();
    copyToClipboard(`[image:${image.id}]`);
    ToastStore.dispatch({
      type: "NOTICE", message: "Embed code copied to clipboard"
    });
  };

  const handleChangeLocale = (evt: ChangeEvent<HTMLSelectElement>) => {
    props.setLocale(evt.target.value);
  };

  const inputDir = (locales && locales[locale] && locales[locale].dir) || "ltr";

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
