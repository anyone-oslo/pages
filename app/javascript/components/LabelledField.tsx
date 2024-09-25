import { Fragment } from "react";

interface LabelledFieldProps {
  label: string;
  children: React.ReactNode;
  htmlFor?: string;
  description?: string;
  errors?: string[];
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
        {errors && (
          <Fragment>
            {" "}
            <span className="error">{errors[errors.length - 1]}</span>
          </Fragment>
        )}
      </label>
      {description && <p className="description">{description}</p>}
      {children}
    </div>
  );
}
