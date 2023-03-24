import React from "react";
import PropTypes from "prop-types";

import usePage, { blockValue, errorsOn, updateBlock } from "./usePage";
import Block from "./Block";
import Dates from "./Dates";

export default function Content(props) {
  const { locale, locales, templates } = props;
  const [page, setPage, templateConfig] = usePage(props.page, templates);

  const inputDir = (locales && locales[locale] && locales[locale].dir) || "ltr";

  return (
    <React.Fragment>
      {templateConfig.blocks.map(b =>
        <Block key={b.name}
               block={b}
               errors={errorsOn(page, b.name)}
               dir={inputDir}
               lang={locale}
               onChange={updateBlock(page, setPage, b, locale)}
               value={blockValue(page, b, locale)} />)}
      {templateConfig.dates &&
       <Dates starts_at={page.starts_at}
              ends_at={page.ends_at}
              all_day={page.all_day} />}
    </React.Fragment>
  );
}

Content.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  page: PropTypes.object,
  templates: PropTypes.array
};
