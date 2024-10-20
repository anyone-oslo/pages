import useModalStore from "../../stores/useModalStore";
import useToastStore from "../../stores/useToastStore";
import copyToClipboard, { copySupported } from "../../lib/copyToClipboard";
import useImageEditorContext from "./useImageEditorContext";

type Props = {
  onSave: (evt: React.MouseEvent) => void;
};

export default function Form({ onSave }: Props) {
  const { state, dispatch, options } = useImageEditorContext();
  const { alternative, caption, locale } = state;
  const { image, locales } = options;

  const closeModal = useModalStore((state) => state.close);
  const notice = useToastStore((state) => state.notice);

  const copyEmbedCode = (evt: React.MouseEvent) => {
    evt.preventDefault();
    copyToClipboard(`[image:${image.id}]`);
    notice("Embed code copied to clipboard");
  };

  const handleChangeLocale = (evt: React.ChangeEvent<HTMLSelectElement>) => {
    dispatch({ type: "setLocale", payload: evt.target.value });
  };

  const handleChangeAlternative = (
    evt: React.ChangeEvent<HTMLTextAreaElement>
  ) => {
    dispatch({ type: "setAlternative", payload: evt.target.value });
  };

  const handleChangeCaption = (evt: React.ChangeEvent<HTMLTextAreaElement>) => {
    dispatch({ type: "setCaption", payload: evt.target.value });
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
          onChange={handleChangeAlternative}
        />
      </div>
      {options.caption && (
        <div className="field">
          <label>Caption</label>
          <textarea
            lang={locale}
            dir={inputDir}
            onChange={handleChangeCaption}
            value={caption[locale] || ""}
            className="caption"
          />
        </div>
      )}
      <div className="buttons">
        <button className="primary" onClick={onSave}>
          Save
        </button>
        <button onClick={closeModal}>Cancel</button>
      </div>
    </form>
  );
}
