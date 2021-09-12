import React from "react";
import PropTypes from "prop-types";
import Attachments from "./Attachments";

export default class PageFiles extends React.Component {
  render() {
    return (
      <div className="page-files">
        <Attachments attribute="page[page_files_attributes]"
                     showEmbed={true}
                     locale={this.props.locale}
                     locales={this.props.locales}
                     csrf_token={this.props.csrf_token}
                     records={this.props.records} />
      </div>
    );
  }
}

PageFiles.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  csrf_token: PropTypes.string,
  records: PropTypes.array
};
