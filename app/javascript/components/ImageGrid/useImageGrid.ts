import { useState } from "react";
import { useDragCollection } from "../drag";

export default function useImageGrid(
  records: ImageRecord[],
  enablePrimary = false
): ImageGrid.State {
  const primaryRecords = enablePrimary
    ? records.filter((r) => r.primary).slice(0, 1)
    : [];
  const imageRecords = records.filter((r) => primaryRecords.indexOf(r) === -1);

  const primary = useDragCollection(primaryRecords);
  const images = useDragCollection(imageRecords);
  const [deleted, setDeleted] = useState<ImageRecord[]>([]);

  return {
    primary: primary,
    images: images,
    deleted: deleted,
    setDeleted: setDeleted
  };
}
