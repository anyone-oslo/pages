interface TabPanelProps {
  active: boolean;
  children: React.ReactNode;
}

export default function TabPanel(props: TabPanelProps) {
  const { active, children } = props;

  const classNames = ["content-tab"];
  if (!active) {
    classNames.push("hidden");
  }

  return (
    <div className={classNames.join(" ")} role="tabpanel">
      {children}
    </div>
  );
}
