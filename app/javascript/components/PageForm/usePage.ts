import { useReducer } from "react";

import * as PageEditor from "../../types/PageEditor";
import * as Pages from "../../types/Pages";
import * as Template from "../../types/Template";
import { LocalizedValue, MaybeLocalizedValue } from "../../types";

export function blockValue(
  state: PageEditor.State,
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

export function errorsOn(page: Pages.Resource, attribute: string): string[] {
  return page.errors
    .filter((e) => e.attribute === attribute)
    .map((e) => e.message);
}

export function unconfiguredBlocks(state: PageEditor.State): Template.Block[] {
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
    const value = state.page.blocks[k] || "";
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

function derivedState(state: PageEditor.State): PageEditor.State {
  const { locale, locales, page, templates } = state;
  return {
    ...state,
    inputDir: (locales && locales[locale] && locales[locale].dir) || "ltr",
    templateConfig: templates.filter(
      (t) => t.template_name === page.template
    )[0]
  };
}

function parsedDates(page: Pages.SerializedResource) {
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
  state: PageEditor.State<Pages.SerializedResource>
): PageEditor.State {
  const page = { ...state.page, ...parsedDates(state.page) };
  return { ...state, page: page, datesEnabled: page.starts_at ? true : false };
}

function reducer(
  state: PageEditor.State,
  action: PageEditor.Action
): PageEditor.State {
  const { type, payload } = action;
  switch (type) {
    case "setPage":
      return prepare({ ...state, page: payload });
    case "setDatesEnabled":
      return { ...state, datesEnabled: payload };
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

function updateLocalized<T>(
  state: PageEditor.State,
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
  state: PageEditor.State,
  attributes: Partial<Pages.Blocks>
): PageEditor.State {
  const { page } = state;

  return {
    ...state,
    page: { ...page, blocks: updateLocalized(state, page.blocks, attributes) }
  };
}

function updatePage(
  state: PageEditor.State,
  attributes: Partial<Pages.Resource>
): PageEditor.State {
  return { ...state, page: updateLocalized(state, state.page, attributes) };
}

export default function usePage(
  initialState: PageEditor.State<Pages.SerializedResource>
): PageEditor.Return {
  const [state, dispatch] = useReducer(reducer, prepare(initialState));
  return [derivedState(state), dispatch];
}
