import { useState } from "react";
import { useDragCollection } from "../drag";
import * as Attachments from "../../types/Attachments";

export default function useAttachments(
  records: Attachments.Record[]
): Attachments.State {
  const [deleted, setDeleted] = useState<Attachments.Record[]>([]);

  return {
    collection: useDragCollection(records),
    deleted: deleted,
    setDeleted: setDeleted
  };
}
