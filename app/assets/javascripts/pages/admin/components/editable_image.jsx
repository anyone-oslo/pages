class EditableImage extends React.Component {
  constructor(props) {
    super(props);
    this.openEditor = this.openEditor.bind(this);
  }

  openEditor() {
    ModalActions.open(<ImageEditor image={this.props.image} />);
  }

  render() {
    return (
      <img className="editable-image"
           src={this.props.src}
           width={this.props.width}
           height={this.props.height}
           onClick={this.openEditor} />
    );
  }
}
