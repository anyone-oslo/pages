import React, { useState } from "react";
import PropTypes from "prop-types";

import AddTagForm from "./TagEditor/AddTagForm";
import Tag from "./TagEditor/Tag";

function onlyUnique(value, index, self) {
  return self.indexOf(value) === index;
}

export default function TagEditor(props) {
  const [tags, setTags] = useState(props.tags);
  const [enabled, setEnabled] = useState(props.enabled);

  const tagList = [...tags, ...enabled].filter(onlyUnique);

  const normalize = (tag) => {
    return (
      tagList.filter(t => t.toLowerCase() == tag.toLowerCase())[0] || tag
    );
  };

  const tagEnabled = (tag) => {
    return enabled.map(t => t.toLowerCase()).indexOf(tag.toLowerCase()) !== -1;
  };

  const toggleEnabled = (tag) => {
    const normalized = normalize(tag);

    if (tagEnabled(normalized)) {
      setEnabled(enabled.filter((t) => t !== normalized));
    } else {
      setEnabled([...enabled, normalized]);
    }
  };

  const addTag = (tag) => {
    const normalized = normalize(tag);

    setTags([...tags, normalized].filter(onlyUnique));
    setEnabled([...enabled, normalized].filter(onlyUnique));
  };

  return (
    <div className="tag-editor clearfix">
      <input type="hidden" name={props.name} value={JSON.stringify(enabled)} />
      {tagList.map((t) =>
        <Tag key={t}
             tag={t}
             enabled={tagEnabled(t)}
             toggleEnabled={toggleEnabled} />)}
      <AddTagForm addTag={addTag} />
    </div>
  );
}

TagEditor.propTypes = {
  name: PropTypes.string,
  enabled: PropTypes.array,
  tags: PropTypes.array
};
