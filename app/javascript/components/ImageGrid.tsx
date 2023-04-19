import React, { useState } from "react";
import Grid from "./ImageGrid/Grid";

import { useDragCollection } from "./drag";

interface ImageGridProps {
  attribute: string;
  enablePrimary: boolean;
  locale: string;
  locales: { [index: string]: Locale };
  primaryAttribute: string;
  records: ImageRecord[];
  showEmbed: boolean;
}

function initRecords(props: ImageGridProps) {
  const primary = props.enablePrimary
    ? props.records.filter((r) => r.primary).slice(0, 1)
    : [];

  return [primary, props.records.filter((r) => primary.indexOf(r) === -1)];
}

export default function ImageGrid(props: ImageGridProps) {
  const {
    attribute,
    locale,
    locales,
    enablePrimary,
    primaryAttribute,
    showEmbed
  } = props;

  const [initPrimary, initImages] = initRecords(props);
  const primary = useDragCollection(initPrimary);
  const images = useDragCollection(initImages);
  const [deleted, setDeleted] = useState([]);

  return (
    <Grid
      attribute={attribute}
      deleted={deleted}
      setDeleted={setDeleted}
      locale={locale}
      locales={locales}
      enablePrimary={enablePrimary}
      primaryAttribute={primaryAttribute}
      primary={primary}
      images={images}
      showEmbed={showEmbed}
    />
  );
}
