import React from "react";
import PropTypes from "prop-types";

export default function TabPanel(props) {
  const { active, children } = props;

  let classNames = ["content-tab"];
  if (!active) {
    classNames.push("hidden");
  }

  return (
    <div className={classNames.join(" ")}
         role="tabpanel">
      {children}
    </div>
  );
}

TabPanel.propTypes = {
  active: PropTypes.bool,
  children: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.object,
    PropTypes.array
  ]),
};
