import React, { useState } from "react";
import PropTypes from "prop-types";
import List from "./Attachments/List";

import { useDragCollection } from "./drag";

export default function Attachments(props) {
  const { attribute, locale, locales, records, showEmbed } = props;

  const collection = useDragCollection(records);
  const [deleted, setDeleted] = useState([]);

  return (
    <List
      attribute={attribute}
      locale={locale}
      locales={locales}
      collection={collection}
      deleted={deleted}
      setDeleted={setDeleted}
      showEmbed={showEmbed}
    />
  );
}

Attachments.propTypes = {
  attribute: PropTypes.string,
  locale: PropTypes.string,
  locales: PropTypes.object,
  records: PropTypes.array,
  showEmbed: PropTypes.bool
};
