import { useState } from "react";

import * as Images from "../../types/Images";

import { useDragCollection } from "../drag";

export default function useImageGrid(
  records: Images.Record[],
  enablePrimary = false
): Images.GridState {
  const primaryRecords = enablePrimary
    ? records.filter((r) => r.primary).slice(0, 1)
    : [];
  const imageRecords = records.filter((r) => primaryRecords.indexOf(r) === -1);

  const primary = useDragCollection(primaryRecords);
  const images = useDragCollection(imageRecords);
  const [deleted, setDeleted] = useState<Images.Record[]>([]);

  return {
    primary: primary,
    images: images,
    deleted: deleted,
    setDeleted: setDeleted
  };
}
