import React from "react";
import PropTypes from "prop-types";

export default function Tag(props) {
  const handleChange = () => {
    props.toggleEnabled(props.tag);
  };

  let classes = ["tag"];
  if (props.enabled) {
    classes.push("enabled");
  }

  return (
    <span className={classes.join(" ")}>
      <label className="check-box">
        <input type="checkbox"
               name={"tag-" + props.tag}
               value="1"
               checked={props.enabled}
               onChange={handleChange} />
        <span className="name">{props.tag}</span>
      </label>
    </span>
  );
}

Tag.propTypes = {
  enabled: PropTypes.bool,
  tag: PropTypes.string,
  toggleEnabled: PropTypes.func
};
