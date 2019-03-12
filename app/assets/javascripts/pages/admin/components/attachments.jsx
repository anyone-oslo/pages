class Attachments extends DragUploader {
  constructor(props) {
    super(props);

    this.state = {
      ...this.state,
      records: props.records.map(
        r => ({ ...r, ref: React.createRef(), handle: this.getHandle() })),
      deleted: []
    };

    this.container = React.createRef();

    this.deleteRecord = this.deleteRecord.bind(this);
    this.receiveFiles = this.receiveFiles.bind(this);
  }

  attributeName(record) {
    return `${this.props.attribute}[${this.index(record) + 1}]`;
  }

  deleteRecord(record) {
    let { records, deleted } = this.state;
    records = records.filter(i => i != record);
    if (record.id) {
      deleted = [...deleted, record];
    }
    this.setState({ records: records, deleted: deleted });
  }

  draggables() {
    return this.state.records;
  }

  getDraggedOrder() {
    let dragging = this.state.dragging;
    var records = this.state.records;
    if (dragging) {
      if (this.hovering(this.container)) {
        records = [];
        this.state.records.filter(r => r !== dragging).forEach(r => {
          if (this.hovering(r) && records.indexOf(dragging) === -1) {
            records.push(dragging);
          }
          records.push(r);
        });
        if (records.indexOf(dragging) === -1) {
          records.push(dragging);
        }
      } else {
        records = this.state.records.filter(r => r !== dragging);
        if (this.state.y < this.container.current.getBoundingClientRect().top) {
          records = [dragging, ...records];
        } else {
          records.push(dragging);
        }
      }
    }
    return records;
  }

  index(record) {
    let { records, deleted } = this.state;
    let ordered = [...records, ...deleted];
    return ordered.indexOf(record);
  }

  injectUploads(files, records) {
    let queue = files.slice();
    let source = records;

    if (source.indexOf("Files") === -1) {
      return [...source, ...queue];
    } else {
      records = [];
      source.forEach(function (record) {
        if (record === "Files") {
          records = [...records, ...queue];
        } else {
          records.push(record);
        }
      });
    }

    return records;
  }

  receiveFiles(files, newState) {
    this.setState({
      ...newState,
      records: this.injectUploads(files.map(f => this.uploadAttachment(f)),
                                  this.getDraggedOrder())
    });
  }

  render() {
    let { dragging, deleted } = this.state;
    let records = this.getDraggedOrder();
    let classes = ["attachments"];
    if (dragging) {
      classes.push("dragover");
    }
    return (
      <div className={classes.join(" ")}
           ref={this.container}
           onDragOver={this.drag}
           onDrop={this.dragEnd}>
        <div className="files">
          {records.map(r => this.renderAttachment(r))}
        </div>
        <div className="deleted">
          {deleted.map(r => this.renderDeletedRecord(r))}
        </div>
        <div className="drop-target">
          <FileUploadButton multiple={true}
                            multiline={true}
                            callback={this.receiveFiles} />
        </div>
      </div>
    );
  }

  renderAttachment(record) {
    let dragging = this.state.dragging;

    if (record === "Files") {
      return (
        <div className="attachment drop-placeholder"
             key="file-placeholder">
          Upload files here
        </div>
      );
    }

    let onUpdate = (attachment) => {
      this.updateAttachment(record, attachment);
    };

    return (
      <Attachment key={record.handle}
                  record={record}
                  locale={this.props.locale}
                  locales={this.props.locales}
                  csrf_token={this.props.csrf_token}
                  showEmbed={this.props.showEmbed}
                  startDrag={this.startDrag}
                  position={this.index(record) + 1}
                  onUpdate={onUpdate}
                  deleteRecord={this.deleteRecord}
                  attributeName={this.attributeName(record)}
                  placeholder={dragging && dragging == record} />
    );
  }

  renderDeletedRecord(record) {
    let attachment = record.attachment;
    let attrName = this.attributeName(record);
    return (
      <span className="deleted-attachment" key={`deleted-${record.id}`}>
        <input name={`${attrName}[id]`}
               type="hidden" value={record.id} />
        <input name={`${attrName}[attachment_id]`}
               type="hidden" value={(attachment && attachment.id) || ""} />
        <input name={`${attrName}[_destroy]`}
               type="hidden" value={true} />
      </span>
    );
  }

  updateAttachment(record, attachment) {
    let records = this.state.records.slice();

    records[records.indexOf(record)] = {
      ...record,
      attachment: { ...record.attachment, ...attachment }
    };

    this.setState({ records: records });
  }

  filenameToName(str) {
    return str.replace(/\.[\w\d]+$/, "").replace(/_/g, " ");
  }

  uploadAttachment(file) {
    let component = this;
    let locale = this.props.locale;
    let locales = this.props.locales ? Object.keys(this.props.locales) : [locale];

    let name = {};
    locales.forEach((l) => name[l] = file.name);

    let obj = { attachment: { filename: file.name, name: name },
                uploading: true,
                ref: React.createRef(),
                handle: this.getHandle() };
    let data = new FormData();

    data.append("attachment[file]", file);
    locales.forEach((l) => {
      data.append(`attachment[name][${l}]`, this.filenameToName(file.name));
    });
    this.postFile("/admin/attachments.json", data, function (json) {
      obj.attachment = json;
      obj.uploading = false;
      component.setState({ });
    });

    return obj;
  }
}
