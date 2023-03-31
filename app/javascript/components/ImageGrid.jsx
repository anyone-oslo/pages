import React, { useState } from "react";
import PropTypes from "prop-types";
import Grid from "./ImageGrid/Grid";

import { useDragCollection } from "./drag";

function initRecords(props) {
  const primary = props.enablePrimary
    ? props.records.filter((r) => r.primary).slice(0, 1)
    : [];

  return [primary, props.records.filter((r) => primary.indexOf(r) === -1)];
}

export default function ImageGrid(props) {
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

ImageGrid.propTypes = {
  attribute: PropTypes.string,
  locale: PropTypes.string,
  locales: PropTypes.object,
  records: PropTypes.array,
  enablePrimary: PropTypes.bool,
  primaryAttribute: PropTypes.string,
  showEmbed: PropTypes.bool
};
