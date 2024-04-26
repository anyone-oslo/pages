interface Locale {
  name: string;
  dir: "ltr" | "rtl";
}

type LocalizedValue = Record<string, string>;
type MaybeLocalizedValue = LocalizedValue | string;

interface AttachmentResource {
  id: number | null;
  name: LocalizedValue;
  description: LocalizedValue;
  url: string;
  filename: string;
}

interface AttachmentRecord extends Drag.DraggableRecord {
  id?: number;
  attachment: AttachmentResource;
  uploading?: boolean;
}

interface ImageResource {
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

interface ImageRecord extends Drag.DraggableRecord {
  id?: number;
  image: ImageResource;
  primary?: boolean;
  src?: string;
  file?: File;
}

type ImageResponse = ImageResource | { status: "error"; error: string };

type PageBlockValue = LocalizedValue | string;
