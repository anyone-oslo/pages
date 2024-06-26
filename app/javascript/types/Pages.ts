import * as Attachments from "./Attachments";
import * as Images from "./Images";
import * as Trees from "./Trees";
import { LocalizedValue, MaybeLocalizedValue } from "../types";

export type Author = [name: string, id: number];

export interface Ancestor {
  id: number;
  name: LocalizedValue;
  path_segment: LocalizedValue;
}

export interface StatusLabels {
  [index: number]: string;
}

export interface TreeResource {
  id?: number;
  blocks: Blocks;
  news_page: boolean;
  parent_page_id: number;
  permissions: string[];
  pinned: boolean;
  published_at: Date;
  status: number;
}

export interface Blocks {
  [index: string]: MaybeLocalizedValue;
  name: LocalizedValue;
}

export interface MetaImage {
  src?: string;
  image?: Images.Resource;
}

export interface Resource extends TreeResource {
  all_day: boolean;
  ancestors: Ancestor[];
  blocks: Blocks;
  enabled_tags: string[];
  ends_at: Date;
  errors: { attribute: string; message: string }[];
  feed_enabled: boolean;
  meta_image: MetaImage;
  page_files: Attachments.Record[];
  page_images: Images.Record[];
  path_segment: MaybeLocalizedValue;
  redirect_to: string;
  starts_at: Date;
  tags_and_suggestions: string[];
  template: string;
  unique_name: string;
  urls: LocalizedValue;
  user_id: number;
}

export interface SerializedResource
  extends Omit<Resource, "published_at" | "starts_at" | "ends_at"> {
  published_at: string;
  starts_at: string;
  ends_at: string;
}

export interface TreeItem extends Partial<TreeResource> {
  blocks: Blocks;
  editing?: boolean;
  permissions?: string[];
}

export interface TreeNode extends TreeItem, Trees.Node {
  children: TreeNode[];
}
