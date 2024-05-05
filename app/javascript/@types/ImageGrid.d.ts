declare namespace ImageGrid {
  interface Options {
    attribute: string;
    enablePrimary: boolean;
    locale: string;
    locales: { [index: string]: Locale };
    primaryAttribute: string;
    showEmbed: boolean;
  }

  interface State {
    primary: Drag.Collection<ImageRecord>;
    images: Drag.Collection<ImageRecord>;
    deleted: ImageRecord[];
    setDeleted: (records: ImageRecord[]) => void;
  }
}
