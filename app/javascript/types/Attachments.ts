import * as Drag from "./Drag";
import { Locale, LocalizedValue } from "../types";

export interface Resource {
  id: number | null;
  name: LocalizedValue;
  description: LocalizedValue;
  url: string;
  filename: string;
}

export interface Record extends Drag.DraggableRecord {
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
