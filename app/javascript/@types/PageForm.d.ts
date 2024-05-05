declare namespace PageForm {
  interface Action {
    type: string;
    payload?: boolean | string | Partial<Page.Resource> | Partial<Page.Blocks>;
  }

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
