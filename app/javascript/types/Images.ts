import * as Drag from "./Drag";
import { Locale, LocalizedValue } from "../types";

export interface Resource {
  id: number | null;
  alternative: LocalizedValue;
  caption: LocalizedValue;
  content_type: string;
  filename: string;
  crop_start_x: number | null;
  crop_start_y: number | null;
  crop_width: number | null;
  crop_height: number | null;
  crop_gravity_x: number;
  crop_gravity_y: number;
  real_width: number;
  real_height: number;
  original_url: string;
  thumbnail_url: string;
  uncropped_url: string;
}

export interface Record extends Drag.DraggableRecord {
  id?: number;
  image: Resource;
  primary?: boolean;
  src?: string;
  file?: File;
}

export type Response = Resource | { status: "error"; error: string };

export interface GridOptions {
  attribute: string;
  enablePrimary: boolean;
  locale: string;
  locales: { [index: string]: Locale };
  primaryAttribute: string;
  showEmbed: boolean;
}

export interface GridState {
  primary: Drag.Collection<Record>;
  images: Drag.Collection<Record>;
  deleted: Record[];
  setDeleted: (records: Record[]) => void;
  update: (records: Record[]) => void;
}
