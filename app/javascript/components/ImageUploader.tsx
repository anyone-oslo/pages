import { DragEvent, MouseEvent, useState } from "react";

import useToastStore from "../stores/useToastStore";
import { post } from "../lib/request";
import * as Images from "../types/Images";
import { Locale } from "../types";

import EditableImage from "./EditableImage";
import FileUploadButton from "./FileUploadButton";

interface Props {
  locale: string;
  locales: { [index: string]: Locale };
  image: Images.Resource;
  src: string;
  width: number;
  caption: boolean;
  attr: string;
  alternative?: string;
  onChange?: (state: State) => void;
}

interface State {
  image?: Images.Resource;
  src?: string;
}

function getFiles(dt: DataTransfer): File[] {
  const files: File[] = [];
  if (dt.items) {
    for (let i = 0; i < dt.items.length; i++) {
      if (dt.items[i].kind == "file") {
        files.push(dt.items[i].getAsFile());
      }
    }
  } else {
    for (let i = 0; i < dt.files.length; i++) {
      files.push(dt.files[i]);
    }
  }
  return files;
}

export default function ImageUploader(props: Props) {
  const [uploading, setUploading] = useState(false);
  const [dragover, setDragover] = useState(false);
  const [state, setState] = useState<State>({
    image: props.image,
    src: props.src
  });
  const { image, src } = props.onChange ? props : state;

  const error = useToastStore((state) => state.error);

  const update = (image: Images.Resource | null, src?: string) => {
    const handler = props.onChange || setState;
    handler({ image: image, src: src || null });
  };

  const handleDragOver = (evt: DragEvent) => {
    evt.preventDefault();
    setDragover(true);
  };

  const handleDragLeave = () => {
    setDragover(false);
  };

  const handleDragEnd = (evt: DragEvent) => {
    if ("dataTransfer" in evt) {
      if ("items" in evt.dataTransfer && "remove" in evt.dataTransfer.items) {
        for (let i = 0; i < evt.dataTransfer.items.length; i++) {
          evt.dataTransfer.items.remove(i);
        }
      } else if ("clearData" in evt.dataTransfer) {
        evt.dataTransfer.clearData();
      }
    }
    setDragover(false);
  };

  const handleDrop = (evt: DragEvent) => {
    let files: File[] = [];
    if ("dataTransfer" in evt) {
      files = getFiles(evt.dataTransfer);
    }
    evt.preventDefault();
    if (files.length > 0) {
      uploadImage(files[0]);
    }
  };

  const handleRemove = (evt: MouseEvent) => {
    evt.preventDefault();
    update(null);
  };

  const receiveFiles = (files: File[]) => {
    if (files.length > 0) {
      uploadImage(files[0]);
    }
  };

  const uploadImage = (file: File) => {
    const validTypes = [
      "image/gif",
      "image/jpeg",
      "image/pjpeg",
      "image/png",
      "image/tiff"
    ];

    if (validTypes.indexOf(file.type) == -1) {
      alert(
        "Invalid file type, only images in JPEG, PNG or GIF " +
          "formats are supported"
      );
      return;
    }

    const locale = props.locale;
    const locales = props.locales ? Object.keys(props.locales) : [locale];

    const data = new FormData();

    update(null);
    setDragover(false);
    setUploading(true);

    data.append("image[file]", file);
    locales.forEach((l) => {
      data.append(`image[alternative][${l}]`, props.alternative || "");
    });

    void post("/admin/images.json", data).then((response: Images.Response) => {
      setUploading(false);
      if ("status" in response && response.status === "error") {
        error(`Error uploading image: ${response.error}`);
      } else if ("thumbnail_url" in response) {
        update(response, response.thumbnail_url);
      }
    });
  };

  const classes = ["image-uploader"];
  if (uploading) {
    classes.push("uploading");
  } else if (dragover) {
    classes.push("dragover");
  }
  return (
    <div
      className={classes.join(" ")}
      onDragOver={handleDragOver}
      onDragLeave={handleDragLeave}
      onDragEnd={handleDragEnd}
      onDrop={handleDrop}>
      <input type="hidden" name={props.attr} value={image ? image.id : ""} />
      {image && (
        <div className="image">
          <EditableImage
            image={image}
            src={src}
            width={props.width}
            caption={props.caption}
            locale={props.locale}
            locales={props.locales}
          />
        </div>
      )}
      <div className="ui-wrapper">
        {uploading && <div className="ui">Uploading image...</div>}
        {!uploading && (
          <div className="ui">
            <FileUploadButton
              type="image"
              multiline={true}
              callback={receiveFiles}
            />
            {image && (
              <a
                className="delete remove-image"
                href="#"
                onClick={handleRemove}>
                Remove image
              </a>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
