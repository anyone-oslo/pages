import React from "react";

import * as PageEditor from "../../types/PageEditor";
import * as Tags from "../../types/Tags";
import { MaybeLocalizedValue } from "../../types";

import { blockValue, errorsOn } from "./usePage";
import LabelledField from "../LabelledField";
import { default as TagEditor } from "../TagEditor/Editor";
import Block from "./Block";
import Dates from "./Dates";

interface Props {
  state: PageEditor.State;
  dispatch: (action: PageEditor.Action) => void;
  tagsState: Tags.State;
  tagsDispatch: (action: Tags.Action) => void;
}

export default function Content(props: Props) {
  const { state, dispatch, tagsState, tagsDispatch } = props;

  const { page, locale, inputDir, templateConfig } = state;

  const handleChange = (attr: string) => (value: MaybeLocalizedValue) => {
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
      {templateConfig.dates && <Dates state={state} dispatch={dispatch} />}
      {templateConfig.tags && (
        <LabelledField label="Tags">
          <TagEditor
            name="page[serialized_tags]"
            state={tagsState}
            dispatch={tagsDispatch}
          />
        </LabelledField>
      )}
    </React.Fragment>
  );
}
