import React from "react";

import * as PageEditor from "../../types/PageEditor";

interface Props {
  state: PageEditor.State;
  dispatch: (action: PageEditor.Action) => void;
}

export default function LocaleLinks(props: Props) {
  const { state, dispatch } = props;
  const { locale, locales } = state;

  const handleClick = (newLocale: string) => (evt: React.MouseEvent) => {
    evt.preventDefault();
    dispatch({ type: "setLocale", payload: newLocale });
  };

  if (!locales) {
    return "";
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
