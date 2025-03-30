import { ChangeEvent, MouseEvent, KeyboardEvent, useState } from "react";

import * as Tags from "../../types/Tags";

type Props = {
  dispatch: (action: Tags.Action) => void;
};

export default function AddTagForm(props: Props) {
  const [tag, setTag] = useState("");

  const submit = () => {
    props.dispatch({ type: "addTag", payload: tag });
    setTag("");
  };

  const handleSubmit = (evt: MouseEvent) => {
    evt.preventDefault();
    submit();
  };

  const handleKeyDown = (evt: KeyboardEvent<HTMLInputElement>) => {
    if (evt.which === 13) {
      evt.preventDefault();
      submit();
    }
  };

  const handleChange = (evt: ChangeEvent<HTMLInputElement>) => {
    setTag(evt.target.value);
  };

  return (
    <div className="add-tag-form inline-form">
      <input
        name="add-tag"
        type="text"
        className="add-tag tight"
        value={tag}
        onKeyDown={handleKeyDown}
        onChange={handleChange}
        placeholder="Add tag..."
      />
      <button onClick={handleSubmit} disabled={!tag}>
        Add
      </button>
    </div>
  );
}
