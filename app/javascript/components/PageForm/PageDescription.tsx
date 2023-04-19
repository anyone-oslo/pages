import React from "react";

import { PageFormAction, PageFormState } from "./usePage";
import LocaleLinks from "./LocaleLinks";

interface PageDescriptionProps {
  state: PageFormState;
  dispatch: (action: PageFormAction) => void;
  children: JSX.Element;
}

function editLink(locale: string, page: PageResource): string {
  return (
    <a href={`/admin/${locale}/pages/${page.id}/edit`}>
      {pageName(locale, page)}
    </a>
  );
}

function pageName(locale: string, page: PageResource) {
  return page.name[locale] || <i>Untitled</i>;
}

export default function PageDescription(props: PageDescriptionProps) {
  const { state, dispatch, children } = props;
  const { locale, page } = state;

  return (
    <div className="page-description with_content_tabs">
      <LocaleLinks state={state} dispatch={dispatch} />
      <h3>
        {page.ancestors.map((p) => (
          <React.Fragment key={p.id}>
            {editLink(locale, p)}
            {" » "}
          </React.Fragment>
        ))}
        {page.id ? editLink(locale, page) : "New Page"}
      </h3>
      {children}
    </div>
  );
}
