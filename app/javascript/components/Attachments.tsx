import useAttachments from "./Attachments/useAttachments";
import List from "./Attachments/List";
import * as Attachment from "../types/Attachments";

type Props = Attachment.Options & {
  records: Attachment.Record[];
};

export default function Attachments(props: Props) {
  const state = useAttachments(props.records);

  return <List state={state} {...props} />;
}
