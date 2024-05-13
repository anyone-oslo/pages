import React, { MouseEvent } from "react";

interface Props {
  className: string;
  name: string;
  onClick: (evt: React.MouseEvent) => void;
}

export default function RichTextToolbarButton(props: Props) {
  return (
    <a
      title={props.name}
      className={"button " + props.className}
      onClick={props.onClick}>
      <i className={"fa-solid fa-" + props.className} />
    </a>
  );
}
