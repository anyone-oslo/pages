import React from "react";

import { PageFormAction, PageFormState } from "./usePage";

interface LocaleLinksProps {
  state: PageFormState,
  dispatch: (action: PageFormAction) => void
}

export default function LocaleLinks(props: LocaleLinksProps) {
  const { state, dispatch } = props;
  const { locale, locales } = state;

  const handleClick = (newLocale: string) => (evt: Event) => {
    evt.preventDefault();
    dispatch({ type: "setLocale", payload: newLocale });
  };

  if (!locales) {
    return "";
  }

  return (
    <div className="links">
      {Object.keys(locales).map(l =>
        <a key={l}
           className={locale == l ? "current" : ""}
           href="#"
           onClick={handleClick(l)}>
          {locales[l].name}
        </a>)}
    </div>
  );
}
