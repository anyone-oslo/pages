import React from "react";
import PropTypes from "prop-types";
import ImageGrid from "../ImageGrid";

export default class Images extends React.Component {
  render() {
    return (
      <div className="page-images">
        <ImageGrid attribute="page[page_images_attributes]"
                   primaryAttribute="page[image_id]"
                   enablePrimary={true}
                   showEmbed={true}
                   locale={this.props.locale}
                   locales={this.props.locales}
                   records={this.props.records} />
      </div>
    );
  }
}

Images.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  records: PropTypes.array
};
