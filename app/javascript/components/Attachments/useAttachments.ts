import { useState } from "react";
import { useDragCollection } from "../drag";

export default function useAttachments(
  records: AttachmentRecord[]
): Attachments.State {
  const [deleted, setDeleted] = useState<AttachmentRecord[]>([]);

  return {
    collection: useDragCollection(records),
    deleted: deleted,
    setDeleted: setDeleted
  };
}
