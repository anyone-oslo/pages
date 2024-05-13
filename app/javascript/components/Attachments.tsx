import React from "react";
import useAttachments from "./Attachments/useAttachments";
import List from "./Attachments/List";

interface Props extends Attachments.Options {
  records: AttachmentRecord[];
}

export default function Attachments(props: Props) {
  const state = useAttachments(props.records);

  return <List state={state} {...props} />;
}
