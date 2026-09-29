import { useEffect, useRef, useState } from "react";

import useClickOutside from "./useClickOutside";

type Props = {
  title: string;
  initialUrl: string;
  placeholder?: string;
  error?: string | null;
  onApply: (url: string) => void;
  onRemove?: () => void;
  onClose: () => void;
};

/** Small inline dialog for link and video URLs. */
export default function UrlPopover({
  title,
  initialUrl,
  placeholder,
  error,
  onApply,
  onRemove,
  onClose
}: Props) {
  const [url, setUrl] = useState(initialUrl || "");
  const inputRef = useRef<HTMLInputElement>(null);
  const rootRef = useRef<HTMLDivElement>(null);
  useClickOutside(rootRef, true, onClose);

  useEffect(() => {
    inputRef.current?.focus();
    inputRef.current?.select();
  }, []);

  return (
    <div
      ref={rootRef}
      className="doc-popover"
      role="dialog"
      aria-label={title}
      onMouseDown={(e) => e.stopPropagation()}>
      <label>
        {title}
        <input
          ref={inputRef}
          type="text"
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter") {
              e.preventDefault();
              onApply(url.trim());
            }
            if (e.key === "Escape") {
              e.preventDefault();
              onClose();
            }
          }}
          placeholder={placeholder || "https://… or /path"}
        />
      </label>
      {error ? <p className="doc-popover__error">{error}</p> : null}
      <div className="doc-popover__actions">
        <button
          type="button"
          className="primary"
          onClick={() => onApply(url.trim())}>
          Apply
        </button>
        {onRemove && initialUrl ? (
          <button type="button" onClick={onRemove}>
            Remove
          </button>
        ) : null}
        <button type="button" onClick={onClose}>
          Cancel
        </button>
      </div>
    </div>
  );
}
