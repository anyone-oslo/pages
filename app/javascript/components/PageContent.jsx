import React, { useState } from "react";
import PropTypes from "prop-types";

import PageBlock from "./PageContent/PageBlock";
import PageDates from "./PageContent/PageDates";

function errorsOn(page, attribute) {
  return page.errors.filter(e => e.attribute === attribute).map(e => e.message);
}

export default function PageContent(props) {
  const { locale, locales } = props;
  const [page, setPage] = useState(props.page);

  const inputDir = (locales && locales[locale] && locales[locale].dir) || "ltr";

  const templateConfig = props.templates
        .filter(t => t.template_name === page.template)[0];

  const value = (block) => {
    if (block.localized) {
      return page[block.name][locale];
    } else {
      return page[block.name];
    }
  };

  const updatePage = (block) => (newValue) => {
    let nextValue = newValue;
    if (block.localized) {
      nextValue = { ...page[block.name], [locale]: newValue };
    }
    setPage({ ...page, [block.name]: nextValue });
  };

  return (
    <React.Fragment>
      {templateConfig.blocks.map(b =>
        <PageBlock key={b.name}
                   block={b}
                   errors={errorsOn(page, b.name)}
                   dir={inputDir}
                   lang={locale}
                   onChange={updatePage(b)}
                   value={value(b)} />)}
      {templateConfig.dates &&
       <PageDates starts_at={page.starts_at}
                  ends_at={page.ends_at}
                  all_day={page.all_day} />}
    </React.Fragment>
  );
}

PageContent.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  page: PropTypes.object,
  templates: PropTypes.array
};
