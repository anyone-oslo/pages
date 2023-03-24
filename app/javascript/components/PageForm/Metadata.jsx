import React from "react";
import PropTypes from "prop-types";

import usePage, { blockValue, errorsOn, updateBlock } from "./usePage";
import Block from "./Block";

export default function Metadata(props) {
  const { locale, locales, templates } = props;
  const [page, setPage, templateConfig] = usePage(props.page, templates);

  const inputDir = (locales && locales[locale] && locales[locale].dir) || "ltr";

  return (
    <React.Fragment>
      {templateConfig.metadata_blocks.map(b =>
        <Block key={b.name}
               block={b}
               errors={errorsOn(page, b.name)}
               dir={inputDir}
               lang={locale}
               onChange={updateBlock(page, setPage, b, locale)}
               value={blockValue(page, b, locale)} />)}
    </React.Fragment>
  );
}

Metadata.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  page: PropTypes.object,
  templates: PropTypes.array
};
