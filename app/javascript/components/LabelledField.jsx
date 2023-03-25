import React from "react";
import PropTypes from "prop-types";

export default function LabelledField(props) {
  const { htmlFor, description, label, errors, children } = props;

  const classNames = ["field"];
  if (errors && errors.length > 0) {
    classNames.push("field-with-errors");
  }

  return (
    <div className={classNames.join(" ")}>
      <label htmlFor={htmlFor}>
        {label}
        {errors &&
         <React.Fragment>
           {" "}
           <span className="error">
             {errors[errors.length - 1]}
           </span>
         </React.Fragment>}
      </label>
      {description &&
       <p className="description">
         {description}
       </p>}
      {children}
    </div>
  );
}

LabelledField.propTypes = {
  htmlFor: PropTypes.string,
  description: PropTypes.string,
  label: PropTypes.string,
  errors: PropTypes.array,
  children: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.object,
    PropTypes.array
  ]),
};
