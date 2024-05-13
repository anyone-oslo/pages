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

  interface TreeResource {
    id?: number;
    blocks: Blocks;
    news_page: boolean;
    parent_page_id: number;
    permissions: string[];
    pinned: boolean;
    published_at: Date;
    status: number;
  }

  interface Blocks {
    [index: string]: MaybeLocalizedValue;
    name: LocalizedValue;
  }

  interface MetaImage {
    src?: string;
    image?: ImageResource;
  }

  interface Resource extends TreeResource {
    all_day: boolean;
    ancestors: Ancestor[];
    blocks: Blocks;
    enabled_tags: string[];
    ends_at: Date;
    errors: { attribute: string; message: string }[];
    feed_enabled: boolean;
    meta_image: MetaImage;
    page_files: AttachmentRecord[];
    page_images: ImageRecord[];
    path_segment: LocalizedValue;
    redirect_to: string;
    starts_at: Date;
    tags_and_suggestions: string[];
    template: string;
    unique_name: string;
    urls: LocalizedValue;
    user_id: number;
  }

  interface SerializedResource
    extends Omit<Resource, "published_at" | "starts_at" | "ends_at"> {
    published_at: string;
    starts_at: string;
    ends_at: string;
  }

  interface TreeItem extends Partial<TreeResource> {
    blocks: Blocks;
    editing?: boolean;
    permissions?: string[];
  }

  interface TreeNode extends TreeItem, Tree.Node {
    children: TreeNode[];
  }
}
