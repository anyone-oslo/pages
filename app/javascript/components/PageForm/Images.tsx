import React from "react";

import { GridState } from "../../types/Images";
import { Locale } from "../../types";

import Grid from "../ImageGrid/Grid";

interface Props {
  locale: string;
  locales: { [index: string]: Locale };
  state: GridState;
}

export default function Images(props: Props) {
  return (
    <div className="page-images">
      <Grid
        attribute="page[page_images_attributes]"
        primaryAttribute="page[image_id]"
        enablePrimary={true}
        showEmbed={true}
        locale={props.locale}
        locales={props.locales}
        state={props.state}
      />
    </div>
  );
}
