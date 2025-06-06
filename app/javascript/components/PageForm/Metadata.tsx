import { Fragment } from "react";

import * as Pages from "../../types/Pages";
import { MaybeLocalizedValue } from "../../types";

import { blockValue, errorsOn } from "./utils";
import usePageFormContext from "./usePageFormContext";
import Block from "./Block";
import PathSegment from "./PathSegment";
import LabelledField from "../LabelledField";
import ImageUploader from "../ImageUploader";

export default function Metadata() {
  const { state, dispatch } = usePageFormContext();

  const { page, locale, locales, inputDir, templateConfig } = state;

  const handleChange = (attr: string) => (value: MaybeLocalizedValue) => {
    dispatch({ type: "updateBlocks", payload: { [attr]: value } });
  };

  const handleMetaImage = (value: Pages.MetaImage) => {
    dispatch({ type: "update", payload: { meta_image: value } });
  };

  return (
    <Fragment>
      <PathSegment />
      <LabelledField
        htmlFor="page_meta_image_id"
        label="Image"
        description={
          "Image displayed when sharing on social media. " +
          "Will fall back to the primary image if absent. " +
          "Recommended size is at least 1200x630."
        }
        errors={errorsOn(page, "meta_image_id")}>
        <ImageUploader
          attr="page[meta_image_id]"
          locale={locale}
          locales={locales}
          image={page.meta_image.image}
          src={page.meta_image.src}
          onChange={handleMetaImage}
          width={250}
          caption={false}
        />
      </LabelledField>
      {templateConfig.metadata_blocks.map((b) => (
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
