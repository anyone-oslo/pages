declare namespace Attachments {
  interface Options {
    attribute: string;
    locale: string;
    locales: { [index: string]: Locale };
    showEmbed: boolean;
  }

  interface State {
    collection: Drag.Collection<AttachmentRecord>;
    deleted: AttachmentRecord[];
    setDeleted: (records: AttachmentRecord[]) => void;
  }
}
