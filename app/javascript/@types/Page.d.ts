declare namespace Page {
  type Author = [name: string, id: number];

  interface Ancestor {
    id: number;
    name: LocalizedValue;
    path_segment: LocalizedValue;
  }

  interface StatusLabels {
    [index: number]: string;
  }

  interface Attributes {
    id?: number;
    published_at: Date;
    pinned: boolean;
    status: number;
    page_images: ImageRecord[];
    page_files: AttachmentRecord[];
    all_day: boolean;
    unique_name: string;
    feed_enabled: boolean;
    news_page: boolean;
    redirect_to: string;
    starts_at: Date;
    ends_at: Date;
  }

  interface Blocks {
    [index: string]: MaybeLocalizedValue;
    name: LocalizedValue;
  }

  interface MetaImage {
    src?: string;
    image?: ImageResource;
  }

  interface Resource extends Attributes {
    blocks: Blocks;
    ancestors: Ancestor[];
    tags_and_suggestions: string[];
    meta_image: MetaImage;
    enabled_tags: string[];
    path_segment: LocalizedValue;
    urls: LocalizedValue;
    errors: { attribute: string; message: string }[];
    user_id: number;
    template: string;
  }

  interface SerializedResource
    extends Omit<Resource, "published_at" | "starts_at" | "ends_at"> {
    published_at: string;
    starts_at: string;
    ends_at: string;
  }

  interface TreeItem extends Partial<Attributes> {
    name: string;
    locale: string;
    parent_page_id?: number;
    param?: string;
    editing?: boolean;
  }

  interface TreeNode extends TreeItem, Tree.Node {
    children: TreeNode[];
    permissions?: string[];
  }
}
