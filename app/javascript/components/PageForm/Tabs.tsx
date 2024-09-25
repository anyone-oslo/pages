import * as PageEditor from "../../types/PageEditor";

interface Props {
  tab: string;
  tabs: PageEditor.Tab[];
  setTab: (tab: string) => void;
}

export default function Tabs(props: Props) {
  const { tab, tabs, setTab } = props;

  const handleTabChange = (tab: PageEditor.Tab) => (evt: React.MouseEvent) => {
    evt.preventDefault();
    setTab(tab.id);
  };

  return (
    <ul className="content-tabs" role="tablist">
      {tabs.map((t) => (
        <li key={t.id} className={t.id == tab ? "current" : ""}>
          {!t.enabled && t.name}
          {t.enabled && (
            <a href={`#${t.id}`} onClick={handleTabChange(t)}>
              {t.name}
            </a>
          )}
        </li>
      ))}
    </ul>
  );
}
