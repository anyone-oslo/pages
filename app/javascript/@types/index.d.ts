interface Locale {
  name: string;
  dir: "ltr" | "rtl";
}

interface AttachmentResource {
  id: number | null;
  name: Record<string, string>;
  description: Record<string, string>;
  url: string;
  filename: string;
}

interface AttachmentRecord {
  id: number | null;
  attachment: AttachmentResource;
}

interface ImageResource {
  id: number | null;
  alternative: Record<string, string>;
  caption: Record<string, string>;
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

interface ImageRecord {
  id: number | null;
  image: ImageResource;
}

type ImageResponse = ImageResource | { status: "error"; error: string };

interface PageAncestor {
  id: number;
  name: Record<string, string>;
  path_segment: Record<string, string>;
}

interface PageResource {
  [index: string]: string | Record<string, string>;
  id: number | null;
  ancestors: PageAncestor[];
  starts_at: string | null;
  ends_at: string | null;
  all_day: boolean;
  status: string;
  published_at: string;
  pinned: boolean;
  template: string;
  unique_name: string;
  feed_enabled: boolean;
  news_page: boolean;
  user_id: number;
  redirect_to: string;
  page_images: ImageRecord[];
  page_files: AttachmentRecord[];
  enabled_tags: string[];
  tags_and_suggestions: string[];
  meta_image: {
    src: string | null;
    image: ImageResource | null;
  };
  name: Record<string, string>;
  path_segment: Record<string, string>;
  urls: Record<string, string>;
  errors: { attribute: string; message: string }[];
}

interface TemplateBlock {
  name: string;
  title: string;
  description?: string;
  optional: boolean;
  enforced: boolean;
  size: string;
  class?: string;
  localized?: boolean;
  placeholder: boolean;
  options?: [string, string][];
}

interface TemplateConfig {
  name: string;
  template_name: string;
  blocks: TemplateBlock[];
  metadata_blocks: TemplateBlock[];
  images: boolean;
  dates: boolean;
  tags: boolean;
  files: boolean;
}
