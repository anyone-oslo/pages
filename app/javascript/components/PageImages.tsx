import * as Images from "../types/Images";
import { Locale } from "../types";

import ImageGrid from "./ImageGrid";

type Props = {
  locale: string;
  locales: { [index: string]: Locale };
  records: Images.Record[];
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
