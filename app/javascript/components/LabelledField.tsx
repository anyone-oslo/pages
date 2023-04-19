import React from "react";

interface LabelledFieldProps {
  htmlFor: string,
  description: string,
  label: string,
  errors: string[],
  children: JSX.Element
}

export default function LabelledField(props: LabelledFieldProps) {
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
