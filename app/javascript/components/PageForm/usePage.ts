import { useReducer } from "react";

export type Author = [name: string, id: number];

export interface StatusLabels {
  [index: number]: string;
}

export interface PageFormAction {
  type: string;
  payload?: string | Record<string, unknown>;
}

export interface PageFormState {
  locale: string;
  locales: { [index: string]: Locale };
  page: PageResource;
  templates: TemplateConfig[];
  inputDir: "ltr" | "rtl";
  templateConfig: TemplateConfig;
}

export type PageBlockValue = string | Record<string, string>;

export function blockValue(
  state: PageFormState,
  block: TemplateBlock
): PageBlockValue {
  if (block.localized) {
    const value: Record<string, string> = state.page.blocks[block.name] || {};

    return value[state.locale] || "";
  } else {
    return state.page.blocks[block.name] || "";
  }
}

export function errorsOn(page: PageResource, attribute: string): string[] {
  return page.errors
    .filter((e) => e.attribute === attribute)
    .map((e) => e.message);
}

function parseDate(str: string): Date | null {
  if (!str) {
    return null;
  } else if (typeof str === "string") {
    return new Date(str);
  } else {
    return str;
  }
}

function derivedState(state: PageFormState): PageFormState {
  const { locale, locales, page, templates } = state;
  return {
    ...state,
    inputDir: (locales && locales[locale] && locales[locale].dir) || "ltr",
    templateConfig: templates.filter(
      (t) => t.template_name === page.template
    )[0]
  };
}

function parsedDates(page: PageResource) {
  return {
    published_at: parseDate(page.published_at),
    starts_at: parseDate(page.starts_at),
    ends_at: parseDate(page.ends_at)
  };
}

function localizedAttributes(templates: TemplateConfig[]): string[] {
  const allBlocks = (t: TemplateConfig): TemplateBlock[] => {
    return [...t.blocks, ...t.metadata_blocks];
  };

  const blockNames = templates
    .map(allBlocks)
    .reduce((acc, val) => acc.concat(val), [])
    .filter((b) => b.localized)
    .map((b) => b.name)
    .filter((value, index, array) => array.indexOf(value) === index);

  return ["path_segment", ...blockNames];
}

function prepare(state: PageFormState): PageFormState {
  const page = { ...state.page, ...parsedDates(state.page) };
  return { ...state, page: page };
}

function reducer(state: PageFormState, action: PageFormAction): PageFormState {
  const { type, payload } = action;
  switch (type) {
    case "setLocale":
      return { ...state, locale: payload };
    case "update":
      return updatePage(state, payload);
    case "updateBlocks":
      return updatePageBlocks(state, payload);
    default:
      return state;
  }
}

function updateLocalized(
  state: PageFormState,
  obj: { [index: string]: PageBlockValue },
  attributes: Record<string, string>
) {
  const { locale, templates } = state;
  const nextObj = {};

  Object.keys(attributes).forEach((attr: string) => {
    if (localizedAttributes(templates).indexOf(attr) !== -1) {
      nextObj[attr] = {
        ...obj[attr],
        [locale]: attributes[attr]
      } as PageBlockValue;
    } else {
      nextObj[attr] = attributes[attr];
    }
  });

  return { ...obj, ...nextObj };
}

function updatePageBlocks(
  state: PageFormState,
  attributes: Record<string, string>
): PageFormState {
  const { page } = state;

  return {
    ...state,
    page: { ...page, blocks: updateLocalized(state, page.blocks, attributes) }
  };
}

function updatePage(
  state: PageFormState,
  attributes: Record<string, string>
): PageFormState {
  return { ...state, page: updateLocalized(state, state.page, attributes) };
}

export default function usePage(
  initialState: PageFormState
): [PageFormState, (PageFormAction) => void] {
  const [state, dispatch] = useReducer(reducer, prepare(initialState));
  return [derivedState(state), dispatch];
}
