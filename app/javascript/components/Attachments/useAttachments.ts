import { useState } from "react";
import { useDragCollection } from "../drag";
import * as Attachments from "../../types/Attachments";

export default function useAttachments(
  records: Attachments.Record[]
): Attachments.State {
  const [deleted, setDeleted] = useState<Attachments.Record[]>([]);
  const collection = useDragCollection(records);

  const update = (records: Attachments.Record[]) => {
    collection.dispatch({ type: "reinitialize", payload: records });
    setDeleted([]);
  };

  return {
    collection: collection,
    deleted: deleted,
    setDeleted: setDeleted,
    update: update
  };
}
