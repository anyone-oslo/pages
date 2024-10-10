import { Fragment } from "react";
import * as Pages from "../../types/Pages";
import usePageFormContext from "./usePageFormContext";

import LocaleLinks from "./LocaleLinks";

function editLink(locale: string, page: Pages.Ancestor | Pages.Resource) {
  return (
    <a href={`/admin/${locale}/pages/${page.id}/edit`}>
      {pageName(locale, page)}
    </a>
  );
}

function pageName(locale: string, page: Pages.Ancestor | Pages.Resource) {
  if ("name" in page) {
    return page.name[locale];
  }
  return page.blocks.name[locale] || <i>Untitled</i>;
}

export default function PageDescription({ children }: React.PropsWithChildren) {
  const { state } = usePageFormContext();
  const { locale, page } = state;

  return (
    <div className="page-description with_content_tabs">
      <LocaleLinks />
      <h3>
        {page.ancestors.map((p) => (
          <Fragment key={p.id}>
            {editLink(locale, p)}
            {" » "}
          </Fragment>
        ))}
        {page.id ? editLink(locale, page) : "New Page"}
      </h3>
      {children}
    </div>
  );
}
