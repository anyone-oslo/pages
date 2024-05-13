declare namespace PageForm {
  type Action =
    | { type: "setPage"; payload: Page.SerializedResource }
    | { type: "setDatesEnabled"; payload: boolean }
    | { type: "setLocale"; payload: string }
    | { type: "update"; payload: Partial<Page.Resource> }
    | { type: "updateBlocks"; payload: Partial<Page.Blocks> };

  interface State<T = Page.Resource> {
    locale: string;
    locales: { [index: string]: Locale };
    page: T;
    templates: Template.Config[];
    datesEnabled?: boolean;
    inputDir?: "ltr" | "rtl";
    templateConfig?: Template.Config;
  }

  interface Tab {
    id: string;
    name: string;
    enabled: boolean;
  }
}
