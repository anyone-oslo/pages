import React, { ChangeEvent, MouseEvent } from "react";
import useModalStore from "../../stores/useModalStore";
import useToastStore from "../../stores/useToastStore";
import copyToClipboard, { copySupported } from "../../lib/copyToClipboard";

interface Props {
  alternative: Record<string, string>;
  caption: Record<string, string>;
  image: ImageResource;
  locale: string;
  locales: Record<string, Locale>;
  setLocale: (locale: string) => void;
  save: (evt: MouseEvent) => void;
  showCaption: boolean;
  updateLocalization: (name: "alternative" | "caption", value: string) => void;
}

export default function Form(props: Props) {
  const { alternative, caption, image, locale, locales } = props;

  const closeModal = useModalStore((state) => state.close);
  const notice = useToastStore((state) => state.notice);

  const copyEmbedCode = (evt: MouseEvent) => {
    evt.preventDefault();
    copyToClipboard(`[image:${image.id}]`);
    notice("Embed code copied to clipboard");
  };

  const handleChangeLocale = (evt: ChangeEvent<HTMLSelectElement>) => {
    props.setLocale(evt.target.value);
  };

  const inputDir = (locales && locales[locale] && locales[locale].dir) || "ltr";

  return (
    <form>
      <div className="field embed-code">
        <label>Embed code</label>
        <input type="text" value={`[image:${image.id}]`} disabled={true} />
        {copySupported() && <button onClick={copyEmbedCode}>Copy</button>}
      </div>
      {locales && Object.keys(locales).length > 1 && (
        <div className="field">
          <label>Locale</label>
          <select name="locale" value={locale} onChange={handleChangeLocale}>
            {Object.keys(locales).map((key) => (
              <option key={`locale-${key}`} value={key}>
                {locales[key].name}
              </option>
            ))}
          </select>
        </div>
      )}
      <div
        className={
          "field " + (alternative[locale] ? "" : "field-with-warning")
        }>
        <label>Alternative text</label>
        <span className="description">
          For visually impaired users and search engines.
        </span>
        <textarea
          className="alternative"
          lang={locale}
          dir={inputDir}
          value={alternative[locale] || ""}
          onChange={(e) =>
            props.updateLocalization("alternative", e.target.value)
          }
        />
      </div>
      {props.showCaption && (
        <div className="field">
          <label>Caption</label>
          <textarea
            lang={locale}
            dir={inputDir}
            onChange={(e) =>
              props.updateLocalization("caption", e.target.value)
            }
            value={caption[locale] || ""}
            className="caption"
          />
        </div>
      )}
      <div className="buttons">
        <button className="primary" onClick={props.save}>
          Save
        </button>
        <button onClick={closeModal}>Cancel</button>
      </div>
    </form>
  );
}
