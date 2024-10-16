import * as Attachments from "./Attachments";
import * as Images from "./Images";
import { LocalizedValue, MaybeLocalizedValue } from "../types";

export type Author = [name: string, id: number];

export type Ancestor = {
  id: number;
  name: LocalizedValue;
  path_segment: LocalizedValue;
};

export type StatusLabels = {
  [index: number]: string;
};

type BaseResource = {
  id?: number;
  blocks: Blocks;
  news_page: boolean;
  parent_page_id: number;
  permissions: string[];
  pinned: boolean;
  published_at: Date;
  status: number;
};

export type TreeResource = BaseResource & {
  editing?: boolean;
};

export type Blocks = {
  [index: string]: MaybeLocalizedValue;
  name: LocalizedValue;
};

export type MetaImage = {
  src?: string;
  image?: Images.Resource;
};

export type Resource = BaseResource & {
  all_day: boolean;
  ancestors: Ancestor[];
  enabled_tags: string[];
  ends_at: Date;
  errors: { attribute: string; message: string }[];
  feed_enabled: boolean;
  meta_image: MetaImage;
  page_files: Attachments.Record[];
  page_images: Images.Record[];
  path_segment: MaybeLocalizedValue;
  redirect_to: string;
  skip_index: boolean;
  starts_at: Date;
  tags_and_suggestions: string[];
  template: string;
  unique_name: string;
  urls: LocalizedValue;
  user_id: number;
};

export type SerializedResource = Omit<
  Resource,
  "published_at" | "starts_at" | "ends_at"
> & {
  published_at: string;
  starts_at: string;
  ends_at: string;
};
