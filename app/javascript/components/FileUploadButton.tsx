import React, { ChangeEvent, useRef } from "react";

interface FileUploadButtonProps {
  callback: (files: File[]) => void,
  type: string,
  multiple: boolean,
  multiline: boolean
}

export default function FileUploadButton(props: FileUploadButtonProps) {
  const inputRef = useRef<HTMLInputElement>();

  const handleChange = (evt: ChangeEvent<HTMLInputElement>) => {
    const fileList = evt.target.files;
    const files: File[] = [];
    for (let i = 0; i < fileList.length; i++) {
      files.push(fileList[i]);
    }
    if (files.length > 0) {
      props.callback(files);
    }
  };

  const triggerDialog = (evt: Event) => {
    evt.preventDefault();
    inputRef.current.click();
  };

  return (
    <div className="upload-button">
      <span>
        Drag and drop {props.type || "file"}
        {props.multiple && "s"} here, or
        {props.multiline && <br />}
        <button onClick={triggerDialog}>
          choose a file
        </button>
      </span>
      <input type="file"
             onChange={handleChange}
             ref={inputRef}
             style={{ display: "none" }}
             multiple={props.multiple || false} />
    </div>
  );
}
