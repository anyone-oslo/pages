type Props = {
  label: string;
  onReplace?: () => void;
  onRemove: () => void;
};

/** Shared object chrome: label left, Replace… / Remove as text links. */
export default function EmbedHead({ label, onReplace, onRemove }: Props) {
  return (
    <div className="doc-embed__head" contentEditable={false}>
      <span className="doc-embed__label">{label}</span>
      <div className="doc-embed__actions">
        {onReplace ? (
          <button
            type="button"
            className="doc-embed__action"
            onMouseDown={(e) => {
              e.preventDefault();
              e.stopPropagation();
            }}
            onClick={onReplace}>
            Replace…
          </button>
        ) : null}
        <button
          type="button"
          className="doc-embed__action doc-embed__action--danger"
          onMouseDown={(e) => {
            e.preventDefault();
            e.stopPropagation();
          }}
          onClick={onRemove}>
          Remove
        </button>
      </div>
    </div>
  );
}
