type Props = {
  name: string;
  locale: string;
  dir?: string;
  editUrl?: string;
}

export default function PageName(props: Props) {
  const { name, locale, dir, editUrl } = props;

  const span = (
    <span dir={dir} lang={locale}>
      {name || <i className="untitled">Untitled</i>}
    </span>
  );

  const preventDrag = (evt: React.MouseEvent) => {
    evt.preventDefault();
  };

  if (editUrl) {
    return (
      <a href={editUrl} className="name" onDragStart={preventDrag}>
        {span}
      </a>
    );
  } else {
    return <span className="name">{span}</span>;
  }
}
