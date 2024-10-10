import usePageFormContext from "./usePageFormContext";

export default function LocaleLinks() {
  const { state, dispatch } = usePageFormContext();
  const { locale, locales } = state;

  const handleClick = (newLocale: string) => (evt: React.MouseEvent) => {
    evt.preventDefault();
    dispatch({ type: "setLocale", payload: newLocale });
  };

  if (!locales) {
    return;
  }

  return (
    <div className="links">
      {Object.keys(locales).map((l) => (
        <a
          key={l}
          className={locale == l ? "current" : ""}
          href="#"
          onClick={handleClick(l)}>
          {locales[l].name}
        </a>
      ))}
    </div>
  );
}
