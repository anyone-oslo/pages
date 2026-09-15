import { ChangeEvent } from "react";

import * as Template from "../../types/Template";

import DocumentEditor from "../DocumentEditor";
import LabelledField from "../LabelledField";
import RichTextArea from "../RichTextArea";

type Props = {
  block: Template.Block;
  errors: string[];
  onChange: (value: string) => void;
  lang: string;
  dir: string;
  value: string;
  rich?: boolean;
  allowFiles?: boolean;
};

export default function Block(props: Props) {
  const { block, errors, onChange, lang, dir, value, rich, allowFiles } = props;

  const handleChange = (
    evt: ChangeEvent<HTMLInputElement> | ChangeEvent<HTMLSelectElement>
  ) => {
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

  let field: React.ReactNode;
  if (block.type == "select") {
    const options = block.options;

    // Ensure the current value is part of the options
    if (options.map((o) => o[1]).indexOf(value) === -1) {
      options.push([value, value]);
    }

    field = (
      <select onChange={handleChange} {...commonOptions}>
        {options.map((opt) => (
          <option key={opt[1]} value={opt[1]}>
            {opt[0]}
          </option>
        ))}
      </select>
    );
  } else if (block.size == "field") {
    field = <input type="text" onChange={handleChange} {...textFieldOptions} />;
  } else if (rich) {
    field = (
      <DocumentEditor
        id={id}
        value={value}
        onChange={onChange}
        lang={lang}
        dir={dir}
        placeholder={block.placeholder}
        allowFiles={allowFiles}
        minRows={block.size == "large" ? 15 : 5}
        format={block.format == "inline" ? "inline" : "document"}
      />
    );
  } else {
    field = (
      <RichTextArea
        onChange={onChange}
        rows={block.size == "large" ? 15 : 5}
        {...textFieldOptions}
      />
    );
  }

  return (
    <LabelledField
      htmlFor={id}
      label={block.title}
      description={block.description}
      errors={errors}>
      {field}
    </LabelledField>
  );
}
