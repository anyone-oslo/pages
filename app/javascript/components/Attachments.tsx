import React, { useState } from "react";
import List from "./Attachments/List";

import { useDragCollection } from "./drag";

interface Props {
  attribute: string;
  locale: string;
  locales: { [index: string]: Locale };
  records: AttachmentRecord[];
  showEmbed: boolean;
}

export default function Attachments(props: Props) {
  const { attribute, locale, locales, records, showEmbed } = props;

  const collection = useDragCollection(records);
  const [deleted, setDeleted] = useState<AttachmentRecord[]>([]);

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
