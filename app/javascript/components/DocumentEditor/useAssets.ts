import * as Attachments from "../../types/Attachments";
import * as Images from "../../types/Images";
import usePageFormContext from "../PageForm/usePageFormContext";

export type ImageAsset = {
  id: number;
  thumbnail: string;
  filename: string;
  alternative: string;
};

export type FileAsset = {
  id: number;
  name: string;
  filename: string;
};

function localized(value: Record<string, string> | string, locale: string) {
  if (!value) return "";
  if (typeof value === "string") return value;
  return value[locale] || Object.values(value).find((v) => v) || "";
}

/** The page's own images and files, as the pickers and node views see them. */
export default function useAssets(): {
  images: ImageAsset[];
  files: FileAsset[];
  imageById: (id: number | string | null) => ImageAsset | undefined;
  fileById: (id: number | string | null) => FileAsset | undefined;
} {
  const ctx = usePageFormContext();
  const locale = ctx?.state.locale || "";

  const imageRecords: Images.Record[] = ctx?.images
    ? [...ctx.images.primary.draggables, ...ctx.images.images.draggables]
        .filter((d) => d !== "Files")
        .map((d) => (d as { record: Images.Record }).record)
    : [];

  const images: ImageAsset[] = imageRecords.flatMap((r) =>
    r.image?.id
      ? [
          {
            id: r.image.id,
            thumbnail: r.image.thumbnail_url,
            filename: r.image.filename,
            alternative: localized(r.image.alternative, locale)
          }
        ]
      : []
  );

  const fileRecords: Attachments.Record[] = ctx?.files
    ? ctx.files.collection.draggables
        .filter((d) => d !== "Files")
        .map((d) => (d as { record: Attachments.Record }).record)
    : [];

  const files: FileAsset[] = fileRecords.flatMap((r) =>
    r.attachment?.id
      ? [
          {
            id: r.attachment.id,
            name: localized(r.attachment.name, locale) || r.attachment.filename,
            filename: r.attachment.filename
          }
        ]
      : []
  );

  return {
    images,
    files,
    imageById: (id) => images.find((i) => String(i.id) === String(id)),
    fileById: (id) => files.find((f) => String(f.id) === String(id))
  };
}
