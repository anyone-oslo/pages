export interface Locale {
  name: string;
  dir: "ltr" | "rtl";
}

export interface AttachmentResource {
  id: number | null;
  name: Record<string, string>;
  description: Record<string, string>;
  url: string;
}

export interface ImageResource {
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
