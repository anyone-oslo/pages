import { File as FileIcon } from "lucide-react";

import useAssets, { FileAsset, ImageAsset } from "./useAssets";

type ImageProps = {
  kind: "image";
  onPick: (item: ImageAsset) => void;
  onClose: () => void;
};

type FileProps = {
  kind: "file";
  onPick: (item: FileAsset) => void;
  onClose: () => void;
};

type Props = ImageProps | FileProps;

export default function AssetPicker(props: Props) {
  const { images, files } = useAssets();
  const isImage = props.kind === "image";
  const title = isImage ? "Insert image" : "Insert file";
  const empty = isImage ? images.length === 0 : files.length === 0;
  const tab = isImage ? "Images" : "Files";

  return (
    <div
      className="doc-picker-backdrop"
      onMouseDown={props.onClose}
      role="presentation">
      <div
        className="doc-picker"
        role="dialog"
        aria-label={title}
        onMouseDown={(e) => e.stopPropagation()}>
        <header className="doc-picker__header">
          <h2>{title}</h2>
          <button
            type="button"
            className="doc-picker__close"
            onClick={props.onClose}>
            ×
          </button>
        </header>

        {empty ? (
          <p className="doc-picker__empty">
            No {isImage ? "images" : "files"} on this page yet. Upload in the{" "}
            <strong>{tab}</strong> tab and save the page, then insert here.
          </p>
        ) : isImage ? (
          <ul className="doc-picker__grid">
            {images.map((img) => (
              <li key={img.id}>
                <button
                  type="button"
                  className="doc-picker__thumb"
                  onClick={() => (props as ImageProps).onPick(img)}>
                  <img src={img.thumbnail} alt="" />
                  <span className="doc-picker__caption">
                    <span className="doc-picker__id">#{img.id}</span>
                    <span className="doc-picker__name">
                      {img.alternative || img.filename}
                    </span>
                  </span>
                </button>
              </li>
            ))}
          </ul>
        ) : (
          <ul className="doc-picker__list">
            {files.map((file) => (
              <li key={file.id}>
                <button
                  type="button"
                  className="doc-picker__row"
                  onClick={() => (props as FileProps).onPick(file)}>
                  <FileIcon size={18} strokeWidth={1.75} aria-hidden />
                  <span>
                    {file.name}
                    <small>
                      #{file.id} · {file.filename}
                    </small>
                  </span>
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
