import React from "react";

import { blockValue, errorsOn, unconfiguredBlocks } from "./usePage";
import Block from "./Block";

interface Props {
  state: PageForm.State;
  dispatch: (action: PageForm.Action) => void;
}

export default function UnconfiguredContent(props: Props) {
  const { state, dispatch } = props;

  const { page, locale, inputDir } = state;

  const handleChange = (attr: string) => (value: MaybeLocalizedValue) => {
    dispatch({ type: "updateBlocks", payload: { [attr]: value } });
  };

  return (
    <React.Fragment>
      <p>
        This page has additional content fields not enabled by the selected
        template.
      </p>
      {unconfiguredBlocks(state).map((b) => (
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
    </React.Fragment>
  );
}
