import React from "react";

import { blockValue, errorsOn, PageBlockValue, PageFormAction, PageFormState } from "./usePage";
import Block from "./Block";
import PathSegment from "./PathSegment";
import LabelledField from "../LabelledField";
import ImageUploader from "../ImageUploader";

interface MetadataProps {
  state: PageFormState,
  dispatch: (action: PageFormAction) => void
}

export default function Metadata(props: MetadataProps) {
  const { state, dispatch } = props;

  const { page, locale, locales, inputDir, templateConfig } = state;

  const handleChange = (attr: string) => (value: PageBlockValue) => {
    dispatch({ type: "update", payload: { [attr]: value } });
  };

  return (
    <React.Fragment>
      <PathSegment state={state}
                   dispatch={dispatch} />
      <LabelledField
        htmlFor="page_meta_image_id"
        label="Image"
        description={"Image displayed when sharing on social media. " +
                     "Will fall back to the primary image if absent. " +
                     "Recommended size is at least 1200x630."}
        errors={errorsOn(page, "meta_image_id")}>
        <ImageUploader attr="page[meta_image_id]"
                       locale={locale}
                       locales={locales}
                       image={page.meta_image.image}
                       src={page.meta_image.src}
                       width={250}
                       caption={false} />
      </LabelledField>
      {templateConfig.metadata_blocks.map(b =>
        <Block key={b.name}
               block={b}
               errors={errorsOn(page, b.name)}
               dir={inputDir}
               lang={locale}
               onChange={handleChange(b.name)}
               value={blockValue(state, b)} />)}
    </React.Fragment>
  );
}
