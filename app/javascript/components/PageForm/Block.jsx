import React from "react";
import PropTypes from "prop-types";

import RichTextArea from "../RichTextArea";

export default function Block(props) {
  const { block, errors, onChange, lang, dir, value } = props;

  const handleChange = (evt) => {
    onChange(evt.target.value);
  };

  const id = `page_${block.name}`;

  const commonOptions = {
    id: id,
    name: `page[${block.name}]`,
    value: value
  };

  const textFieldOptions = {
    ...commonOptions,
    className: ["rich", block.class].join(" ").trim(),
    lang: lang,
    dir: dir,
    placeholder: block.placeholder
  };

  let field;
  if (block.type == "select") {
    let options = block.options;

    // Ensure the current value is part of the options
    if (options.map(o => o[1]).indexOf(value) === -1) {
      options.push([value, value]);
    }

    field = <select onChange={handleChange}
                    {...commonOptions}>
              {options.map(opt =>
                <option key={opt[1]} value={opt[1]}>
                  {opt[0]}
                </option>)}
            </select>;
  } else if (block.size == "field") {
    field = <input type="text"
                   onChange={handleChange}
                   {...textFieldOptions} />;
  } else {
    field = <RichTextArea onChange={onChange}
                          rows={block.size == "large" ? 15 : 5}
                          {...textFieldOptions} />;
  }

  let fieldClass = ["field"];
  if (errors.length > 0) {
    fieldClass.push("field-with-errors");
  }

  return (
    <div className={fieldClass.join(" ")}>
      <label htmlFor={id}>
        {block.title}
        {errors &&
         <React.Fragment>
           {" "}
           <span className="error">
             {errors[errors.length - 1]}
           </span>
         </React.Fragment>}
      </label>
      {block.description &&
       <p className="description">
         {block.description}
       </p>}
      {field}
    </div>
  );
}

Block.propTypes = {
  block: PropTypes.object,
  errors: PropTypes.array,
  onChange: PropTypes.func,
  lang: PropTypes.string,
  dir: PropTypes.string,
  value: PropTypes.string
};
