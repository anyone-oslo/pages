import React from "react";
import PropTypes from "prop-types";
import ImageGrid from "./ImageGrid";

export default class PageImages extends React.Component {
  render() {
    return (
      <div className="page-images">
        <ImageGrid attribute="page[page_images_attributes]"
                   primaryAttribute="page[image_id]"
                   enablePrimary={true}
                   showEmbed={true}
                   locale={this.props.locale}
                   locales={this.props.locales}
                   csrf_token={this.props.csrf_token}
                   records={this.props.records} />
      </div>
    );
  }
}

PageImages.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  csrf_token: PropTypes.string,
  records: PropTypes.array
};
