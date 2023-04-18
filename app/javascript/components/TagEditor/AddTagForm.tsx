import React, { ChangeEvent, useState } from "react";

interface AddTagFormProps {
  addTag: (string) => void
}

export default function AddTagForm(props: AddTagFormProps) {
  const [tag, setTag] = useState("");

  const submit = (evt: Event) => {
    evt.preventDefault();
    props.addTag(tag);
    setTag("");
  };

  const handleKeyDown = (evt: Event) => {
    if (evt.which === 13) {
      submit(evt);
    }
  };

  const handleChange = (evt: ChangeEvent<HTMLInputElement>) => {
    setTag(evt.target.value);
  };

  return (
    <div className="add-tag-form">
      <input name="add-tag"
             type="text"
             className="add-tag"
             value={tag}
             onKeyDown={handleKeyDown}
             onChange={handleChange}
             placeholder="Add tag..." />
      <button onClick={submit}
              disabled={!tag}>
        Add
      </button>
    </div>
  );
}
