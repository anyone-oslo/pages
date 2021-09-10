class RichTextToolbarButton extends React.Component {
  render() {
    return (
      <a title={this.props.name}
         className={"button " + this.props.className}
         onClick={this.props.onClick}>
        <i className={"fa fa-" + this.props.className} />
      </a>
    );
  }
}
