declare namespace PageForm {
  interface Action {
    type: string;
    payload?: string | Partial<Page.Resource> | Partial<Page.Blocks>;
  }

  interface State<T = Page.Resource> {
    locale: string;
    locales: { [index: string]: Locale };
    page: T;
    templates: Template.Config[];
    inputDir?: "ltr" | "rtl";
    templateConfig?: Template.Config;
  }

  interface Tab {
    id: string;
    name: string;
    enabled: boolean;
  }
}
