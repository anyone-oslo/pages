import { useState } from "react";

import * as Images from "../../types/Images";

import { useDragCollection } from "../drag";

function filterRecords(records: Images.Record[], enablePrimary = false) {
  const primaryRecords = enablePrimary
    ? records.filter((r) => r.primary).slice(0, 1)
    : [];
  const imageRecords = records.filter((r) => primaryRecords.indexOf(r) === -1);
  return [primaryRecords, imageRecords];
}

export default function useImageGrid(
  records: Images.Record[],
  enablePrimary = false
): Images.GridState {
  const [primaryRecords, imageRecords] = filterRecords(records, enablePrimary);

  const primary = useDragCollection(primaryRecords);
  const images = useDragCollection(imageRecords);
  const [deleted, setDeleted] = useState<Images.Record[]>([]);

  const update = (records: Images.Record[]) => {
    const [primaryRecords, imageRecords] = filterRecords(
      records,
      enablePrimary
    );
    primary.dispatch({ type: "reinitialize", payload: primaryRecords });
    images.dispatch({ type: "reinitialize", payload: imageRecords });
    setDeleted([]);
  };

  return {
    primary: primary,
    images: images,
    deleted: deleted,
    setDeleted: setDeleted,
    update: update
  };
}
