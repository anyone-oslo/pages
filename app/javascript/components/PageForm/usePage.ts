import { useReducer } from "react";

export function blockValue(
  state: PageForm.State,
  block: Template.Block
): string {
  if (block.localized) {
    const value: LocalizedValue =
      (state.page.blocks[block.name] as LocalizedValue) || {};

    return value[state.locale] || "";
  } else {
    return (state.page.blocks[block.name] as string) || "";
  }
}

export function errorsOn(page: Page.Resource, attribute: string): string[] {
  return page.errors
    .filter((e) => e.attribute === attribute)
    .map((e) => e.message);
}

export function unconfiguredBlocks(state: PageForm.State): Template.Block[] {
  const allBlocks: Record<string, Template.Block> = state.templates
    .flatMap((t) => t.blocks)
    .reduce((bs, b) => ({ [b.name]: b, ...bs }), {});

  const anyValue = (v: MaybeLocalizedValue) => {
    if (typeof v === "string") {
      return v ? true : false;
    } else {
      return Object.values(v).filter((v) => v).length > 0;
    }
  };

  const hasValue = Object.keys(allBlocks).filter((k) => {
    const value = state.page.blocks[k];
    return anyValue(value);
  });

  const enabled = state.templateConfig.blocks.map((b) => b.name);

  return hasValue
    .filter((b) => enabled.indexOf(b) === -1)
    .map((n) => allBlocks[n]);
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

function derivedState(state: PageForm.State): PageForm.State {
  const { locale, locales, page, templates } = state;
  return {
    ...state,
    inputDir: (locales && locales[locale] && locales[locale].dir) || "ltr",
    templateConfig: templates.filter(
      (t) => t.template_name === page.template
    )[0]
  };
}

function parsedDates(page: Page.SerializedResource) {
  return {
    published_at: parseDate(page.published_at),
    starts_at: parseDate(page.starts_at),
    ends_at: parseDate(page.ends_at)
  };
}

function localizedAttributes(templates: Template.Config[]): string[] {
  const allBlocks = (t: Template.Config): Template.Block[] => {
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

function prepare(
  state: PageForm.State<Page.SerializedResource>
): PageForm.State {
  const page = { ...state.page, ...parsedDates(state.page) };
  return { ...state, page: page, datesEnabled: page.starts_at ? true : false };
}

function reducer(
  state: PageForm.State,
  action: PageForm.Action
): PageForm.State {
  const { type, payload } = action;
  switch (type) {
    case "setPage":
      return prepare({ ...state, page: payload as Page.SerializedResource });
    case "setDatesEnabled":
      return { ...state, datesEnabled: payload as boolean };
    case "setLocale":
      return { ...state, locale: payload as string };
    case "update":
      return updatePage(state, payload as Partial<Page.Resource>);
    case "updateBlocks":
      return updatePageBlocks(state, payload as Partial<Page.Blocks>);
    default:
      return state;
  }
}

function updateLocalized<T>(
  state: PageForm.State,
  obj: T,
  attributes: Partial<T>
): T {
  const { locale, templates } = state;
  const nextObj = {};

  Object.keys(attributes).forEach((attr: string) => {
    const value = attributes[attr] as MaybeLocalizedValue;
    if (localizedAttributes(templates).indexOf(attr) !== -1) {
      nextObj[attr] = { ...obj[attr], [locale]: value } as LocalizedValue;
    } else {
      nextObj[attr] = value;
    }
  });

  return { ...obj, ...nextObj };
}

function updatePageBlocks(
  state: PageForm.State,
  attributes: Partial<Page.Blocks>
): PageForm.State {
  const { page } = state;

  return {
    ...state,
    page: { ...page, blocks: updateLocalized(state, page.blocks, attributes) }
  };
}

function updatePage(
  state: PageForm.State,
  attributes: Partial<Page.Resource>
): PageForm.State {
  return { ...state, page: updateLocalized(state, state.page, attributes) };
}

export default function usePage(
  initialState: PageForm.State<Page.SerializedResource>
): [PageForm.State, (action: PageForm.Action) => void] {
  const [state, dispatch] = useReducer(reducer, prepare(initialState));
  return [derivedState(state), dispatch];
}
