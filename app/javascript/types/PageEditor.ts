import * as Pages from "./Pages";
import * as Template from "./Template";
import { Locale } from "../types";

export type Action =
  | { type: "setPage"; payload: Pages.SerializedResource }
  | { type: "setDatesEnabled"; payload: boolean }
  | { type: "setLocale"; payload: string }
  | { type: "update"; payload: Partial<Pages.Resource> }
  | { type: "updateBlocks"; payload: Partial<Pages.Blocks> };

export interface State<T = Pages.Resource> {
  locale: string;
  locales: { [index: string]: Locale };
  page: T;
  templates: Template.Config[];
  datesEnabled?: boolean;
  inputDir?: "ltr" | "rtl";
  templateConfig?: Template.Config;
}

export interface Tab {
  id: string;
  name: string;
  enabled: boolean;
}
