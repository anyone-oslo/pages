import * as Drag from "./Drag";
import { Locale, LocalizedValue } from "../types";

export type Resource = {
  id?: number;
  name: LocalizedValue;
  filename: string;
  description?: LocalizedValue;
  url?: string;
};

export type Record = {
  id?: number;
  attachment: Resource;
  uploading?: boolean;
};

export type Options = {
  attribute: string;
  locale: string;
  locales: { [index: string]: Locale };
  showEmbed: boolean;
};

export type State = {
  collection: Drag.Collection<Record>;
  deleted: Record[];
  setDeleted: (records: Record[]) => void;
  update: (records: Record[]) => void;
};
