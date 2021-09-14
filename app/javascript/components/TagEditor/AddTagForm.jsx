import React, { useState } from "react";
import PropTypes from "prop-types";

export default function AddTagForm(props) {
  const [tag, setTag] = useState("");

  const submit = (evt) => {
    evt.preventDefault();
    props.addTag(tag);
    setTag("");
  };

  const handleKeyDown = (evt) => {
    if (evt.which === 13) {
      submit(evt);
    }
  };

  const handleChange = (evt) => {
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

AddTagForm.propTypes = {
  addTag: PropTypes.func
};
