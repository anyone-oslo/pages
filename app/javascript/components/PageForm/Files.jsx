import React from "react";
import PropTypes from "prop-types";
import Attachments from "../Attachments";

export default function Files(props) {
  const { locale, locales, records } = props;

  return (
    <div className="page-files">
      <Attachments
        attribute="page[page_files_attributes]"
        showEmbed={true}
        locale={locale}
        locales={locales}
        records={records}
      />
    </div>
  );
}

Files.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  records: PropTypes.array
};
