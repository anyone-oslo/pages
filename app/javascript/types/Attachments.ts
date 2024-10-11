import * as Drag from "./Drag";
import { Locale, LocalizedValue } from "../types";

export interface Resource {
  id?: number;
  name: LocalizedValue;
  filename: string;
  description?: LocalizedValue;
  url?: string;
}

export interface Record {
  id?: number;
  attachment: Resource;
  uploading?: boolean;
}

export interface Options {
  attribute: string;
  locale: string;
  locales: { [index: string]: Locale };
  showEmbed: boolean;
}

export interface State {
  collection: Drag.Collection<Record>;
  deleted: Record[];
  setDeleted: (records: Record[]) => void;
  update: (records: Record[]) => void;
}
