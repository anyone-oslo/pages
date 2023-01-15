import React from "react";
import PropTypes from "prop-types";

export default class RichTextToolbarButton extends React.Component {
  render() {
    return (
      <a title={this.props.name}
         className={"button " + this.props.className}
         onClick={this.props.onClick}>
        <i className={"fa-solid fa-" + this.props.className} />
      </a>
    );
  }
}

RichTextToolbarButton.propTypes = {
  className: PropTypes.string,
  name: PropTypes.string,
  onClick: PropTypes.func
};
