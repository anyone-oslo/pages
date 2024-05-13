import React from "react";
import ImageGrid from "./ImageGrid";

interface Props {
  locale: string;
  locales: { [index: string]: Locale };
  records: ImageRecord[];
}

export default function PageImages(props: Props) {
  return (
    <div className="page-images">
      <ImageGrid
        attribute="page[page_images_attributes]"
        primaryAttribute="page[image_id]"
        enablePrimary={true}
        showEmbed={true}
        locale={props.locale}
        locales={props.locales}
        records={props.records}
      />
    </div>
  );
}
