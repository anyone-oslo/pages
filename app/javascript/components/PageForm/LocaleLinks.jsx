import React from "react";
import PropTypes from "prop-types";

export default function LocaleLinks(props) {
  const { state, dispatch } = props;
  const { locale, locales } = state;

  const handleClick = (newLocale) => (evt) => {
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

LocaleLinks.propTypes = {
  state: PropTypes.object,
  dispatch: PropTypes.func
};
