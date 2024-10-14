import { Fragment } from "react";

import { MaybeLocalizedValue } from "../../types";
import { blockValue, errorsOn, unconfiguredBlocks } from "./utils";
import usePageFormContext from "./usePageFormContext";

import Block from "./Block";

export default function UnconfiguredContent() {
  const { state, dispatch } = usePageFormContext();

  const { page, locale, inputDir } = state;

  const handleChange = (attr: string) => (value: MaybeLocalizedValue) => {
    dispatch({ type: "updateBlocks", payload: { [attr]: value } });
  };

  return (
    <Fragment>
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
    </Fragment>
  );
}
