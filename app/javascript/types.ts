export type Locale = {
  name: string;
  dir: "ltr" | "rtl";
};

export type LocalizedValue = Record<string, string>;
export type MaybeLocalizedValue = LocalizedValue | string;
