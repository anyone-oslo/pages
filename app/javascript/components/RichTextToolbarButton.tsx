import React from "react";

interface RichTextToolbarButtonProps {
  className: string;
  name: string;
  onClick: (evt: Event) => void;
}

export default function RichTextToolbarButton(
  props: RichTextToolbarButtonProps
) {
  return (
    <a
      title={props.name}
      className={"button " + props.className}
      onClick={props.onClick}>
      <i className={"fa-solid fa-" + props.className} />
    </a>
  );
}
