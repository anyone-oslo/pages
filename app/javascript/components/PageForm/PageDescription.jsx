import React from "react";
import PropTypes from "prop-types";

import LocaleLinks from "./LocaleLinks";

function editLink(locale, page) {
  return(
    <a href={`/admin/${locale}/pages/${page.id}/edit`}>
      {pageName(locale, page)}
    </a>
  );
}

function pageName(locale, page) {
  return page.name[locale] || <i>Untitled</i>;
}

export default function PageDescription(props) {
  const { state, dispatch, children } = props;
  const { locale, page } = state;

  return (
    <div className="page-description with_content_tabs">
      <LocaleLinks state={state} dispatch={dispatch} />
      <h3>
        {page.ancestors.map(p =>
          <React.Fragment key={p.id}>
            {editLink(locale, p)}
            {" » "}
          </React.Fragment>)}
        {page.id ? editLink(locale, page) : "New Page"}
      </h3>
      {children}
    </div>
  );
}

PageDescription.propTypes = {
  state: PropTypes.object,
  dispatch: PropTypes.func,
  children: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.object,
    PropTypes.array
  ]),
};
