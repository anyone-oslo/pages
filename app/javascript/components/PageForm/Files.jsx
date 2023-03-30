import React from "react";
import PropTypes from "prop-types";
import Attachments from "../Attachments";

export default class Files extends React.Component {
  render() {
    return (
      <div className="page-files">
        <Attachments
          attribute="page[page_files_attributes]"
          showEmbed={true}
          locale={this.props.locale}
          locales={this.props.locales}
          records={this.props.records}
        />
      </div>
    );
  }
}

Files.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  records: PropTypes.array
};
