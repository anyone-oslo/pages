import React, { useState } from "react";
import List from "./Attachments/List";

import { useDragCollection } from "./drag";

interface AttachmentsProps {
  attribute: string;
  locale: string;
  locales: { [index: string]: Locale };
  records: AttachmentRecord[];
  showEmbed: boolean;
}

export default function Attachments(props: AttachmentsProps) {
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
