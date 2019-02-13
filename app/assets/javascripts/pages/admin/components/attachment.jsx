class Attachment extends React.Component {
  constructor(props) {
    super(props);
    this.copyEmbed = this.copyEmbed.bind(this);
    this.editAttachment = this.editAttachment.bind(this);
    this.deleteRecord = this.deleteRecord.bind(this);
    this.dragStart = this.dragStart.bind(this);
  }

  copyEmbed(evt) {
    let attachment = this.props.record.attachment;
    evt.preventDefault();
    const el = document.createElement("textarea");
    el.value = `[attachment:${attachment.id}]`;
    document.body.appendChild(el);
    el.select();
    document.execCommand("copy");
    document.body.removeChild(el);
    ToastActions.notice("Embed code copied to clipboard");
  }

  deleteRecord(evt) {
    evt.preventDefault();
    if (this.props.deleteRecord) {
      this.props.deleteRecord(this.props.record);
    }
  }

  dragStart(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    if (this.props.startDrag) {
      this.props.startDrag(evt, this.props.record);
    }
  }

  description() {
    let attachment = this.props.record.attachment;
    if (attachment.description && attachment.description[this.props.locale]) {
      return attachment.description[this.props.locale];
    }
    return null;
  }

  name() {
    let attachment = this.props.record.attachment;
    if (attachment.name && attachment.name[this.props.locale]) {
      return attachment.name[this.props.locale];
    }
    return null;
  }

  editAttachment(evt) {
    evt.preventDefault();
    ModalActions.open(
      <AttachmentEditor attachment={this.props.record.attachment}
                        locale={this.props.locale}
                        locales={this.props.locales}
                        csrf_token={this.props.csrf_token}
                        onUpdate={this.props.onUpdate} />
    );
  }

  renderAttachment() {
    let { attachment, uploading } = this.props.record;

    let icon = uploading ? "cloud-upload" : "paperclip";

    return(
      <div className="attachment-info">
        <h3>
          <i className={`fa fa-${icon} icon`} />
          {this.name() || <em>Untitled</em>}<br />
        </h3>
        {!uploading &&
         <a href={attachment.url}
            target="_blank">{attachment.filename}</a>}
        {!uploading && this.description() && <p>{this.description()}</p>}
      </div>
    );
  }

  render() {
    let { attributeName, record } = this.props;
    let uploading = record.uploading;
    let attachment = record.attachment;
    let classes = ["attachment"];
    if (this.props.placeholder) {
      classes.push("placeholder");
    }
    if (this.props.record.uploading) {
      classes.push("uploading");
    }
    return (
      <div className={classes.join(" ")}
           onDragStart={this.dragStart}
           ref={this.props.record.ref}
           draggable>
        <input name={`${attributeName}[id]`}
               type="hidden" value={record.id || ""} />
        <input name={`${attributeName}[attachment_id]`}
               type="hidden" value={(attachment && attachment.id) || ""} />
        <input name={`${attributeName}[position]`}
               type="hidden" value={this.props.position} />
        {this.props.enablePrimary && (
           <input name={`${attributeName}[primary]`}
                  type="hidden" value={this.props.primary} />
        )}
        {!uploading &&
         <div className="actions">
           <button onClick={this.editAttachment}>
             Edit
           </button>
           {this.props.showEmbed && (
             <button onClick={this.copyEmbed}>
               Embed
             </button>
           )}
           {this.props.deleteRecord && (
             <button onClick={this.deleteRecord}>
               Remove
             </button>
           )}
         </div>
        }
        {attachment && this.renderAttachment()}
      </div>
    );
  }
}
