import React from "react";

import { blockValue, errorsOn, PageFormAction, PageFormState } from "./usePage";
import LabelledField from "../LabelledField";
import TagEditor from "../TagEditor";
import Block from "./Block";
import Dates from "./Dates";

interface ContentProps {
  state: PageFormState;
  dispatch: (action: PageFormAction) => void;
}

export default function Content(props: ContentProps) {
  const { state, dispatch } = props;

  const { page, locale, inputDir, templateConfig } = state;

  const handleChange = (attr: string) => (value: PageBlockValue) => {
    dispatch({ type: "updateBlocks", payload: { [attr]: value } });
  };

  return (
    <React.Fragment>
      {templateConfig.blocks.map((b) => (
        <Block
          key={b.name}
          block={b}
          errors={errorsOn(page, b.name)}
          dir={inputDir}
          lang={locale}
          onChange={handleChange(b.name)}
          value={blockValue(state, b)}
        />
      ))}
      {templateConfig.dates && (
        <Dates
          starts_at={page.starts_at}
          ends_at={page.ends_at}
          all_day={page.all_day}
        />
      )}
      {templateConfig.tags && (
        <LabelledField label="Tags">
          <TagEditor
            name="page[serialized_tags]"
            enabled={page.enabled_tags}
            tags={page.tags_and_suggestions}
          />
        </LabelledField>
      )}
    </React.Fragment>
  );
}
