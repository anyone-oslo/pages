import { Fragment } from "react";
import * as Tags from "../../types/Tags";
import { MaybeLocalizedValue } from "../../types";

import { blockValue, errorsOn } from "./utils";
import usePageFormContext from "./usePageFormContext";
import LabelledField from "../LabelledField";
import { default as TagEditor } from "../TagEditor/Editor";
import Block from "./Block";
import Dates from "./Dates";

type Props = {
  tagsState: Tags.State;
  tagsDispatch: React.Dispatch<Tags.Action>;
};

export default function Content({ tagsState, tagsDispatch }: Props) {
  const { state, dispatch } = usePageFormContext();
  const { page, locale, inputDir, templateConfig } = state;

  const handleChange = (attr: string) => (value: MaybeLocalizedValue) => {
    dispatch({ type: "updateBlocks", payload: { [attr]: value } });
  };

  return (
    <Fragment>
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
      {templateConfig.dates && <Dates />}
      {templateConfig.tags && (
        <LabelledField label="Tags">
          <TagEditor
            name="page[serialized_tags]"
            state={tagsState}
            dispatch={tagsDispatch}
          />
        </LabelledField>
      )}
    </Fragment>
  );
}
