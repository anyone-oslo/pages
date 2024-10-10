type Props = {
  active: boolean;
};

export default function TabPanel(props: React.PropsWithChildren<Props>) {
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
