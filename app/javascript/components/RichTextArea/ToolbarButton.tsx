type Props = {
  className: string;
  name: string;
  onClick: (evt: React.MouseEvent) => void;
};

export default function ToolbarButton(props: Props) {
  return (
    <a
      title={props.name}
      className={"button " + props.className}
      onClick={props.onClick}>
      <i className={"fa-solid fa-" + props.className} />
    </a>
  );
}
